# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'High-performance socket service nt version'

try:
    import stackless as _sl
    USE_SL = True
except:
    import gevent as _gevent
    USE_SL = False
import socket as _socket
from mxpsu import PriorityQueue, load_license, SCRIPT_DIR, stamp2time
import select as _select
import time as _time
import gc as _gc
import os as _os

# Linux EPOLL用常量
READ_ONLY = []
READ_WRITE = []

IS_EXIT = 0
# 客户端集合{fileno, ClientSession}
CLIENTS = {}
# 发送队列{fd, SendData}
SEND_QUEUE = {}


cpdef int __license_ok():
    cdef str a = load_license(_os.path.join(SCRIPT_DIR, 'LICENSE'))
    if 'err' in a:
        print(a)
        return 0
    else:
        return 1


cdef class Epoll:
    cpdef register(self, int fileno, list lstwatch, object ssock=None):
        global READ_ONLY, READ_WRITE, CLIENTS
        if ssock is not None:
            READ_ONLY.append(ssock)
        else:
            sock = CLIENTS.get(fileno)
            if sock is not None:
                if lstwatch is READ_ONLY:
                    if sock.sock not in READ_ONLY:
                        READ_ONLY.append(sock.sock)
                elif lstwatch is READ_WRITE:
                    if sock.sock not in READ_WRITE:
                        READ_WRITE.append(sock.sock)


    cpdef modify(self, int fileno, list lstwatch):
        global READ_ONLY, READ_WRITE, CLIENTS
        sock = CLIENTS.get(fileno)
        if sock is not None:
            if lstwatch is READ_ONLY:
                try:
                    READ_WRITE.remove(sock.sock)
                except:
                    pass
            elif lstwatch is READ_WRITE:
                if sock.sock not in READ_WRITE:
                    READ_WRITE.append(sock.sock)


    cpdef unregister(self, int fileno):
        global READ_ONLY, READ_WRITE, CLIENTS
        sock = CLIENTS.get(fileno)
        if sock is not None:
            try:
                READ_ONLY.remove(sock.sock)
            except:
                pass
            try:
                READ_WRITE.remove(sock.sock)
            except:
                pass


# cpdef add_watch_write(object sock):
#     '''
#     加入读写集合
#     :param sock: socket
#     :return:
#     '''
#     global READ_WRITE
#     if sock in READ_WRITE:
#         return
#     READ_WRITE.append(sock)


# cpdef del_watch_write(object sock):
#     '''
#     从读写集合删除
#     :param sock: socket
#     '''
#     global READ_WRITE
#     try:
#         READ_WRITE.remove(sock)
#     except:
#         pass


EPOLL = Epoll()

# cdef class SendData:
#     cdef public str cmd, senddata
#     cdef public int guardtime, loglevel, wait4ans, pri, dtype
#     def __init__(self, senddata, guardtime=0, loglevel=20, cmd='', wait4ans=0, pri=5, dtype=0):
#         """发送数据包实例

#         Args:
#             senddata (TYPE): 发送消息内容
#             guardtime (int, optional): 发送消息保护时间
#             loglevel (int, optional): 消息日志等级
#             cmd (str, optional): 消息指令
#             wait4ans (bool, optional): 是否等待应答
#             pri (int, optional): 消息优先级
#             dtype (int，optional): 数据发送类型0-hex，1-ascii
#         Returns:
#             TYPE: Description
#         """
#         self.cmd = cmd
#         self.senddata = senddata
#         self.guardtime = int(guardtime)
#         self.wait4ans = wait4ans
#         self.loglevel = int(loglevel)
#         self.pri = pri
#         self.dtype = dtype


