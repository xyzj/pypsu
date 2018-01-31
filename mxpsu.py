# -*- coding: utf-8 -*-

__version__ = "0.9"
__author__ = 'minamoto'
__doc__ = 'Perhaps something useful'

try:
    import threading as _threading
except ImportError:
    import dummy_threading as _threading
import base64 as _base64
import time as _time
import datetime as _datetime
import random as _random
import math as _math
import socket as _socket
import struct as _struct
import os as _os
import hashlib
import codecs
import zlib as _xlib
import sys as _sys
import binascii
reload(_sys)
_sys.setdefaultencoding(_sys.getfilesystemencoding())

_PLATFORM = _sys.platform


def __cur_file_dir():
    # 获取脚本路径
    path = _sys.path[0]
    # 判断为脚本文件还是py2exe编译后的文件，如果是脚本文件，则返回的是脚本的目录，如果是py2exe编译后的文件，则返回的是编译后的文件路径
    if _os.path.isdir(path):
        return path
    elif _os.path.isfile(path):
        return _os.path.dirname(path)
    else:
        return '.'


def decode_message(str_in):
    try:
        oh = ''
        str_in += '=' * (4 - len(str_in) % 4)
        y = _base64.b64decode(str_in.swapcase())
        x = ord(y[0])
        z = y[1:]
        for s in z:
            oh += chr(ord(s) - x)
        return oh
    except:
        return 'You screwed up.'


SCRIPT_DIR = __cur_file_dir()
SCRIPT_NAME = _sys.argv[0].rpartition('\\')[2]
KEEP_ALIVE = '3a-53-3b-a0'  # 1983-08-19 03:12:00~2014-08-21 18:00:00

try:
    a = '{0}{1}'.format(_time.localtime()[1], _time.localtime()[2])
    if a in ('127', '720', '65', '821'):
        with open(_os.path.join(SCRIPT_DIR, '.history'), 'r') as f:
            x = f.readlines()
        z = ''.join(x)
        print decode_message(z)
    with open(_os.path.join(SCRIPT_DIR, '.message'), 'r') as f:
        x = f.readlines()
    z = ''.join(x)
    print decode_message(z)
except:
    pass


def bcd2int(value):
    """
    bcd转int
    """
    return ((value & 0xf0) >> 4) * 10 + (value & 0x0f)


def int2bcd(value):
    """
    int转bcd
    """
    return ((value / 10) << 4) | (value % 10)


class GpsPoint():
    """Summary

    Attributes:
        lat (TYPE): Description
        lng (TYPE): Description
    """

    def __init__(self, lng, lat):
        """Summary

        Args:
            lng (TYPE): Description
            lat (TYPE): Description
        """
        self.lng = lng
        self.lat = lat


class GpsDistance():
    """Summary

    Args:
        a (GpsPoint): Description
        b (GpsPoint): Description

    Returns:
        TYPE: Description
    """

    def __init__(self, lng_a, lat_a, lng_b, lat_b):
        """Summary

        Args:
            lng (TYPE): Description
            lat (TYPE): Description
        """
        self.a = GpsPoint(lng_a, lat_a)
        self.b = GpsPoint(lng_b, lat_b)

    def get_distance(self):
        c = self.Wv(self.a, self.b)
        return c

    def max(self, a, b):
        """Summary

        Args:
            a (TYPE): Description
            b (TYPE): Description

        Returns:
            TYPE: Description
        """
        if a > b:
            return a
        return b

    def min(self, a, c):
        """Summary

        Args:
            a (TYPE): Description
            c (TYPE): Description

        Returns:
            TYPE: Description
        """
        if a > c:
            return c
        return a

    def lw(self, a, b, c):
        """Summary

        Args:
            a (TYPE): Description
            b (TYPE): Description
            c (TYPE): Description

        Returns:
            TYPE: Description
        """
        #     b != n && (a = Math.max(a, b));
        #     c != n && (a = Math.min(a, c));
        a = self.max(a, b)
        a = self.min(a, c)
        return a

    def ew(self, a, b, c):
        """Summary

        Args:
            a (TYPE): Description
            b (TYPE): Description
            c (TYPE): Description

        Returns:
            TYPE: Description
        """
        while a > c:
            a -= c - b
        while a < b:
            a += c - b
        return a

    def oi(self, a):
        """Summary

        Args:
            a (TYPE): Description

        Returns:
            TYPE: Description
        """
        return _math.pi * a / 180

    def Td(self, a, b, c, d):
        """Summary

        Args:
            a (TYPE): Description
            b (TYPE): Description
            c (TYPE): Description
            d (TYPE): Description

        Returns:
            TYPE: Description
        """
        return 6370996.81 * _math.acos(
            _math.sin(c) * _math.sin(d) + _math.cos(c) * _math.cos(d) *
            _math.cos(b - a))

    def Wv(self, a, b):
        """Summary

        Args:
            a (GpsPoint): Description
            b (GpsPoint): Description

        Returns:
            TYPE: Description
        """
        if not a or not b:
            return 0
        a.lng = self.ew(a.lng, -180, 180)
        a.lat = self.lw(a.lat, -74, 74)
        b.lng = self.ew(b.lng, -180, 180)
        b.lat = self.lw(b.lat, -74, 74)
        return self.Td(
            self.oi(a.lng), self.oi(b.lng), self.oi(a.lat), self.oi(b.lat))


