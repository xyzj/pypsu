# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.2'
__doc__ = 'High-performance socket service'

import gevent as _gevent
import socket as _socket
from mxpsu import PriorityQueue, SCRIPT_DIR, stamp2time, ip2int, Platform
from mxhpss_comm import loadLicense
import select as _select
import time as _time
import gc as _gc
import os as _os

# Constants from the epoll module
_EPOLLIN = 0x001
_EPOLLPRI = 0x002
_EPOLLOUT = 0x004
_EPOLLERR = 0x008
_EPOLLHUP = 0x010
_EPOLLRDHUP = 0x2000
_EPOLLONESHOT = (1 << 30)
_EPOLLET = (1 << 31)

# Our events map exactly to the epoll events
NONE = 0

IS_EXIT = 0
# 客户端集合{fileno, ClientSession}
CLIENTS = {}
# 发送队列{fd, SendData}
SEND_QUEUE = {}
# epoll实例
if Platform.isLinux():
    IMPL = _select.epoll()
    ERROR = _EPOLLERR | _EPOLLHUP
    READ = _EPOLLIN | ERROR
    WRITE = _EPOLLOUT | READ
    WRITE_ONLY = _EPOLLOUT | ERROR
else:
    IMPL = None
    READ = []
    WRITE = []


def __license_ok():
    """
    许可证检查

    Returns:
        int: 0-许可证无效，1-许可证有效
    """
    a = loadLicense(_os.path.join(SCRIPT_DIR, 'LICENSE'))
    if 'err' in a:
        print(a)
        return 0
    else:
        return 1


def register(fileno, objwatch, ssock=None):
    global READ, WRITE, CLIENTS, IMPL
    if Platform.isLinux():
        IMPL.register(fileno, objwatch)
    else:
        if ssock is not None:
            READ.append(ssock)
        else:
            sock = CLIENTS.get(fileno)
            if sock is not None:
                if objwatch is READ:
                    if sock.sock not in READ:
                        READ.append(sock.sock)
                elif objwatch is WRITE:
                    if sock.sock not in WRITE:
                        WRITE.append(sock.sock)


def modify(fileno, objwatch):
    global READ, WRITE, CLIENTS, IMPL
    if Platform.isLinux():
        IMPL.modify(fileno, objwatch)
    else:
        sock = CLIENTS.get(fileno)
        if sock is not None:
            if objwatch is READ:
                try:
                    WRITE.remove(sock.sock)
                except:
                    pass
            elif objwatch is WRITE:
                if sock.sock not in WRITE:
                    WRITE.append(sock.sock)


def unregister(fileno):
    global READ, WRITE, CLIENTS, IMPL
    if Platform.isLinux():
        try:
            IMPL.unregister(fileno)
        except:
            pass
    else:
        sock = CLIENTS.get(fileno)
        if sock is not None:
            try:
                READ.remove(sock.sock)
            except:
                pass
            try:
                WRITE.remove(sock.sock)
            except:
                pass