cdef class ClientSession:
    cdef public object sock, wait4send
    cdef public int fileno, clientid,  recognition, guardtime, nothing_to_send, server_port, debug
    cdef public str name, temp_recv_buffer
    cdef public double last_send_time,last_recv_time,connect_time
    cdef public tuple address
    cdef list property
    def __init__(self, object sock, int fd, tuple address, int serverport, int debug=0):
        """_socket client 实例

        Args:
            sock (TYPE): _socket实例
            fd (TYPE): file descriptor
            address (TYPE): (ip,port)
            serverport (TYPE): 本地监听端口
            # socktimeout (TYPE): _socket接收超时时间
        """
        global EPOLL, SEND_QUEUE, CLIENTS
        self.sock = sock
        if self.sock is not None:
            self.sock.setblocking(0)
        cdef double t = _time.time()
        self.fileno = fd
        self.last_send_time = t
        self.last_recv_time = t
        self.connect_time = t
        self.clientid = -1
        self.property = []
        self.name = ''
        self.recognition = -1  # 1-tml,2-data,3-client,4-sdcmp,5-fwdcs,6-upgrade
        self.wait4send = None
        self.guardtime = 0
        self.address = address
        self.temp_recv_buffer = ''
        self.nothing_to_send = 1
        self.server_port = serverport
        self.longitude = 0.0  # 经度
        self.latitude = 0.0  # 纬度
        SEND_QUEUE[self.fileno] = PriorityQueue()
        self.debug = debug
        CLIENTS[self.fileno] = self
        EPOLL.register(self.fileno, READ_ONLY)
        self.on_session_connect()

    cpdef on_session_connect(self):
        """
        发送欢迎词
        """
        pass

    cpdef on_session_close(self, str closereason):
        """
        再见

        Args:
            closereason (TYPE): _socket关闭原因
        """
        pass

    cpdef on_session_send(self):
        """
        数据发送
        """
        pass

    cpdef on_session_recv(self, str recbuff):
        """
        数据接收处理

        Args:
            recbuff (TYPE): 收到的数据
        """
        pass

    cdef set_debug(self, int showdebug=0):
        """Summary

        Args:
            showdebug (bool, optional): 设置是否显示调试信息标志位
        """
        self.debug = showdebug

    cpdef show_debug(self, str msg):
        """
        显示调试信息

        Args:
            msg (TYPE): 调试信息内容
        """
        if self.debug:
            print("D", msg)

    cpdef set_name(self):
        """
        设置_socket连接名称
        """
        pass

    cpdef int get_property(self, str identity):
        """
        检查客户端是否包含相关属性

        Args:
            identity (TYPE): 自定义_socket属性
        """
        if identity in self.property:
            return 1
        return 0

    cpdef set_recognition(self, str recbuff):
        """
        设置客户端识别码

        Args:
            recbuff (TYPE): 接收到的数据
        """
        pass

    cpdef set_session_property(self, str identity):
        """
        设置客户端属性

        Args:
            identity (TYPE): 自定义_socket属性
        """
        if not identity in self.property:
            self.property.append(identity)

    cdef set_client_id(self, int nid):
        """
        设置客户端id

        Args:
            nid (TYPE): 设备地址
        """
        self.clientid = nid

    cdef set_last_send_time(self, int itime):
        """
        设置最后发送时间

        Args:
            itime (TYPE): 时间（long）
        """
        self.last_send_time = itime

    cpdef disconnect(self, str closereason=''):
        """
        断开客户端_socket

        Args:
            closereason (str, optional): _socket关闭原因
        """
        global EPOLL, CLIENTS, SEND_QUEUE
        try:
            del SEND_QUEUE[self.fileno]
        except:
            pass
        try:
            EPOLL.unregister(self.fileno)
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
        self.show_debug("client close: {0}".format(closereason))
        self.on_session_close(closereason)

    cpdef check_timeout(self, double now, int timeout):
        """
        检查是否超时以及发送ka

        Args:
            now (TYPE): 当前时间，_time.time()格式
        """
        global SEND_QUEUE
        # 检查超时
        if now - self.last_recv_time > timeout and SEND_QUEUE[self.fileno].empty():
            self.disconnect('timeout')
            return

        if self.recognition == -1 and now - self.last_send_time > 60 and SEND_QUEUE[self.fileno].empty():
            self.disconnect('unregistered connection')
            return

    cdef is_nothing_to_send(self):
        """
        检查发送队列是否为空
        """
        return self.nothing_to_send

    cpdef int enable_send(self):
        """
        检查是否允许发送
        """
        global EPOLL, READ_ONLY

        cdef double t = _time.time()
        if (t - self.last_send_time) * 1000 >= self.guardtime:
            self.set_wait_for_send()
            if self.wait4send is None:
                EPOLL.modify(self.fileno, READ_ONLY)
                return 0
            else:
                return 1
        else:
            return 0

    cpdef set_wait_for_send(self):
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

    cpdef send_data(self):
        """
        发送数据
        """
        # self.last_send_time = _time.time()
        self.show_debug("send:".format(self.wait4send))
        self.on_session_send()

    cpdef receive_data(self):
        """
        接收数据
        """
        cdef str recbuff = ""
        try:
            recbuff = self.sock.recv(8192)
        except Exception as ex:
            self.show_debug("recerr:{0}:{1}".format(ex.message, recbuff))
            self.disconnect('_socket recv error')
            return 0

        # 客户端断开
        if len(recbuff) == 0:
            self.disconnect('client close')
            return 0

        cdef double t = _time.time()
        self.last_recv_time = t
        # 加入上次未完成解析的数据
        if len(self.temp_recv_buffer) > 0:
            recbuff = self.temp_recv_buffer + recbuff
            self.temp_recv_buffer = ''

        self.show_debug("rec:{0}".format(recbuff))

        self.on_session_recv(recbuff)