def formatLog(log_txt, dateformat='%Y-%m-%d %H:%M:%S'):
    '''
    Args:
    log_txt (str):
    dateformat (str), default: %Y-%m-%d %H:%M:%S
    '''
    a = str(u"{0} {1}".format(
        _time.strftime(dateformat, _time.localtime()), log_txt))
    return a


def checkPort(port):
    if port and port.isdigit():
        iport = int(port)
        if 0 < iport < 65536:
            return 1
    return 0


def getMD5(src):
    '''
    Args:
    src (str)
    withsalt (bool): 0-False,1-True, saltstr is secret
    '''
    src = str(src)
    md5 = hashlib.md5()
    md5.update(src.encode('utf-8'))
    return md5.hexdigest()


def getSHA1(src):
    '''
    Args:
    src (str)
    withsalt (bool): 0-False,1-True, saltstr is secret
    '''
    src = str(src)
    sha1 = hashlib.sha1()
    sha1.update(src.encode('utf-8'))
    return sha1.hexdigest()


class PriorityQueue():
    """Create a queue object with a given maximum size.

    If maxsize is <= 0, the queue size is infinite.
    """

    def __init__(self, maxsize=0):
        self.maxsize = maxsize
        self._init(maxsize)
        # mutex must be held whenever the queue is mutating.  All methods
        # that acquire mutex must release it before returning.  mutex
        # is shared between the three conditions, so acquiring and
        # releasing the conditions also acquires and releases mutex.
        self.mutex = _threading.Lock()
        # Notify not_empty whenever an item is added to the queue; a
        # thread waiting to get is notified then.
        self.not_empty = _threading.Condition(self.mutex)
        # Notify not_full whenever an item is removed from the queue;
        # a thread waiting to put is notified then.
        self.not_full = _threading.Condition(self.mutex)
        # Notify all_tasks_done whenever the number of unfinished tasks
        # drops to zero; thread waiting to join() is notified to resume
        self.all_tasks_done = _threading.Condition(self.mutex)
        self.unfinished_tasks = 0

    def task_done(self):
        """Indicate that a formerly enqueued task is complete.

        Used by Queue consumer threads.  For each get() used to fetch a task,
        a subsequent call to task_done() tells the queue that the processing
        on the task is complete.

        If a join() is currently blocking, it will resume when all items
        have been processed (meaning that a task_done() call was received
        for every item that had been put() into the queue).

        Raises a ValueError if called more times than there were items
        placed in the queue.
        """
        self.all_tasks_done.acquire()
        try:
            unfinished = self.unfinished_tasks - 1
            if unfinished <= 0:
                if unfinished < 0:
                    raise ValueError('task_done() called too many times')
                self.all_tasks_done.notify_all()
            self.unfinished_tasks = unfinished
        finally:
            self.all_tasks_done.release()

    def join(self):
        """Blocks until all items in the Queue have been gotten and processed.

        The count of unfinished tasks goes up whenever an item is added to the
        queue. The count goes down whenever a consumer thread calls task_done()
        to indicate the item was retrieved and all work on it is complete.

        When the count of unfinished tasks drops to zero, join() unblocks.
        """
        self.all_tasks_done.acquire()
        try:
            while self.unfinished_tasks:
                self.all_tasks_done.wait()
        finally:
            self.all_tasks_done.release()

    def qsize(self):
        """Return the approximate size of the queue (not reliable!)."""
        self.mutex.acquire()
        n = self._qsize()
        self.mutex.release()
        return n

    def empty(self):
        """Return True if the queue is empty, False otherwise (not reliable!)."""
        self.mutex.acquire()
        n = 0
        if self._qsize() > 0:
            n = 0
        else:
            n = 1
        self.mutex.release()
        return n

    def full(self):
        """Return True if the queue is full, False otherwise (not reliable!)."""
        self.mutex.acquire()
        n = 0 < self.maxsize == self._qsize()
        self.mutex.release()
        return n

    def put(self, item, block=1, timeout=0):
        """Put an item into the queue.

        If optional args 'block' is true and 'timeout' is None (the default),
        block if necessary until a free slot is available. If 'timeout' is
        a non-negative number, it blocks at most 'timeout' seconds and raises
        the Full exception if no free slot was available within that time.
        Otherwise ('block' is false), put an item on the queue if a free slot
        is immediately available, else raise the Full exception ('timeout'
        is ignored in that case).
        """
        self.not_full.acquire()
        try:
            if self.maxsize > 0:
                if block == 0:
                    if self._qsize() == self.maxsize:
                        raise 1
                elif timeout == 0:
                    while self._qsize() == self.maxsize:
                        self.not_full.wait()
                elif timeout < 0:
                    raise ValueError("'timeout' must be a non-negative number")
                else:
                    endtime = _time() + timeout
                    while self._qsize() == self.maxsize:
                        remaining = endtime - _time()
                        if remaining <= 0.0:
                            raise 1
                        self.not_full.wait(remaining)
            self._put(item)
            self.unfinished_tasks += 1
            self.not_empty.notify()
        finally:
            self.not_full.release()

    def put_nowait(self, item, priority=5):
        """Put an item into the queue without blocking.

        Only enqueue the item if a free slot is immediately available.
        Otherwise raise the Full exception.
        """
        return self.put((priority, item), False)

    def get(self, block=1, timeout=0):
        """Remove and return an item from the queue.

        If optional args 'block' is true and 'timeout' is None (the default),
        block if necessary until an item is available. If 'timeout' is
        a non-negative number, it blocks at most 'timeout' seconds and raises
        the Empty exception if no item was available within that time.
        Otherwise ('block' is false), return an item if one is immediately
        available, else raise the Empty exception ('timeout' is ignored
        in that case).
        """
        self.not_empty.acquire()
        try:
            if not block:
                if not self._qsize():
                    raise 0
            elif timeout == 0:
                while not self._qsize():
                    self.not_empty.wait()
            elif timeout < 0:
                raise ValueError("'timeout' must be a non-negative number")
            else:
                endtime = _time() + timeout
                while not self._qsize():
                    remaining = endtime - _time()
                    if remaining <= 0.0:
                        raise 0
                    self.not_empty.wait(remaining)
            item = self._get()
            self.not_full.notify()
            return item
        finally:
            self.not_empty.release()

    def get_nowait(self):
        """Remove and return an item from the queue without blocking.

        Only get an item if one is immediately available. Otherwise
        raise the Empty exception.
        """
        if self._qsize() > 0:
            return self.get(False)[1]
        else:
            return None

    # Override these methods to implement other queue organizations
    # (e.g. stack or priority queue).
    # These will only be called with appropriate locks held

    # Initialize the queue representation
    def _init(self, maxsize):
        # def q=[]
        self.queue = []

    def _qsize(self):
        return len(self.queue)

    # Put a new item in the queue
    def _put(self, item):
        self.queue.insert(0, item)
        self.queue.sort(key=lambda it: it[0], reverse=True)

    # Get an item from the queue
    def _get(self):
        return self.queue.pop()

    def __del__(self):
        # del self.queue
        self.queue = []

    def get_queue(self):
        return self.queu


