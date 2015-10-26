#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'epoll socket server'

import gevent as _gevent
import socket as _socket
from mxpsu import PriorityQueue, load_license
import select as _select
import time as _time
import gc as _gc

# Linux EPOLL用常量
READ_ONLY = (_select.EPOLLIN | _select.EPOLLHUP | _select.EPOLLERR)
READ_WRITE = (READ_ONLY | _select.EPOLLOUT)
WRITE_ONLY = (_select.EPOLLOUT | _select.EPOLLHUP | _select.EPOLLERR)

IS_EXIT = 0
# 客户端集合{fileno, ClientSession}
CLIENTS = {}
# file descriptor lock
FD_LOCK = []
# 发送队列{fd, SendData}
SEND_QUEUE = {}
# epoll实例
EPOLL = _select.epoll()
# bind _socket fd
SERVER_FD = {}


cdef int __license_ok():
    cdef str a = load_license()
    if 'err' in a:
        print(a)
        return 0
    else:
        return 1


cdef class SendData:
    cdef public str cmd, senddata
    cdef public int guardtime, loglevel, wait4ans, pri, dtype
    def __init__(self, senddata, guardtime=0, loglevel=20, cmd='', wait4ans=0, pri=5, dtype=0):
        """发送数据包实例

        Args:
            senddata (TYPE): 发送消息内容
            guardtime (int, optional): 发送消息保护时间
            loglevel (int, optional): 消息日志等级
            cmd (str, optional): 消息指令
            wait4ans (bool, optional): 是否等待应答
            pri (int, optional): 消息优先级
            dtype (int，optional): 数据发送类型0-hex，1-ascii
        Returns:
            TYPE: Description
        """
        self.cmd = cmd
        self.senddata = senddata
        self.guardtime = int(guardtime)
        self.wait4ans = wait4ans
        self.loglevel = int(loglevel)
        self.pri = pri
        self.dtype = dtype


cdef class ClientSession:
    cdef public object sock
    cdef public int fd, serverport, debug
    cdef public tuple address
    def __init__(self, object sock, int fd, tuple address, int serverport, int debug=0):
        """_socket client 实例

        Args:
            sock (TYPE): _socket实例
            fd (TYPE): file descriptor
            address (TYPE): (ip,port)
            serverport (TYPE): 本地监听端口
            # socktimeout (TYPE): _socket接收超时时间
        """
        global EPOLL, SEND_QUEUE
        self.sock = sock
        if self.sock is not None:
            self.sock.setblocking(0)
        cdef float t = _time.time()
        cdef list p = []
        self.fileno = fd
        self.last_send_time = t
        self.last_recv_time = t
        self.connect_time = t
        self.clientid = -1
        self.property = p
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

    cpdef get_property(self, int identity):
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

    cpdef set_session_property(self, int identity):
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
        global EPOLL, CLIENTS, SEND_QUEUE, FD_LOCK
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
            FD_LOCK.remove(self.fileno)
        except:
            pass
        try:
            del CLIENTS[self.fileno]
        except:
            pass
        self.show_debug("client close: {0}".format(closereason))
        self.on_session_close(closereason)

    cpdef check_timeout(self, float now, int timeout):
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

    cdef enable_send(self):
        """
        检查是否允许发送
        """
        global EPOLL, READ_ONLY
        if (_time.time() - self.last_send_time) * 1000 >= self.guardtime:
            self.set_wait_for_send()
            if self.wait4send is None:
                EPOLL.modify(self.fileno, READ_ONLY)
                return 0
            else:
                return 1
        else:
            return 0

    cdef set_wait_for_send(self):
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

    cdef send_data(self):
        """
        发送数据
        """
        # self.last_send_time = _time.time()
        self.show_debug("send:".format(self.wait4send))
        self.on_session_send()

    cdef receive_data(self):
        """
        接收数据
        """
        cdef str recbuff = ""
        try:
            recbuff = self.sock.recv(8192)
        except Exception as ex:
            self.show_debug("ErrRecv:{0}:{1}".format(ex.message, recbuff))
            self.disconnect('_socket recv error')
            return 0
        # 客户端断开
        if len(recbuff) == 0:
            self.disconnect('client close')
            return 0

        self.last_recv_time = _time.time()
        # 加入上次未完成解析的数据
        if len(self.temp_recv_buffer) > 0:
            recbuff = self.temp_recv_buffer + recbuff
            self.temp_recv_buffer = ''

        self.show_debug("DebugRec:{0}".format(recbuff))

        self.on_session_recv(recbuff)