class ClientSession(object):

    def __init__(self, sock, fd, address, serverport, debug=0):
        """ 初始化 socket client 实例

        Args:
            sock (socket): _socket实例
            fd (int): file descriptor
            address (tuple): (ip,port)
            serverport (int): 本地监听端口
            debug (int): 是否输出调试信息
        """
        global SEND_QUEUE, CLIENTS
        self.sock = sock
        if self.sock is not None:
            self.sock.setblocking(0)
        t = _time.time()
        # def list p = []
        self.fileno = fd
        self.last_send_time = t
        self.last_recv_time = t
        self.connect_time = t
        self.clientid = -1
        self.attributes = []
        self.name = ''
        self.recognition = -1  # 1-tml,2-data,3-client,4-sdcmp,5-fwdcs,6-upgrade
        self.wait4send = None
        self.guardtime = 0
        self.address = address
        self.ip_int = ip2int(address[0])
        self.temp_recv_buffer = ''
        self.nothing_to_send = 1
        self.server_port = serverport
        self.gps = (0.0, 0.0)  # 经度 纬度
        SEND_QUEUE[self.fileno] = PriorityQueue()
        self.debug = debug
        CLIENTS[self.fileno] = self
        register(self.fileno, READ)
        self.onSessionConnect()

    def onSessionConnect(self):
        """
        连接，say hello
        """
        self.sock.send('hello')

    def onSessionClose(self, closereason):
        """
        再见

        Args:
            closereason (str): _socket关闭原因
        """
        pass

    def onSessionSend(self):
        """
        数据发送
        """
        self.sock.send(self.wait4send)

    def onSessionRecv(self, recbuff):
        """
        数据接收处理

        Args:
            recbuff (str): 收到的数据
        """
        global SEND_QUEUE, CLIENTS
        for k in CLIENTS.keys():
            SEND_QUEUE[k].put_now(recbuff)

    def setDebug(self, showdebug=0):
        """Summary

        Args:
            showdebug (bool, optional): 设置是否输出调试信息标志位
        """
        self.debug = showdebug

    def showDebug(self, msg):
        """
        显示调试信息

        Args:
            msg (str): 调试信息内容
        """
        if self.debug:
            print("[D] {0} {1}".format(stamp2time(_time.time()), repr(msg)))

    def setName(self):
        """
        设置_socket连接名称
        """
        pass

    def fuzzyQueryProperty(self, attribute):
        """
        模糊查询客户端是否包含相关属性

        Args:
            attribute (str): 自定义_socket属性

        Returns:
            int: 0-不包含属性，1-包含属性
        """
        for pro in self.attributes:
            if pro.find(attribute) > -1:
                return 1
        return 0

    def queryProperty(self, attribute):
        """
        检查客户端是否包含相关属性

        Args:
            attribute (TYPE): 自定义_socket属性

        Returns:
            int: 0-不包含属性，1-包含属性
        """
        if attribute in self.attributes:
            return 1
        return 0

    def setRecognition(self, recbuff):
        """
        设置客户端识别码

        Args:
            recbuff (str): 接收到的数据
        """
        pass

    def setProperty(self, attribute):
        """
        设置客户端属性

        Args:
            attribute (str): 设置自定义_socket属性
        """
        if attribute not in self.attributes:
            self.attributes.append(attribute)

    def disconnect(self, closereason=''):
        """
        断开客户端_socket

        Args:
            closereason (str, optional): _socket关闭原因
        """
        global CLIENTS, SEND_QUEUE
        try:
            del SEND_QUEUE[self.fileno]
        except:
            pass
        try:
            unregister(self.fileno)
        except:
            pass
        try:
            self.sock.close()
        except:
            pass
        try:
            del CLIENTS[self.fileno]
        except:
            pass
        self.showDebug("close: {0}".format(closereason))
        self.onSessionClose(closereason)

    def checkTimeout(self, now, timeout):
        """
        检查是否超时以及发送ka

        Args:
            now (double): 当前时间，_time.time()格式
            timeout (double): 超时时间，_time.time()格式
        """
        global SEND_QUEUE
        # 检查超时
        if now - self.last_recv_time > timeout and SEND_QUEUE[self.fileno].empty():
            self.disconnect('timeout')
            return

        if self.recognition == -1 and now - self.last_send_time > 60 and SEND_QUEUE[
                self.fileno].empty():
            self.disconnect('unregistered connection')
            return

    def isNothingSend(self):
        """
        检查发送队列是否为空
        """
        return self.nothing_to_send

    def enableSend(self):
        """
        检查是否允许发送

        Returns:
            int: 0-不可以发送，1-可以发送
        """
        global READ

        t = _time.time()
        if (t - self.last_send_time) * 1000 >= self.guardtime:
            self.setWaitForSend()
            if self.wait4send is None:
                modify(self.fileno, READ)
                return 0
            else:
                return 1
        else:
            return 0

    def setWaitForSend(self):
        """
        缓存要发送的消息
        """
        global SEND_QUEUE
        if self.wait4send is None:
            senddata = None
            if not SEND_QUEUE[self.fileno].empty():
                senddata = SEND_QUEUE[self.fileno].get_nowait()[1]
            self.nothing_to_send = senddata is None

            self.wait4send = senddata
            del senddata

    def send(self):
        """
        发送数据
        """
        # self.last_send_time = _time.time()
        self.showDebug("send:{0}".format(self.wait4send))

        if self.debug:
            self.onSessionSend()
        else:
            try:
                self.onSessionSend()
            except Exception as ex:
                print(ex)

        if SEND_QUEUE[self.fileno].empty():
            modify(self.fileno, READ)

    def receive(self):
        """
        接收数据
        """
        recbuff = ""
        try:
            recbuff = self.sock.recv(8192)
        except Exception as ex:
            self.showDebug("recerr:{0}:{1}".format(ex.message, recbuff))
            self.disconnect('socket recv error')
            return 0

        # 客户端断开
        if len(recbuff) == 0:
            self.disconnect('client close')
            return 0

        t = _time.time()
        self.last_recv_time = t
        # 加入上次未完成解析的数据
        if len(self.temp_recv_buffer) > 0:
            recbuff = self.temp_recv_buffer + recbuff
            self.temp_recv_buffer = ''

        self.showDebug("recv:{0}".format(recbuff))

        if self.debug:
            self.onSessionRecv(recbuff)
        else:
            try:
                self.onSessionRecv(recbuff)
            except Exception as ex:
                print(ex)

        if not SEND_QUEUE[self.fileno].empty():
            modify(self.fileno, WRITE)