# def HEIGHT = 32
# # chars = "   ...',;:jlrixtO0KXNWMMM"
# def chars = "   .........rixtO0KXNWMMM"

# def __getsize(object image):
#     '''Calculate the target picture size
#     '''
#     def s_width = image.size[0]
#     def s_height = image.size[1]
#     def t_height = HEIGHT
#     def t_width = (t_height * s_width) / s_height
#     t_width = int(t_width * 2.3)
#     # def t_size = (t_width, t_height)
#     return (t_width, t_height)

# def pic2ascii(filename):
#     def output = ''
#     image = _Image.open(filename)
#     def size = __getsize(image)
#     image = image.resize(size)
#     image = image.convert('L')
#     pixs = image.load()
#     for y in range(size[1]):
#         for x in range(size[0]):
#             output += chars[pixs[x, y] / 10 - 1]
#         output += '\n'
#     return output


def getWindowsIpAddress():
    return _socket.gethostbyname(_socket.gethostname())


def getLinuxIpAddress(ifname):
    """Summary

    Args:
        ifname (str): something like eth0

    Returns:
        str: ip string
    """
    try:
        import fcntl

        s = _socket.socket(_socket.AF_INET, _socket.SOCK_DGRAM)
        return _socket.inet_ntoa(
            fcntl.ioctl(
                s.fileno(),
                0x8915,  # SIOCGIFADDR
                _struct.pack('256s', ifname[:15]))[20:24])
    except:
        return ''


