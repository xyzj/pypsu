#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""socket连接池，支持Linux，Windows
受windows平台影响，最大连接数为500

Attributes:
    LOG_POOL (logger): 日志实例
    READ (set): 只读socket对象集合
    WRITE (set): 读写socket对象集合
"""

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'socket-pool.py'

import Queue as _Queue
import select as _select
from mxpsu import PriorityQueue, AdvLogger, KEEP_ALIVE, stamp2time
from mxhpss_comm import IMPL, register, unregister, modify, READ, WRITE, _EPOLLIN, _EPOLLOUT, _EPOLLHUP, _EPOLLERR
import time as _time
import gc as _gc
import socket as _socket
from threading import Thread

LOG_POOL = None


class MXSPLoop(Thread):
    """socket连接池

    Attributes:
        impl: epoll or select 实例
        address (tuple): (str(ip), int(port))
        debug (bool): 是否输出调试信息
        free_clients (queue): socket pool
        max_idle (int): 最大常连接保持数量，默认1
        max_open (int): 池中最大socket实例数量，默认20,最大500
        max_recycle_sec (int): socket无发送回收时间，默认60s
        send_queue (queue): 发送队列
        working_clients (TYPE): Description
    """

    def __init__(self,
                 connect_address,
                 max_idle_connections=1,
                 max_open_connections=20,
                 max_recycle_sec=60,
                 debug=0,
                 logger=None):
        super(MXSPLoop, self).__init__()
        # 受windows平台影响，最大连接数为500
        if max_open_connections > 500:
            max_open_connections = 500
        # 常连接数量不能大于最大连接数
        if max_idle_connections > max_open_connections:
            max_idle_connections = max_open_connections

        self.address = connect_address
        self.max_idle = max_idle_connections
        self.max_open = max_open_connections
        self.max_recycle_sec = max_recycle_sec
        self.debug = debug
        self.send_queue = PriorityQueue()
        self.free_clients = _Queue.Queue()
        self.working_clients = set()
        if logger is not None:
            LOG_POOL = logger
        else:
            self.debug = 1

        t = _time.time()
        self.last_gc = t
        self.reconnect_sec = 15

        # 初始化连接池, 启动常连接
        for i in range(self.max_open):
            c = SocketSession(i, self.address, self.debug)
            if len(self.working_clients) < self.max_idle:
                c.connect()
                self.working_clients.add(c)
            else:
                self.free_clients.put_nowait(c)
            del c

    @staticmethod
    def instance():
        if not hasattr(IOLoop, "_instance"):
            if Platform.is_linux():
                IOLoop._instance = EPollIOLoop()
            elif Platform.is_mac():
                IOLoop._instance = KQueueIOLoop()
            else:
                IOLoop._instance = SelectIOLoop()
        return IOLoop._instance

    def stop(self):
        self.stop = True

    def recyle(self):
        self.reconnect_sec = 15
        if _time.time() - self.last_gc > 600:
            _gc.collect()

    def sendCycle(self):
        # 优先利用当前保持的连接
        if not self.send_queue.empty():
            for c in self.working_clients:
                if c.isNothingSend():
                    if not c.isConnected():
                        c.connect()
                    s = self.send_queue.get_nowait()[1]
                    c.setSendData(s)
                    del s
                if self.send_queue.empty():
                    break
        # 若连接池还有多余session，继续使用
        if not self.send_queue.empty():
            while not self.free_clients.empty():
                c = self.free_clients.get_nowait()
                c.connect()
                self.working_clients.add(c)
                s = self.send_queue.get_nowait()[1]
                c.setSendData(s)
                del s
                if self.send_queue.empty():
                    break

        if not self.send_queue.empty() and self.free_clients.empty():
            self.reconnect_sec = 0

        t = _time.time()
        x = self.working_clients.copy()
        for c in x:
            # 断线重连
            if not c.isNothingSend() and not c.isConnected(
            ) and t - c.lost_connect_time > self.reconnect_sec:
                c.connect()
                continue

            # 断开多余连接
            if self.getOnlineCount() > self.max_idle:
                if t - c.last_send_time > self.max_recycle_sec and c.isNothingSend():
                    c.clean()
                    self.free_clients.put(c)
                    self.working_clients.discard(c)
                    continue

    def setDebug(self, debug):
        """设置调试信息标识

        Args:
            debug (bool): 是否输出调试信息
        """
        self.debug = debug

    def _showDebug(self, msg, loglevel=20):
        """
        显示调试信息

        Args:
            msg (str): 调试信息内容
            loglevel (int, optional): 日志等级
        """
        writeLog(repr(msg), loglevel)
        if self.debug:
            print("[D] {0} {1}".format(stamp2time(_time.time()), repr(msg)))

    def expandPool(self, new_open_connections):
        """扩大连接池数量

        Args:
            new_open_connections (int): 新的池中最大socket实例数量，若小于当前数量则不操作

        Returns:
            int: 0-扩展失败，1-扩展成功
        """
        # 受windows平台影响，最大连接数为500
        if new_open_connections > 500:
            new_open_connections = 500
        # 新数量小于当前数量，不操作
        if new_open_connections < self.max_open:
            return 0

        for i in range(self.max_open, new_open_connections):
            c = SocketSession(i, self.address, self.debug)
            self.free_clients.put_nowait(c)

        self.max_open = new_open_connections
        return 1

    def addSendMsg(self, msg, pri=5):
        """向发送队列添加数据

        Args:
            msg (str): 发送的数据
            pri (int): 该数据优先级（1-9，高-低）
        """
        self.send_queue.put_now(msg, pri)
        self._showDebug('add to queue: {0}'.format(msg))

    def getStatus(self):
        """检查状态

        Returns:
            int: 0-所有连接均断开，可能服务错误或配置错误。1-至少有一个连接正常
        """
        status = 0
        for c in self.working_clients:
            if c.isConnected():
                status = 1
                break
        return status

    def getClient(self, fn):
        """查找socket对象对应的session

        Args:
            fn (socket): socket对象

        Returns:
            socket: socket对象
        """
        is_socket = lambda cls: isinstance(cls, _socket.socket)
        if is_socket(fn):
            for c in self.working_clients:
                if c.sock == fn:
                    return c
        else:
            for c in self.working_clients:
                if c.fileno == fn:
                    return c
        return None

    def getOnlineCount(self):
        """获取已连接的session数量

        Returns:
            int: 已连接的session数量
        """
        status = 0
        for c in self.working_clients:
            if c.isConnected():
                status += 1
        return status


class EPollLoop(MXSPLoop):

    def __init__(self):
        super(EPollLoop, self).__init__()

    def run(self):
        while not self.stop:
            try:
                poll_list = IMPL.poll()
            except Exception as ex:
                print(ex)
                continue

            if len(poll_list) > 0:
                for fileno, event in poll_list:
                    c = self.getClient(fileno)
                    if c is None:
                        unregister(soc)
                        continue
                    if event & _EPOLLERR:
                        c.disconnect('socket error')
                    elif event & _EPOLLHUP:
                        c.disconnect('socket hup')
                    elif event & _EPOLLOUT:
                        c.send()
                    elif event & _EPOLLIN:
                        c.receive()

            self.recyle()


class SelectLoop(MXSPLoop):

    def __init__(self):
        super(EPollLoop, self).__init__()

    def run(self):
        while not self.stop:
            try:
                inbuf, outbuf, errbuf = IMPL(READ, WRITE, READ, 0)
            except Exception as ex:
                print(ex)
                continue

            if len(errbuf) > 0:
                for soc in errbuf:
                    try:
                        inbuf.remove(soc)
                    except:
                        pass
                    try:
                        outbuf.remove(soc)
                    except:
                        pass

                    c = self.getClient(soc)
                    if c is None:
                        unregister(soc)
                        continue
                    c.disconnect('socket error')

            if len(inbuf) > 0:
                for soc in inbuf:
                    c = self.getClient(soc)
                    if c is None:
                        unregister(soc)
                        continue
                    c.receive()

            if len(outbuf) > 0:
                for soc in inbuf:
                    c = self.getClient(soc)
                    if c is None:
                        unregister(soc)
                        continue
                    c.send()
            del inbuf, outbuf, errbuf

            self.recyle()


def writeLog(logmsg, loglevel):
    """写日志

    Args:
        logmsg (str): 日志信息
        loglevel (int): 日志级别
    """
    global LOG_POOL
    if LOG_POOL is None:
        return
    logmsg = logmsg[1:len(logmsg) - 1]
    LOG_POOL.saveLog(logmsg, loglevel)


class SocketSession(object):
    """用于socket连接池的socket session

    Attributes:
        address (tuple): (str(ip), int(port))
        connect_fail_count (int): 连接失败次数
        connect_time (float): 连接成功时间
        connected (bool): 是否连接
        debug (bool): 是否输出调试信息
        fileno (int): 文件描述符
        idx (int): 标识号
        last_send_time (float): 最后依次发送时间
        lost_connect_time (float): 连接断开时间
        reconnect_timer (int): Description
        sock (socket): socket实例
        wait_send_data (str): 等待发送的数据
    """

    def __init__(self, idx, address, debug=0):
        """初始化

        Args:
            idx (int): 标识号
            address (tuple): (str(ip), int(port))
            debug (bool): 是否输出调试信息
        """
        self.idx = idx
        self.address = address
        self.connected = 0
        self.lost_connect_time = 0
        self.last_send_time = _time.time()
        self.wait_send_data = ''
        self.debug = debug

    def setDebug(self, debug):
        """设置调试信息标识

        Args:
            debug (bool): 是否输出调试信息
        """
        self.debug = debug

    def _showDebug(self, msg, loglevel=20):
        """
        显示调试信息

        Args:
            msg (str): 调试信息内容
            loglevel (int, optional): Description
        """
        writeLog(repr(msg), loglevel)
        if self.debug:
            print("[D] {0} {1}".format(stamp2time(_time.time()), repr(msg)))

    def isConnected(self):
        """该session中的socket对象是否已连接

        Returns:
            bool: 0-未连接，1-已连接
        """
        return self.connected

    def isNothingSend(self):
        """该session是否有需要发送的数据

        Returns:
            bool: 0-有需要发送的数据，1-无需要发送的数据
        """
        return len(self.wait_send_data) == 0 or self.wait_send_data == KEEP_ALIVE

    def setSendData(self, sendData):
        """设置发送缓存

        Args:
            sendData (str): 需要发送的数据
        """
        self.wait_send_data = sendData
        modify(self.sock, WRITE)
        if len(sendData) > 0 and sendData != KEEP_ALIVE:
            self._showDebug('({0}) add send data: {1}'.format(self.idx, sendData))

    def receive(self):
        """接收数据"""
        # 设置状态标记
        if not self.connected:
            self.connected = 1
            self.connect_time = _time.time()
            self.connect_fail_count = 0
            self.reconnect_timer = 1
            self._showDebug('({0}) recv link success.'.format(self.idx), 30)

        recbuff = ''
        try:
            recbuff = self.sock.recv(8192)
        except Exception as ex:
            self.disconnect('socket recv error: {0}'.format(ex))
            return

        if len(recbuff) == 0:
            self.disconnect('client close')
            return
        self._showDebug('({0}) recv: {1}'.format(self.idx, recbuff))

    def send(self):
        """发送数据"""
        # 设置状态标记
        if not self.connected:
            self.connected = 1
            self.connect_time = _time.time()
            self.connect_fail_count = 0
            self.reconnect_timer = 1
            self._showDebug('({0}) send link success.'.format(self.idx), 40)

        if len(self.wait_send_data) > 0:
            try:
                self.sock.send(self.wait_send_data)
                self.last_send_time = _time.time()
                self._showDebug('({0}) send: {1}'.format(self.idx, self.wait_send_data))
                self.wait_send_data = ''
            except Exception as ex:
                self.disconnect('socket send error')
                return

        if self.isNothingSend():
            modify(self.sock, READ)

    def connect(self):
        """发起非阻塞连接"""
        self.sock = _socket.socket(_socket.AF_INET, _socket.SOCK_STREAM)
        self.sock.setblocking(0)
        self.fileno = self.sock.fileno()

        try:
            self.sock.connect(self.address)
        except:
            self.lost_connect_time = _time.time()

        register(self.sock, READ)
        if not self.isNothingSend():
            modify(self.sock, WRITE)

        # if self.isNothingSend():
        #     self.setSendData(KEEP_ALIVE)

    def disconnect(self, closereason=''):
        """
        断开客户端 socket

        Args:
            closereason (str, optional): socket关闭原因
        """
        # 清理状态监听
        try:
            unregister(self.sock)
        except:
            pass
        # 关闭socket
        try:
            self.sock.close()
        except:
            pass

        if self.connected:
            self._showDebug("({0}) close: {1}".format(self.idx, closereason), 40)
        else:
            self._showDebug("({0}) link fail.".format(self.idx), 40)
        # 更新标志位
        self.connected = 0
        self.lost_connect_time = _time.time()

    def clean(self):
        """清理常连接集合，回收socket资源"""
        self.disconnect('link recycle')


class SocketPool(object):
    """socket连接池

    Attributes:
        address (tuple): (str(ip), int(port))
        debug (bool): 是否输出调试信息
        free_clients (queue): socket pool
        max_idle (int): 最大常连接保持数量，默认1
        max_open (int): 池中最大socket实例数量，默认20,最大500
        max_recycle_sec (int): socket无发送回收时间，默认60s
        send_queue (queue): 发送队列
        working_clients (TYPE): Description
    """

    def __init__(self,
                 connect_address,
                 max_idle_connections=1,
                 max_open_connections=20,
                 max_recycle_sec=60,
                 debug=0,
                 logger=None):
        """初始化

        Args:
            connect_address (tuple): (str(ip), int(port))
            max_idle_connections (int, optional): 最大常连接保持数量，默认1
            max_open_connections (int, optional): 池中最大socket实例数量，默认100
            max_recycle_sec (int, optional): socket无发送回收时间，默认60s
            debug (int, optional): 调试信息开关
            logger (logger, optional): 日志实例，不赋值则输出调试信息
        """
        global LOG_POOL
        # 受windows平台影响，最大连接数为500
        if max_open_connections > 500:
            max_open_connections = 500
        # 常连接数量不能大于最大连接数
        if max_idle_connections > max_open_connections:
            max_idle_connections = max_open_connections

        self.address = connect_address
        self.max_idle = max_idle_connections
        self.max_open = max_open_connections
        self.max_recycle_sec = max_recycle_sec
        self.debug = debug
        self.send_queue = PriorityQueue()
        self.free_clients = _Queue.Queue()
        self.working_clients = set()
        if logger is not None:
            LOG_POOL = logger
        else:
            self.debug = 1

        # 初始化连接池, 启动常连接
        for i in range(self.max_open):
            c = SocketSession(i, self.address, self.debug)
            if len(self.working_clients) < self.max_idle:
                c.connect()
                self.working_clients.add(c)
            else:
                self.free_clients.put_nowait(c)
            del c

    def setDebug(self, debug):
        """设置调试信息标识

        Args:
            debug (bool): 是否输出调试信息
        """
        self.debug = debug

    def _showDebug(self, msg, loglevel=20):
        """
        显示调试信息

        Args:
            msg (str): 调试信息内容
            loglevel (int, optional): 日志等级
        """
        writeLog(repr(msg), loglevel)
        if self.debug:
            print("[D] {0} {1}".format(stamp2time(_time.time()), repr(msg)))

    def expandPool(self, new_open_connections):
        """扩大连接池数量

        Args:
            new_open_connections (int): 新的池中最大socket实例数量，若小于当前数量则不操作

        Returns:
            int: 0-扩展失败，1-扩展成功
        """
        # 受windows平台影响，最大连接数为500
        if new_open_connections > 500:
            new_open_connections == 500
        # 新数量小于当前数量，不操作
        if new_open_connections < self.max_open:
            return 0

        for i in range(self.max_open, new_open_connections):
            c = SocketSession(i, self.address, self.debug)
            self.free_clients.put_nowait(c)

        self.max_open = new_open_connections
        return 1

    def addSendMsg(self, msg, pri=5):
        """向发送队列添加数据

        Args:
            msg (str): 发送的数据
            pri (int): 该数据优先级（1-9，高-低）
        """
        self.send_queue.put_now(msg, pri)
        self._showDebug('add to queue: {0}'.format(msg))

    def getStatus(self):
        """检查状态

        Returns:
            int: 0-所有连接均断开，可能服务错误或配置错误。1-至少有一个连接正常
        """
        status = 0
        for c in self.working_clients:
            if c.isConnected():
                status = 1
                break
        return status

    def getClient(self, fn):
        """查找socket对象对应的session

        Args:
            fn (socket): socket对象

        Returns:
            socket: socket对象
        """
        for c in self.working_clients:
            if c.sock == fn:
                return c
        return None

    def getOnlineCount(self):
        """获取已连接的session数量

        Returns:
            int: 已连接的session数量
        """
        status = 0
        for c in self.working_clients:
            if c.isConnected():
                status += 1
        return status

    def start(self):
        """开始启动Socket池"""
        global EPOLL

        t = _time.time()
        last_gc = t
        reconnect_sec = 15
        while True:
            _time.sleep(0.01)

            # 优先利用当前保持的连接
            if not self.send_queue.empty():
                for c in self.working_clients:
                    if c.isNothingSend():
                        if not c.isConnected():
                            c.connect()
                        s = self.send_queue.get_nowait()[1]
                        c.setSendData(s)
                        del s
                    if self.send_queue.empty():
                        break
            # 若连接池还有多余session，继续使用
            if not self.send_queue.empty():
                while not self.free_clients.empty():
                    c = self.free_clients.get_nowait()
                    c.connect()
                    self.working_clients.add(c)
                    s = self.send_queue.get_nowait()[1]
                    c.setSendData(s)
                    del s
                    if self.send_queue.empty():
                        break

            if not self.send_queue.empty() and self.free_clients.empty():
                reconnect_sec = 0

            t = _time.time()
            x = self.working_clients.copy()
            for c in x:
                # 断线重连
                if not c.isNothingSend() and not c.isConnected(
                ) and t - c.lost_connect_time > reconnect_sec:
                    c.connect()
                    continue

                # 断开多余连接
                if self.getOnlineCount() > self.max_idle:
                    if t - c.last_send_time > self.max_recycle_sec and c.isNothingSend():
                        c.clean()
                        self.free_clients.put(c)
                        self.working_clients.discard(c)
                        continue

            if len(READ) + len(WRITE) == 0:
                _time.sleep(0.1)
            else:
                # inbuf, outbuf, errbuf = _select.select(READ, WRITE, READ, 1)
                try:
                    # 获取事件
                    inbuf, outbuf, errbuf = _select.select(READ, WRITE, READ, 1)
                except Exception as ex:
                    self._showDebug('event error: {0}'.format(ex.message), 40)
                    READ.clear()
                    WRITE.clear()
                    continue

                if len(errbuf) > 0:
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
                            self.mainLoop(soc, 'err', debug=self.debug)
                        except:
                            pass

                if len(inbuf) > 0:
                    for soc in inbuf:
                        try:
                            self.mainLoop(soc, 'in', debug=self.debug)
                        except:
                            pass

                if len(outbuf) > 0:
                    for soc in outbuf:
                        try:
                            self.mainLoop(soc, 'out', debug=self.debug)
                        except:
                            pass
                del inbuf, outbuf, errbuf

            reconnect_sec = 15

            # 资源回收
            if t - last_gc > 600:
                _gc.collect()
                last_gc = t
                self._showDebug("gc", 0)

    def mainLoop(self, sock, eve, debug=0):
        """
        主循环

        Args:
            sock (socket): socket对象
            eve (object): 事件
            debug (bool, optional): 是否输出调试信息
        """
        if debug:
            self.worker(sock, eve)
        else:
            try:
                self.worker(sock, eve)
            except Exception as ex:
                self._showDebug("main loop error:{0}".format(ex.message), 40)

    def worker(self, sock, eve):
        """
        事件分类处理

        Args:
            sock (socket): socket对象
            eve (object): 事件
        """
        c = self.getClient(sock)
        if c is None:
            unregister(sock)
            return
        # socket状态错误
        if eve == 'err':
            c.disconnect('socket error')
        # socket 有数据读
        elif eve == 'in':
            c.receive()
        # socket 可写
        elif eve == 'out':
            c.send()
        del c