class MXIOLoop(object):

    def __init__(self, maxclient=1900, eventtimeout=0, maxevents=5000, fdlock=0):
        """高性能TCP服务基类

        Args:
            maxclient (TYPE): 最大客户端数量
            event_timeout (TYPE): 事件监听超时
            maxevents (TYPE): 最大一次性处理事件数量
            fdlock (TYPE): fd锁
        """
        self.debug = 0
        self.event_timeout = eventtimeout
        self.max_events = maxevents
        self.fd_lock = fdlock
        self.max_client = maxclient
        self.server_fd = {}

    def setDebug(self, showdebug):
        """
        设置调试信息开关

        Args:
            showdebug (int): 设置是否显示调试信息标志位
        """
        self.debug = showdebug

    def showDebug(self, msg):
        """
        是否显示调试信息

        Args:
            msg (str): 调试信息内容
        """
        if self.debug:
            print("[D] {0} {1}".format(stamp2time(_time.time()), repr(msg)))

    def addSocket(self, address):
        """
        添加需要监听的socket参数

        Args:
            address (tuple): ('ip', port)
        """
        global CLIENTS, READ
        sock = _socket.socket(_socket.AF_INET, _socket.SOCK_STREAM)
        sock.setblocking(0)
        # if Platform.isWin():
        sock.setsockopt(_socket.SOL_SOCKET, _socket.SO_REUSEADDR, 1)
        sock.setsockopt(_socket.IPPROTO_TCP, _socket.TCP_NODELAY, 1)
        try:
            sock.bind(address)
            self.showDebug("======= Success bind port:{0} =======".format(address[1]))
            if Platform.isWin():
                register(sock.fileno(), READ, sock)
            else:
                register(sock.fileno(), READ)
            self.server_fd[sock.fileno()] = (sock, address[1])
            # CLIENTS[address[1]] = []
            return sock
        except Exception as ex:
            print(u'------- Bind port {0} failed {1} -------'.format(address[1], ex))
            return None

    def serverForever(self):
        """
        启动服务
        """
        if Platform.isLinux():
            self.epollLoop()
        else:
            self.selectLoop()

    def doSomethingElse(self):
        """
        处理完内核通知后，继续处理其他事件
        """
        pass

    def connect(self, server_object):
        """
        处理连接请求

        Args:
            serversocket (tuple, (fileno, port)): 所有监听服务的_socket实例 or fileno
        """
        global CLIENTS
        connection, address = server_object[0].accept()
        if len(CLIENTS) < self.max_client:
            # 初始化客户端session
            ClientSession(connection, connection.fileno(), address, server_object[1], self.debug)
            self.showDebug("conn: {0}".format(address))
        else:
            connection.close()
            self.showDebug("conn: no more {0}".format(address))

    def epollMainLoop(self, fd, eve, debug=0):
        """
        主循环

        Args:
            fd (TYPE): file descriptor
            eve (TYPE): 事件
            fdlock (bool, optional): 是否加锁
            debug (bool, optional): 是否输出调试信息
        """
        if debug:
            self.epollWorker(fd, eve)
        else:
            try:
                self.epollWorker(fd, eve)
            except Exception as ex:
                self.showDebug("main loop error:{0}".format(ex.message))

    def selectMainLoop(self, fd, eve, debug=0):
        """
        主循环

        Args:
            fd (TYPE): file descriptor
            eve (TYPE): 事件
            fdlock (bool, optional): 是否加锁
            debug (bool, optional): 是否输出调试信息
        """
        if debug:
            self.selectWorker(fd, eve)
        else:
            try:
                self.selectWorker(fd, eve)
            except Exception as ex:
                self.showDebug("main loop error:{0}".format(ex.message))

    def selectWorker(self, fn, eve):
        """
        事件分类处理

        Args:
            fn (TYPE): file descriptor
            eve (TYPE): 事件
        """
        global CLIENTS
        # socket状态错误
        if eve == 'err':
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if session is not None:
                    session.disconnect('socket err')
                del session
        # socket 有数据读
        elif eve == 'in':
            if fn in self.server_fd.keys():
                self.connect(self.server_fd.get(fn))
            else:
                if fn in CLIENTS.keys():
                    session = CLIENTS.get(fn)
                    if session is not None:
                        session.receive()
                    del session
        # socket 可写
        elif eve == 'out':
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if session is not None:
                    if session.enableSend():
                        session.send()
                del session

    def epollWorker(self, fn, eve):
        """
        事件分类处理

        Args:
            fn (TYPE): file descriptor
            eve (TYPE): 事件
        """
        global CLIENTS
        # 对方socket非法关闭
        if eve & _select.EPOLLHUP:
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if session is not None:
                    session.disconnect('socket hup')
                del session
        # socket状态错误
        elif eve & _select.EPOLLERR:
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                session.disconnect('socket error')
                del session
        # socket 有数据读
        elif eve & _select.EPOLLIN:
            if fn in self.server_fd.keys():
                self.connect(self.server_fd.get(fn))
            else:
                if fn in CLIENTS.keys():
                    session = CLIENTS.get(fn)
                    if session is not None:
                        session.receive()
                    del session
        # socket 可写
        elif eve & _select.EPOLLOUT:
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if session is not None:
                    if session.enableSend():
                        session.send()
                del session

    def epollLoop(self):
        global IMPL
        if not __license_ok():
            return

        for s in self.server_fd.values():
            s[0].listen(100)

        # file descriptor事件监听
        t = _time.time()
        last_gc = t
        last_lic = t
        while not IS_EXIT:
            _gevent.sleep(0)

            try:
                # 获取事件
                events = IMPL.poll(timeout=self.event_timeout, maxevents=self.max_events)
            except Exception as ex:
                print(ex)
                continue

            if len(events) > 0:
                _gevent.joinall([_gevent.spawn(self.epollMainLoop, fileno, event, debug=self.debug)
                                 for fileno, event in events])

            self.doSomethingElse()

            t = _time.time()
            # 资源回收
            if t - last_gc > 600:
                _gc.collect()
                last_gc = _time.time()
                self.showDebug("gc")
            # 许可证检查
            if t - last_lic > 86400:
                last_lic = _time.time()
                if not __license_ok():
                    return

    def selectLoop(self):
        global READ, WRITE
        if not __license_ok():
            return

        for s in self.server_fd.values():
            s[0].listen(100)

        cdef double t = _time.time()
        cdef double last_gc = t
        cdef double last_lic = t

        while not IS_EXIT:
            _gevent.sleep(0)

            wr = [READ[i:i + 500] for i in range(0, len(READ), 500)]
            ww = [WRITE[i:i + 500] for i in range(0, len(WRITE), 500)]
            for i in range(len(wr) - len(ww)):
                ww.append([])
            l = len(wr)
            inbuf = []
            outbuf = []
            errbuf = []
            for i in range(l):
                try:
                    inb, outb, errb = _select.select(wr[i], ww[i], wr[i], 0)
                except Exception as ex:
                    print(ex)
                    # with open('select_error.log', 'a') as f:
                    #     f.writelines(['======{0}======='.format(stamp2time(_time.time())), ex, '\r\n'])
                    continue
                inbuf.extend(inb)
                outbuf.extend(outb)
                errbuf.extend(errb)
                del inb, outb, errb
            del wr, ww
            # inbuf, outbuf, errbuf = select.select(READ, WRITE, READ, 10)

            if len(errbuf) > 0:
                threads = []
                for soc in errbuf:
                    try:
                        inbuf.remove(soc)
                    except:
                        pass
                    try:
                        outbuf.remove(soc)
                    except:
                        pass
                    try:
                        threads.append(_gevent.spawn(self.selectMainLoop, soc.fileno(), 'err', debug=self.debug))
                    except:
                        pass
                _gevent.joinall(threads)
                del threads

            threads = []
            if len(inbuf) > 0:
                threads.extend([_gevent.spawn(self.selectMainLoop, soc.fileno(), 'in', debug=self.debug) for soc in inbuf])
                # threads = []
                # for soc in inbuf:
                #     try:
                #         threads.append(_gevent.spawn(self.main_loop, soc.fileno(), 'in', debug=self.debug))
                #     except:
                #         pass

            if len(outbuf) > 0:
                threads.extend([_gevent.spawn(self.selectMainLoop, soc.fileno(), 'out', debug=self.debug) for soc in outbuf])
                # threads = []
                # for soc in outbuf:
                #     try:
                #         threads.append(_gevent.spawn(self.main_loop, soc.fileno(), 'out', debug=self.debug))
                #     except:
                #         pass
            del inbuf, outbuf, errbuf

            thread = [threads[i:i + self.max_events] for i in range(0, len(threads), self.max_events)]
            for x in thread:
                _gevent.joinall(x)
            # _gevent.joinall(threads)
            del threads
            del thread

            # _gevent.sleep(0.1)

            self.doSomethingElse()

            # 资源回收
            t = _time.time()
            if t - last_gc > 600:
                _gc.collect()
                last_gc = t
                self.showDebug("gc")
            # 许可证检查
            if t - last_lic > 86400:
                last_lic = t
                if not __license_ok():
                    return