def cutString(instring, width):
    """Summary

    Args:
        instring (str): Description
        width (int): Description

    Returns:
        str: Description
    """
    l = len(instring)
    a = [instring[x:x + width] for x in range(0, l, width)]
    return tuple(a)


def mkdirs(full_path, mode=0775):
    '''
    Args:
    full_path (str): dir path
    mode (int): something like 0775
    '''
    try:
        _os.makedirs(full_path, mode)
    except:
        pass


def checkFolder(folders='log,conf', uplevel=0):
    """Summary

    Args:
        folders (str, optional): Description
        uplevel (bool, optional): Description

    Returns:
        TYPE: Description
    """
    if len(folders) < 1 or folders is None:
        return
    if uplevel > 0:
        location = '..'
    else:
        location = '.'
    path = SCRIPT_DIR
    folder = folders.split(',')
    for d in folder:
        x = _os.path.join(path, location, d)
        try:
            _os.mkdir(x)  # , mode=0775)
        except:
            pass


def time2stamp(timestr, tocsharp=0, format_type='%Y-%m-%d %H:%M:%S'):
    """Summary

    Args:
        time(TYPE): Description
        tocsharp (bool, optional): Description
        format_type (str, optional): Description

    Returns:
        TYPE: Description
    """
    y = 621356256000000000.0
    z = 10000000.0

    try:
        if tocsharp > 0:
            return int(
                _time.mktime(_time.strptime(timestr, format_type)) * z + y)
        else:
            return int(_time.mktime(_time.strptime(timestr, format_type)))
    except Exception as ex:
        print(ex)
        return 0


def stamp2time(stamp, fromcsharp=0, format_type='%Y-%m-%d %H:%M:%S'):
    """Summary

    Args:
        stamp (TYPE): Description
        fromcsharp (bool, optional): Description
        format_type (str, optional): Description

    Returns:
        TYPE: Description
    """
    y = 621356256000000000.0
    z = 10000000.0

    try:
        if fromcsharp > 0:
            return _datetime.datetime.strftime(
                _datetime.datetime.fromtimestamp((stamp - y) / z), format_type)
            # return _time.strftime(format_type, _time.localtime((stamp - y) / z))
        else:
            return _datetime.datetime.strftime(
                _datetime.datetime.fromtimestamp(stamp), format_type)
            # return _time.strftime(format_type, _time.localtime(stamp))
    except Exception as ex:
        print(ex)
        return ''


def switchStamp(stamp):
    y = 621356256000000000.0
    z = 10000000.0

    try:
        if stamp == 0 or len(str(stamp)) < 10:
            return 0
        elif stamp > y:
            return int((stamp - y) / z)
        else:
            return int(stamp * z + y)
    except Exception as ex:
        print(ex)
        return 0


def ip2int(strip, usehostorder=0):
    """Summary

    Args:
        strip (TYPE): Description
        usehostorder (bool, optional): Description

    Returns:
        TYPE: Description
    """
    try:
        if usehostorder > 0:
            return int(
                _socket.htonl(
                    _struct.unpack("!L", _socket.inet_aton(strip))[0]))
        else:
            return int(
                _socket.htonl(
                    _struct.unpack("I", _socket.inet_aton(strip))[0]))
    except:
        return -1


def ip2string(intip, usehostorder=0):
    """Summary

    Args:
        intip (int): Description
        usehostorder (bool, optional): Description

    Returns:
        TYPE: Description
    """
    try:
        if usehostorder > 0:
            return _socket.inet_ntoa(_struct.pack('!L', _socket.ntohl(intip)))
        else:
            return _socket.inet_ntoa(_struct.pack('I', _socket.ntohl(intip)))
    except:
        return ''


def string2hex(str_in, splitchar="-"):
    return splitchar.join(cutString(binascii.hexlify(str_in), 2))


def hex2string(hex_in, splitchar="-"):
    return binascii.unhexlify(hex_in.replace(splitchar, ''))


def string2lst(str_in):
    return [ord(a) for a in str_in]


def lst2string(lst_in):
    return ''.join(["{0:02x}".format(int(a, 16))
                    for a in lst_in]).decode('hex')


def hex2lst(hex_in, splitchar="-"):
    return [int(a, 16) for a in hex_in.split(splitchar)]


def lst2hex(lst_in, splitchar="-"):
    return splitchar.join(["{0:02x}".format(a) for a in lst_in])


def hexString(argv):
    """Summary

    Args:
        argv (TYPE): Description

    Returns:
        TYPE: Description
    """
    a = hexList(list(argv))
    b = ['{0:02x}'.format(s) for s in a]
    return '-'.join(b)


