# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'High-performance socket service'

try:
    import stackless as _sl
    USE_SL = True
except:
    import gevent as _gevent
    USE_SL = False
import socket as _socket
from mxpsu import PriorityQueue, SCRIPT_DIR, stamp2time, ip2int
from mxhpss_comm import load_license
import select as _select
import time as _time
import gc as _gc
import os as _os

# Linux EPOLL用常量
READ_ONLY = (_select.EPOLLIN | _select.EPOLLHUP | _select.EPOLLERR)
READ_WRITE = (READ_ONLY | _select.EPOLLOUT)
WRITE_ONLY = (_select.EPOLLOUT | _select.EPOLLHUP | _select.EPOLLERR)

IS_EXIT = 0
# 客户端集合{fileno, ClientSession}
CLIENTS = {}
# 发送队列{fd, SendData}
SEND_QUEUE = {}
# epoll实例
EPOLL = _select.epoll()


cdef int __license_ok():
    """
    许可证检查

    Returns:
        int: 0-许可证无效，1-许可证有效
    """
    cdef str a = load_license(_os.path.join(SCRIPT_DIR, 'LICENSE'))
    if 'err' in a:
        print(a)
        return 0
    else:
        return 1


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
    cdef public int fileno, clientid, recognition, guardtime, nothing_to_send, server_port, debug
    cdef public str name, temp_recv_buffer
    cdef public double last_send_time,last_recv_time,connect_time
    cdef public tuple address, gps
    cdef public long ip_int
    cdef list property
    def __init__(self, object sock, int fd, tuple address, int serverport, int debug=0):
        """ 初始化 socket client 实例

        Args:
            sock (socket): _socket实例
            fd (int): file descriptor
            address (tuple): (ip,port)
            serverport (int): 本地监听端口
            debug (int): 是否输出调试信息
        """
        global EPOLL, SEND_QUEUE, CLIENTS
        self.sock = sock
        if self.sock is not None:
            self.sock.setblocking(0)
        cdef double t = _time.time()
        # cdef list p = []
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
        self.ip_int = ip2int(address[0])
        self.temp_recv_buffer = ''
        self.nothing_to_send = 1
        self.server_port = serverport
        self.gps = (0.0, 0.0)  # 经度 纬度
        SEND_QUEUE[self.fileno] = PriorityQueue()
        self.debug = debug
        CLIENTS[self.fileno] = self
        EPOLL.register(self.fileno, READ_ONLY)
        self.on_session_connect()

    cpdef on_session_connect(self):
        """
        连接，say hello
        """
        pass

    cpdef on_session_close(self, str closereason):
        """
        再见

        Args:
            closereason (str): _socket关闭原因
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
            recbuff (str): 收到的数据
        """
        pass

    cdef set_debug(self, int showdebug=0):
        """Summary

        Args:
            showdebug (bool, optional): 设置是否输出调试信息标志位
        """
        self.debug = showdebug

    cpdef show_debug(self, str msg):
        """
        显示调试信息

        Args:
            msg (str): 调试信息内容
        """
        if self.debug:
            print("D", msg)

    cpdef set_name(self):
        """
        设置_socket连接名称
        """
        pass

    cpdef int fuzzy_query_property(self, str identity):
        """
        模糊查询客户端是否包含相关属性

        Args:
            identity (str): 自定义_socket属性

        Returns:
            int: 0-不包含属性，1-包含属性
        """
        for pro in self.property:
            if pro.find(identity) > -1:
                return 1
        return 0

    cpdef int get_property(self, str identity):
        """
        检查客户端是否包含相关属性

        Args:
            identity (TYPE): 自定义_socket属性

        Returns:
            int: 0-不包含属性，1-包含属性
        """
        if identity in self.property:
            return 1
        return 0

    cpdef set_recognition(self, str recbuff):
        """
        设置客户端识别码

        Args:
            recbuff (str): 接收到的数据
        """
        pass

    cpdef set_session_property(self, str identity):
        """
        设置客户端属性

        Args:
            identity (str): 设置自定义_socket属性
        """
        if not identity in self.property:
            self.property.append(identity)

    cdef set_client_id(self, int nid):
        """
        设置客户端id

        Args:
            nid (int): 设备地址
        """
        self.clientid = nid

    cdef set_last_send_time(self, int itime):
        """
        设置最后发送时间

        Args:
            itime (int): 设置最新发送时间（long）
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
            now (double): 当前时间，_time.time()格式
            timeout (double): 超时时间，_time.time()格式
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

        Returns:
            int: 0-不可以发送，1-可以发送
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

        if self.debug:
            self.on_session_recv(recbuff)
        else:
            try:
                self.on_session_recv(recbuff)
            except Exception as ex:
                print(ex)


cdef class EPSocketServer:
    cdef public int debug, event_timeout, max_events, fd_lock, max_client
    cdef public dict server_fd
    def __init__(self, int maxclient, int eventtimeout, int maxevents, int fdlock):
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
        # self.server_sock = None
        self.server_fd = {}


    cpdef set_debug(self, int showdebug):
        """
        设置调试信息开关

        Args:
            showdebug (int): 设置是否显示调试信息标志位
        """
        self.debug = showdebug


    cpdef show_debug(self, str msg):
        """
        是否显示调试信息

        Args:
            msg (str): 调试信息内容
        """
        if self.debug:
            print("D", msg)


    cpdef object add_socket(self, tuple address):
        """
        添加需要监听的socket参数

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
            EPOLL.register(sock.fileno(), READ_ONLY)
            self.server_fd[sock.fileno()] = (sock, address[1])
            # CLIENTS[address[1]] = []
            return sock
        except Exception as ex:
            print(u'------- Bind port {0} failed {1} -------'.format(address[1], ex))
            return None


    cpdef server_forever(self):
        """
        启动服务
        """
        global EPOLL
        if not __license_ok():
            return

        for s in self.server_fd.values():
            s[0].listen(100)

        if USE_SL:
            self.show_debug('running in stackless mode.')
        else:
            self.show_debug('running in gevent mode.')

        # file descriptor事件监听
        cdef double t = _time.time()
        cdef double last_gc = t
        cdef double last_lic = t
        while not IS_EXIT:
            if USE_SL:
                _time.sleep(0)
            else:
                _gevent.sleep(0)

            try:
                # 获取事件
                events = EPOLL.poll(timeout=self.event_timeout, maxevents=self.max_events)
            except Exception as ex:
                print(ex)
                continue

            if len(events) > 0:
                # gevent 和 stackless 不同模式协程开启
                if USE_SL:
                    for fileno, event in events:
                        try:
                            _sl.tasklet(self.main_loop)(fileno, event, self.debug)
                        except:
                            pass
                    _sl.run()
                else:
                    _gevent.joinall([_gevent.spawn(self.main_loop, fileno, event, self.debug) for fileno, event in events])

            self.do_something_after_events()

            t = _time.time()
            # 资源回收
            if t - last_gc > 600:
                _gc.collect()
                last_gc = _time.time()
                self.show_debug("gc")
            # 许可证检查
            if t - last_lic > 86400:
                last_lic = _time.time()
                if not __license_ok():
                    return

    cpdef do_something_after_events(self):
        """
        处理完内核通知后，继续处理其他事件
        """
        pass

    cpdef connection_request(self, tuple server_object):
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
            debug (bool, optional): 是否输出调试信息
        """
        if debug:
            self.worker(fd, eve)
        else:
            try:
                self.worker(fd, eve)
            except Exception as ex:
                self.show_debug("main loop error:{0}".format(ex.message))


    cdef worker(self, int fn, object eve):
        """
        事件分类处理

        Args:
            fn (TYPE): file descriptor
            eve (TYPE): 事件
        """
        global CLIENTS
        if 1:
            # 对方socket非法关闭
            if eve & _select.EPOLLHUP:
                if fn in CLIENTS.keys():
                    session = CLIENTS.get(fn)
                    if session is not None:
                        session.disconnect('_socket hup')
                    del session
            # socket状态错误
            elif eve & _select.EPOLLERR:
                if fn in CLIENTS.keys():
                    session = CLIENTS.get(fn)
                    session.disconnect('_socket error')
                    del session
            # socket 有数据读
            elif eve & _select.EPOLLIN:
                if fn in self.server_fd.keys():
                    self.connection_request(self.server_fd.get(fn))
                else:
                    if fn in CLIENTS.keys():
                        session = CLIENTS.get(fn)
                        if session is not None:
                            session.receive_data()
                        del session
            # socket 可写
            elif eve & _select.EPOLLOUT:
                if fn in CLIENTS.keys():
                    session = CLIENTS.get(fn)
                    if session is not None:
                        if session.enable_send():
                            session.send_data()
                    del session