cdef class NTSocketServer:
    cdef public int debug, event_timeout, max_events, fd_lock, max_client
    cdef public dict server_fd
    def __init__(self, int maxclient, int eventtimeout, int maxevents, int fdlock):
        """高性能TCP服务基类

        Args:
            maxclient (TYPE): 最大客户端数量
            event_timeout (TYPE): 事件监听超时
            maxevents (TYPE): 最大一次性处理事件数量
            fdlock (TYPE): fd锁

        Returns:
            TYPE: Description
        """
        self.debug = 0
        self.event_timeout = eventtimeout
        self.max_events = maxevents
        self.fd_lock = fdlock
        self.max_client = maxclient
        # self.server_sock = None
        self.server_fd = {}


    cpdef set_debug(self, int showdebug):
        """
        设置调试信息开关

        Args:
            showdebug (TYPE): 设置是否显示调试信息标志位
        """
        self.debug = showdebug


    cpdef show_debug(self, str msg):
        """
        是否显示调试信息

        Args:
            msg (TYPE): 调试信息内容
        """
        if self.debug:
            print("D", msg)


    cpdef object add_socket(self, tuple address):
        """
        启动服务

        Args:
            address (tuple): ('ip', port)
        """
        global CLIENTS, READ_ONLY
        sock = _socket.socket(_socket.AF_INET, _socket.SOCK_STREAM)
        sock.setblocking(0)
        if _os.name == 'posix':
            sock.setsockopt(_socket.SOL_SOCKET, _socket.SO_REUSEADDR, 1)
        sock.setsockopt(_socket.IPPROTO_TCP, _socket.TCP_NODELAY, 1)
        try:
            sock.bind(address)
            self.show_debug("======= Success bind port:{0} =======".format(address[1]))
            EPOLL.register(sock.fileno(), READ_ONLY, sock)
            self.server_fd[sock.fileno()] = (sock, address[1])
            return sock
        except Exception as ex:
            print(u'------- Bind port {0} failed {1} -------'.format(address[1], ex))
            return None


    cpdef server_forever(self):
        # file descriptor事件监听
        global READ_ONLY, READ_WRITE
        if not __license_ok():
            return

        for s in self.server_fd.values():
            s[0].listen(100)

        cdef double t = _time.time()
        cdef double last_gc = t
        cdef double last_lic = t

        while not IS_EXIT:
            wr = [READ_ONLY[i:i + 500] for i in range(0, len(READ_ONLY), 500)]
            ww = [READ_WRITE[i:i + 500] for i in range(0, len(READ_WRITE), 500)]
            for i in range(len(wr) - len(ww)):
                ww.append([])
            l = len(wr)
            inbuf = []
            outbuf = []
            errbuf = []
            for i in range(l):
                try:
                    inb, outb, errb = _select.select(wr[i], ww[i], wr[i], 1)
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
                # inbuf, outbuf, errbuf = select.select(READ_ONLY, READ_WRITE, READ_ONLY, 10)

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
                        threads.append(_gevent.spawn(self.main_loop, soc.fileno(), 'err', debug=self.debug))
                    except:
                        pass
                _gevent.joinall(threads)
                del threads

            threads = []
            if len(inbuf) > 0:
                # threads = []
                for soc in inbuf:
                    try:
                        threads.append(_gevent.spawn(self.main_loop, soc.fileno(), 'in', debug=self.debug))
                    except:
                        pass
                # gevent.joinall(threads)
                # del threads

            if len(outbuf) > 0:
                # threads = []
                for soc in outbuf:
                    try:
                        threads.append(_gevent.spawn(self.main_loop, soc.fileno(), 'out', debug=self.debug))
                    except:
                        pass
                # gevent.joinall(threads)
                # del threads
            del inbuf, outbuf, errbuf

            thread = [threads[i:i + self.max_events] for i in range(0, len(threads), self.max_events)]
            for x in thread:
                _gevent.joinall(x)
            del thread, threads

            _gevent.sleep(0.1)

            self.do_something_after_events()

            t = _time.time()
            if t - last_gc > 600:
                _gc.collect()
                last_gc = t
                self.show_debug("gc")

            if t - last_lic > 86400:
                last_lic = t
                if not __license_ok():
                    return


    cpdef do_something_after_events(self):
        """
        处理主循环中额外事件
        """
        pass

    cpdef connection_request(self, tuple server_object):
        """
        处理连接请求

        Args:
            serversocket (TYPE): 监听服务_socket实例
        """
        global CLIENTS
        connection, address = server_object[0].accept()
        if len(CLIENTS) < self.max_client:
            ClientSession(connection, connection.fileno(), address, server_object[1], self.debug)
            # session_in = ClientSession(connection, connection.fileno(), address, SERVER_PORT)
            # EPOLL.register(connection.fileno(), READ_WRITE)
            # CLIENTS[connection.fileno()] = session_in
            self.show_debug("Session connecte from: {0}".format(address))
        else:
            connection.close()
            self.show_debug("No more connection: {0}".format(address))


    cpdef main_loop(self, int fd, object eve, int debug=0):
        """
        主循环

        Args:
            fd (TYPE): file descriptor
            eve (TYPE): 事件
            fdlock (bool, optional): 是否加锁
            debug (bool, optional): 是否调试模式
        """
        if debug:
            self.worker(fd, eve)
        else:
            try:
                self.worker(fd, eve)
            except Exception as ex:
                self.show_debug("main loop error:{0}".format(ex.message))


    cdef worker(self, int fn, str eve):
        """
        事件分类处理

        Args:
            fn (TYPE): file descriptor
            eve (TYPE): 事件
        """
        global CLIENTS
        if True:
            if eve == 'err':
                if fn in CLIENTS.keys():
                    session = CLIENTS.get(fn)
                    if session is not None:
                        session.disconnect('socket err')
                    del session
            elif eve == 'in':
                if fn in self.server_fd.keys():
                    self.connection_request(self.server_fd.get(fn))
                else:
                    if fn in CLIENTS.keys():
                        session = CLIENTS.get(fn)
                        if session is not None:
                            session.receive_data()
                        del session
            elif eve == 'out':
                if fn in CLIENTS.keys():
                    session = CLIENTS.get(fn)
                    if session is not None:
                        if session.enable_send():
                            session.send_data()
                    del session