def hexList(argv):
    """Summary

    Args:
        argv (TYPE): Description

    Returns:
        TYPE: Description
    """
    hhex = []
    try:
        hhex = [ord(hvol) for hvol in argv]
    except:
        hhex = []
    return hhex


def checkLrc(databytes):
    """
    检查纵校验

    Args:
        databytes (TYPE): Description
    """
    l = len(databytes)
    lcr = databytes[l - 1]
    data = databytes[:l - 1]
    if lcr == lrcVB(data):
        return 1
    else:
        return 0


def lrcVB(databytes):
    """
    计算纵校验

    Args:
        databytes (TYPE): Description
    """
    a = 0x00

    for d in databytes:
        a = a ^ d
    return a


def crc32_string(str_in):
    if _sys.version_info[0] == 2:
        return binascii.crc32(str_in) & 0xffffffff
    elif _sys.version_info[0] == 3:
        return binascii.crc32(str_in)


def crc32_file(filename):
    if _os.path.isfile(filename):
        blocksize = 1024 * 64
        try:
            with open(filename, 'rb') as f:
                s = f.read(blocksize)
                crc = 0
                if _sys.version_info[0] == 2:
                    while len(s) != 0:
                        crc = binascii.crc32(s, crc) & 0xffffffff
                        s = f.read(blocksize)
                elif _sys.version_info[0] == 3:
                    while len(s) != 0:
                        crc = binascii.crc32(s, crc)
                        s = f.read(blocksize)
                f.close()
            return crc
        except:
            return 0
    else:
        return 0


def checkCrc16(databytes):
    """
    检查crc

    Args:
        databytes (TYPE): Description
    """
    crc = (databytes[len(databytes) - 2], databytes[len(databytes) - 1])
    data = databytes[0:len(databytes) - 2]
    if crc == crc16VB(data):
        return 1
    else:
        return 0


def crc16VB(databytes):
    """
    计算crc

    Args:
        databytes (TYPE): Description
    """
    crc16lo = 0xff
    crc16hi = 0xff
    cl = 0x01
    ch = 0xa0
    for byte in databytes:
        crc16lo = crc16lo ^ byte
        for flag in range(8):
            savehi = crc16hi
            savelo = crc16lo
            crc16hi //= 2
            crc16lo //= 2
            if (savehi & 0x01) == 0x01:
                crc16lo ^= 0x80
            if (savelo & 0x01) == 0x01:
                crc16hi ^= ch
                crc16lo ^= cl
    return (crc16lo, crc16hi)


def string2bytes(datastring, splitchar="-"):
    """
    字符串转数字列表

    Args:
        datastring (TYPE): Description
        splitchar (str, optional): Description
    """
    s = datastring.split(splitchar)
    s2bytes = [int(b, 16) for b in s]
    return s2bytes


def bytes2string(databytes, splitchar="-", noformat=1):
    """
    数字列表转字符串

    Args:
        databytes (TYPE): Description
        splitchar (str, optional): Description
        noformat (bool, optional): Description
    """
    s = ""
    if noformat:
        return splitchar.join(["{0:x}".format(int(d)) for d in databytes])
        # for d in databytes:
        #     s += splitchar + "{0:x}".format(int(d))
    else:
        return splitchar.join(["{0:02x}".format(int(d)) for d in databytes])
        # for d in databytes:
        #     s += splitchar + "{0:02x}".format(int(d))
    # return s[len(splitchar):]


def list2string(datalist, splitchar="-"):
    """
    列表转字符串

    Args:
        datalist (TYPE): Description
        splitchar (str, optional): Description
        compress (bool, optional): Description
    """
    return splitchar.join([str(a) for a in datalist])
    # s = ''
    # for d in datalist:
    #     s += splitchar + str(d)
    # s = s[1:]
    # # s = splitchar.join(datalist)
    # if compress:
    #     return _base64.b64encode(_zlib.compress(s, 9))
    # else:
    #     return s

    # def getMac():
    #     """Summary
    #
    #     Returns:
    #         TYPE: Description
    #     """
    #     mac = _uuid.uuid1().hex[-12:]
    #     x = [mac[i:i + 2] for i in range(0, len(mac), 2)]
    #     return ":".join(x)