cdef class EpollSocketServer:
    cdef public int debug, server_port, event_timeout, max_events, fd_lock, max_client, server_fd
    cdef public object server_sock
    def __init__(self, int serverport, int maxclient, int eventtimeout, int maxevents, int fdlock):
        """高性能TCP服务基类

        Args:
            serverport (TYPE): 监听端口
            maxclient (TYPE): 最大客户端数量
            event_timeout (TYPE): 事件监听超时
            maxevents (TYPE): 最大一次性处理事件数量
            fdlock (TYPE): fd锁

        Returns:
            TYPE: Description
        """
        self.debug = 0
        self.server_port = serverport
        self.event_timeout = eventtimeout
        self.max_events = maxevents
        self.fd_lock = fdlock
        self.max_client = maxclient
        self.server_sock = None
        self.server_fd = 0

    cdef set_debug(self, int showdebug):
        """
        设置调试信息开关

        Args:
            showdebug (TYPE): 设置是否显示调试信息标志位
        """
        self.debug = showdebug

    cdef show_debug(self, str msg):
        """
        是否显示调试信息

        Args:
            msg (TYPE): 调试信息内容
        """
        if self.debug:
            print("D", msg)

    cpdef server_forever(self):
        """
        启动服务
        """
        global EPOLL, SERVER_FD

        if not __license_ok():
            return

        # 开始监听
        self.server_sock = _socket.socket(_socket.AF_INET, _socket.SOCK_STREAM)
        self.server_sock.setblocking(0)
        self.server_sock.setsockopt(_socket.SOL_SOCKET, _socket.SO_REUSEADDR, 1)
        self.server_sock.setsockopt(_socket.IPPROTO_TCP, _socket.TCP_NODELAY, 1)

        try:
            self.server_sock.bind(("0.0.0.0", int(self.server_port)))
        except Exception as ex:
            print(u'------- Bind port {0} failed {1} -------'.format(self.server_port, ex))
            exit(1)
        # self.server_sock.bind(("0.0.0.0", int(self.server_port)))
        self.server_sock.listen(200)
        self.show_debug("======= Success listening port:{0} =======".format(self.server_port))
        self.server_fd = self.server_sock.fileno()
        EPOLL.register(self.server_fd, READ_ONLY)
        SERVER_FD[self.server_fd] = self.server_sock

        # file descriptor事件监听
        cdef float t = _time.time()
        cdef float last_gc = t
        cdef float last_lic = t
        while not IS_EXIT:
            events = EPOLL.poll(timeout=self.event_timeout, maxevents=self.max_events)
            if len(events) > 0:
                threads = []
                for fileno, event in events:
                    # _gevent.spawn(main_loop, fileno, event)
                    # main_loop(fileno, event)
                    try:
                        self.main_loop(fileno, event, self.fd_lock, self.debug)
                        threads.append(_gevent.spawn(self.main_loop, fileno, event, self.fd_lock, self.debug))
                        # sl.tasklet(self.main_loop)(fileno, event, self.fd_lock, self.debug)
                    except:
                        pass
                # sl.run()
                _gevent.joinall(threads)
                del threads

            self.do_something_after_events()

            if t - last_gc > 600:
                _gc.collect()
                last_gc = _time.time()
                self.show_debug("gc")

            if t - last_lic > 86400:
                last_lic = _time.time()
                if not __license_ok():
                    return

    cpdef do_something_after_events(self):
        """
        处理主循环中额外事件
        """
        pass

    cpdef connection_request(self, object serversocket):
        """
        处理连接请求

        Args:
            serversocket (TYPE): 监听服务_socket实例
        """
        global CLIENTS
        connection, address = serversocket.accept()
        if len(CLIENTS) < self.max_client:
            ClientSession(connection, connection.fileno(), address, self.server_port, self.debug)
            # session_in = ClientSession(connection, connection.fileno(), address, SERVER_PORT)
            # EPOLL.register(connection.fileno(), READ_WRITE)
            # CLIENTS[connection.fileno()] = session_in
            self.show_debug("Session connecte from: {0}".format(address))
        else:
            connection.close()
            self.show_debug("No more connection: {0}".format(address))

    cpdef main_loop(self, int fd, object eve, int fdlock=1, int debug=0):
        """
        主循环

        Args:
            fd (TYPE): file descriptor
            eve (TYPE): 事件
            fdlock (bool, optional): 是否加锁
            debug (bool, optional): 是否调试模式
        """
        global FD_LOCK

        if fdlock:
            while fd in FD_LOCK:
                # sl.schedule()
                _gevent.sleep(0)
            FD_LOCK.append(fd)

        if debug:
            self.worker(fd, eve)
        else:
            try:
                self.worker(fd, eve)
            except Exception as ex:
                self.show_debug("main loop error:{0}".format(ex.message))

        if fdlock:
            try:
                FD_LOCK.remove(fd)
            except:
                pass

    cdef worker(self, int fn, object eve):
        """
        事件分类处理

        Args:
            fn (TYPE): file descriptor
            eve (TYPE): 事件
        """
        global CLIENTS
        if 1:
            if eve & _select.EPOLLHUP:
                if fn in CLIENTS.keys():
                    session_close = CLIENTS[fn]
                    session_close.disconnect('_socket hup')
                    del session_close
            elif eve & _select.EPOLLERR:
                if fn in CLIENTS.keys():
                    session_close = CLIENTS[fn]
                    session_close.disconnect('_socket error')
                    del session_close
            elif eve & _select.EPOLLIN:
                if fn in SERVER_FD.keys():
                    self.connection_request(SERVER_FD.get(fn))
                else:
                    if fn in CLIENTS.keys():
                        session_in = CLIENTS[fn]
                        session_in.receive_data()
                        del session_in
                        # if session_out.recive_data():
                        # EPOLL.modify(fileno, READ_WRITE)
                        # CLIENTS[fn] = session_out
            elif eve & _select.EPOLLOUT:
                if fn in CLIENTS.keys():
                    session_out = CLIENTS[fn]
                    if session_out.enable_send():
                        session_out.send_data()
                    del session_out
                    # 判断Session中是否有wait4send的数据，没有则从队列取出放入
                    # session_out.set_wait_for_send()
                    # 判断是否允许发送，允许则发送，不允许则等待下一次触发
                    # if session_out.enable_send():
                    # session_out.send_data()
                    # if session_out.send_data():
                    # CLIENTS[fn] = session_out