def buildMac(head=0):
    """
    生成随机mac地址
    :param head: 0-jue, 1-kvm
    :return:

    Args:
        head (int, optional): 0-custom,1-kvm
    """
    machex = ""
    if head == 0:  # jue
        machex = "4a:75:65:"
    elif head > 0:  # kvm
        machex = "52:54:00:"
    # else:  # 本地网卡厂家
    #     machex = getMac()[:9]
    if machex != "":
        mac = [
            hex(_random.randint(0x00, 0x7f)).replace('0x', ''),
            hex(_random.randint(0x00, 0xff)).replace('0x', ''),
            hex(_random.randint(0x00, 0xff)).replace('0x', '')
        ]
        hw = machex + ':'.join(mac)
        # def hw = machex + ':'.join(map(lambda x: "%s" % x, mac))
        # hw = machex + ':'.join(map(lambda x: "%02x" % x, mac))
        return hw
    else:
        return None


def timeDifference(t1, t2):
    """
    计算时间差，格式%Y-%m-%d %H:%M:%S
    :param t1: 起始时间
    :param t2: 结束时间

    Args:
        t1 (TYPE): Description
        t2 (TYPE): Description
    """
    try:
        x1 = _time.strptime(t1, "%Y-%m-%d %H:%M:%S")
        x2 = _time.strptime(t2, "%Y-%m-%d %H:%M:%S")
    except Exception as ex:
        print(ex)
        return 0
    else:
        return _time.mktime(x2) - _time.mktime(x1)


class Platform(object):
    @staticmethod
    def detail():
        return _PLATFORM

    @staticmethod
    def isWin():
        return _PLATFORM.startswith('win')

    @staticmethod
    def isLinux():
        return _PLATFORM.startswith('linux')

    @staticmethod
    def isMac():
        return _PLATFORM.startswith('darwin')


def setWindowsStyle():
    # s = checkPlatform()
    # if s == "win7":
    #     return "windowsvista"
    # elif s == "winxp":
    #     return "windowsxp"
    # else:
    #     return "cleanlooks"
    return "cleanlooks"


def checkWinProcess(name):
    p = _os.popen('tasklist /FI "imagename eq {0}" /FO "csv" /NH'.format(name))
    s = p.read()
    if s.count(name) > 0:
        return 1
    else:
        return 0


def ipDecompose(xips):
    """Summary

    Args:
        xip (TYPE): 要解析的地址list [x.x.x.x/y<:p>]格式

    Returns:
        TYPE: ip地址端口列表[(x.x.x.x<:p>)]
    """
    xaddr = []
    for r in xips:
        if r.find('/') > -1:
            try:
                xip, p = r.split(':')
            except:
                xip = r
                p = '0'
            a, b, c, d = xip[:xip.find('/')].split('.')
            l = int(xip[xip.find('/') + 1:])
            e = '{0:08b}{1:08b}{2:08b}{3:08b}'.format(
                int(a), int(b), int(c), int(d))
            f = int('1' * (8 * 4 - l), 2)
            g = e[:l]
            for i in range(1, f):
                h = g + '{0:0{1}b}'.format(i, 8 * 4 - l)
                k = cutString(h, 8)
                w, x, y, z = [int(u, 2) for u in k.split('-')]
                if p == '0':
                    xaddr.append(('{0}.{1}.{2}.{3}'.format(w, x, y, z)))
                else:
                    xaddr.append(('{0}.{1}.{2}.{3}'.format(w, x, y, z),
                                  int(p)))
        else:
            xaddr.append((r.split(':')[0], int(r.split(':')[1])))
    return tuple(xaddr)


class Getch():
    """Gets a single character from standard input.  Does not echo to the
screen."""

    def __init__(self):
        try:
            self.impl = GetchWindows()
        except ImportError:
            self.impl = GetchUnix()

    def __call__(self):
        return self.impl()


class GetchUnix():
    def __init__(self):
        pass

    def __call__(self):
        import tty as _tty
        import termios as _termios
        fd = _sys.stdin.fileno()
        old_settings = _termios.tcgetattr(fd)
        try:
            _tty.setraw(_sys.stdin.fileno(), _termios.TCSANOW)
            ch = _sys.stdin.read(1)
            _sys.stdout.write(ch)
        finally:
            _termios.tcsetattr(fd, _termios.TCSADRAIN, old_settings)
        return ch


class GetchWindows():
    def __init__(self):
        pass

    def __call__(self):
        try:
            import msvcrt
            return msvcrt.getch()
        except:
            pass


def get_dirs(parentdir, subdir='', atlocal=0):
    '''
    Returns: confdir, logdir, cachedir
    '''
    if len(subdir) > 0:
        subdir = '{0}.d'.format(subdir)
    if Platform.isLinux():
        if atlocal:
            # 配置文件目录
            CONF_DIR = _os.path.join(SCRIPT_DIR, '..', 'conf')
            # 日志文件目录
            LOG_DIR = _os.path.join(SCRIPT_DIR, '..', 'log')
            # 缓存文件目录
            CACHE_DIR = _os.path.join(SCRIPT_DIR, '..', 'cache')
            mkdirs(CONF_DIR)
            mkdirs(LOG_DIR)
            mkdirs(CACHE_DIR)
        else:
            # 配置文件目录
            CONF_DIR = _os.path.join("/", "etc", parentdir, subdir)
            # 日志文件目录
            LOG_DIR = _os.path.join("/", "var", "log", parentdir, subdir)
            # 缓存文件目录
            CACHE_DIR = _os.path.join("/", "var", "cache", parentdir, subdir)
            mkdirs(CONF_DIR)
            mkdirs(LOG_DIR)
            mkdirs(CACHE_DIR)
    else:
        # 配置文件目录
        CONF_DIR = _os.path.join(SCRIPT_DIR, '..', 'conf')
        # 日志文件目录
        LOG_DIR = _os.path.join(SCRIPT_DIR, '..', 'log')
        # 缓存文件目录
        CACHE_DIR = _os.path.join(SCRIPT_DIR, '..', 'cache')
        checkFolder('conf,log,cache', 1)
    return (CONF_DIR, LOG_DIR, CACHE_DIR)


def copyFiles(sourceDir, targetDir):
    for f in _os.listdir(sourceDir):
        sourcef = _os.path.join(sourceDir, f)
        targetf = _os.path.join(targetDir, f)
        if _os.path.isfile(sourcef):
            # 创建目录
            if not _os.path.exists(targetDir):
                _os.makedirs(targetDir)
                # 文件不存在,或大小不同,覆盖
                if not _os.path.exists(targetf) or (
                        _os.path.exists(targetf) and
                    (_os.path.getsize(targetf) != _os.path.getsize(sourcef))):
                    # 二进制复制
                    open(targetf, 'wb').write(open(sourcef, 'rb').read())


class ConfigFile():
    def __init__(self, path=''):
        '''
        Args:
        conf (dict): config data, as a dict
        path (str): config file full path, default: config.conf
        '''
        self._conf_data = dict()
        if len(path) > 0:
            self._conf_file = path
            self.loadConfig()
        else:
            self._conf_file = ''

        if 'nt' in _os.name:
            self.lineend = '\r\n'
        elif 'posix' in _os.name:
            self.lineend = '\n'

    def saveConfig(self):
        if self._conf_file == '':
            return

        conf = []
        for a in self._conf_data.keys():
            value, remark = self._conf_data.get(a)
            # if type(remark) is str:
            #     lst_remark = [remark]
            # else:
            #     lst_remark = remark
            # for r in lst_remark:
            if not remark.startswith('#'):
                remark = '# ' + remark
            conf.append('{0}'.format(remark))
            conf.append('{0}={1}'.format(a, value))

        with codecs.open(self._conf_file, 'w', 'utf-8') as f:
            try:
                f.writelines([
                    c + self.lineend
                    if c.startswith('#') else c + self.lineend * 2
                    for c in conf
                ])
            except:
                pass
            f.close()

    def loadConfig(self, path=''):
        if len(path) > 0:
            self._conf_file = path
        if not _os.path.isfile(self._conf_file):
            self.saveConfig()
        else:
            with codecs.open(self._conf_file, 'r', 'utf-8') as f:
                conf = f.readlines()
                remark = ''
                for c in conf:
                    c = c.strip()
                    if len(c) == 0:
                        continue
                    if c.startswith('#'):
                        remark = c
                    elif c.find('=') > 0:
                        a, b = c.split('=', 1)
                        self._conf_data[a.strip()] = (b.strip(), remark)
                        remark = ''
                f.close()
            self.saveConfig()

    def setData(self, key, value, remark=''):
        '''
        when key is exist, this will update the config data, else this add new one
        the data will be save Immediately.
        Args:
        key (str): config data key name
        value (str): config data value
        remark (str): config data describe, it's better not to be empty
        '''
        value = str(value)
        remark = str(remark)

        if len(key.strip()) == 0:
            return False

        if len(remark) == 0:
            item = self._conf_data.get(key)
            if item is None:
                remark = ''
            else:
                remark = item[1]
        self._conf_data[key] = (value, remark)
        self.saveConfig()
        return True

    def delData(self, key):
        '''
        Args:
        key (str): config data key name
        '''
        if key not in self._conf_data.keys():
            return False

        del self._conf_data[key]
        self.saveConfig()
        return True

    def getData(self, key, with_remark=0):
        '''
        Args:
        key (str): config data key name
        with_remark (bool): 0-return value,1-return (value, remark)
        '''
        d = self._conf_data.get(key)
        if with_remark:
            return d
        else:
            if d is not None:
                return d[0]
            else:
                return d

    def getKeys(self):
        '''
        Args:
        key (str): config data key name
        '''
        return self._conf_data.keys()

    def printConfig(self):
        for k in self._conf_data.keys():
            print(k, self._conf_data[k])


def decode_string(str_in):
    '''
    Args:
        str_in (str): input string
    return:
        decode string
    '''
    try:
        str_in += '=' * (4 - len(str_in) % 4)
        y = _base64.b64decode(str_in.swapcase())
        x = int(y[:2])
        z = y[2:]
        z = ''.join(
            [chr(ord(a) - x if ord(a) >= x else ord(a) + 256 - x) for a in z])
        return _xlib.decompress('x\x9c' + z[::-1])[::-1]
    except Exception as ex:
        return 'You screwed up.' + str(ex)


def code_pb2(pb2obj, fmt=0):
    '''
    Args:
        pb2obj: pb2 object
        fmt: 0-base64 string,2-pb2 Serialize string,3-zlib&base64 string
    Return:
        code string
    '''
    try:
        if fmt == 0:
            return _base64.b64encode(pb2obj.SerializeToString())
        elif fmt == 1:
            try:
                import mxpbjson
            except:
                return ''
            else:
                return mxpbjson.pb2json(pb2obj)
        elif fmt == 2:
            return pb2obj.SerializeToString()
        elif fmt == 3:
            return _base64.b64encode(
                _xlib.compress(pb2obj.SerializeToString()))
        return ''
    except:
        return ''


def decode_pb2(pb2msg, pb2obj=None, fmt=0, pb2cls=None):
    '''
    Args:
        pb2msg: pb2 string
        pb2obj: pb2 object
        fmt: 0-base64 string,2-pb2 Serialize string,3-zlib&base64 string
    Return:
        decode pb2obj
    '''
    try:
        if fmt == 0:
            pb2obj.ParseFromString(_base64.b64decode(pb2msg.replace(' ', '+')))
        elif fmt == 1:
            try:
                import mxpbjson
            except:
                return None
            else:
                pb2obj = mxpbjson.json2pb(pb2cls, pb2msg)
        elif fmt == 2:
            pb2obj.ParseFromString(pb2msg)
        elif fmt == 3:
            pb2obj.ParseFromString(
                _xlib.decompress(_base64.b64decode(pb2msg.replace(' ', '+'))))
        return pb2obj
    except:
        return None


def convertProtobuf(pb2msg):
    """Summary

    Args:
        pb2msg (pb2): Description

    Returns:
        str: Description
    """
    return code_pb2(pb2msg)


def hex_bin(hexfile, binfile):
    fin = open(hexfile)
    fout = open(binfile, 'wb')
    result = ''
    for hexstr in fin.readlines():
        hexstr = hexstr.strip()
        size = int(hexstr[1:3], 16)
        if int(hexstr[7:9], 16) != 0:
            continue
        #end if
        for h in range(0, size):
            b = int(hexstr[9 + h * 2:9 + h * 2 + 2], 16)
            result += _struct.pack('B', b)
        #end if
        fout.write(result)
        result = ''
    #end for
    fin.close()
    fout.close()


# bin to hex
def bin_hex(binfile, hexfile):
    fbin = open(binfile, 'rb')
    fhex = open(hexfile, 'w')
    offset = 0
    seg_addr = 0
    while 1:
        checksum = 0
        result = ':'
        bindata = fbin.read(0x10)
        if len(bindata) == 0:
            break
        #end if
        result += '%02X' % len(bindata)
        result += '%04X' % offset
        result += '00'
        checksum = len(bindata)
        checksum += (offset & 0xff) + (offset >> 8)

        for i in range(0, len(bindata)):
            byte = _struct.unpack('B', bindata[i])
            result += '%02X' % byte
            checksum += byte[0]
        #end for
        checksum = 0x01 + ~checksum
        checksum = checksum & 0xff
        result += '%02X/n' % checksum
        fhex.write(result)
        offset += len(bindata)
        if offset == 0x10000:
            offset = 0
            seg_addr += 1
            result = ':02000004'
            result += '%02X%02X' % ((seg_addr >> 8) & 0xff, seg_addr & 0xff)
            checksum = 0x02 + 0x04 + (seg_addr >> 8) + seg_addr & 0xff
            checksum = -checksum
            result += '%02X' % (checksum & 0xff)
            result += '/n'
            fhex.write(result)
        #end if
        if len(bindata) < 0x10:
            break
        #end if
        #end while
    fhex.write(':00000001FF')
    fbin.close()
    fhex.close()


def showOurHistory():
    return
