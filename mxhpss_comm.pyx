# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'High-performance socket service common module'

from Crypto.Cipher import AES as _AES
# from Crypto.Hash import MD5 as _MD5
import random as _random
import zlib as _zlib
import time as _time
import base64 as _base64
import select as _select
from mxpsu import Platform
import sys as _sys
_sys.path.append('/usr/lib64/python2.7/site-packages/')
_sys.path.append('/usr/lib/python2.7/site-packages/')

# Constants from the epoll module
_EPOLLIN = 0x001
_EPOLLPRI = 0x002
_EPOLLOUT = 0x004
_EPOLLERR = 0x008
_EPOLLHUP = 0x010
_EPOLLRDHUP = 0x2000
_EPOLLONESHOT = (1 << 30)
_EPOLLET = (1 << 31)

# epoll实例
if Platform.isLinux():
    IMPL = _select.epoll()
    _ERROR = _EPOLLERR | _EPOLLHUP
    READ = _EPOLLIN | _ERROR
    WRITE = _EPOLLOUT | READ
    WRITE_ONLY = _EPOLLOUT | _ERROR
else:
    IMPL = _select.select
    READ = set()
    WRITE = set()

# 客户端集合{fileno, ClientSession}
CLIENTS = {}

def register(fileno, objwatch, ssock=None):
    """
    注册epoll fd或select socket实例

    Args:
        fileno (object): fd或socket实例
        objwatch (object): 监控事件
        ssock (socket): 用于监听的socket实例
    """
    global READ, WRITE, CLIENTS, IMPL
    if Platform.isLinux():
        try:
            IMPL.register(fileno, objwatch)
        except:
            return
    else:
        if ssock is not None:
            READ.add(ssock)
        else:
            sock = CLIENTS.get(fileno)
            if sock is not None:
                if objwatch is READ:
                    READ.add(sock.sock)
                elif objwatch is WRITE:
                    READ.add(sock.sock)
                    WRITE.add(sock.sock)


def modify(fileno, objwatch):
    """
    修改epoll fd或select socket实例监听事件

    Args:
        fileno (object): fd或socket实例
        objwatch (object): 监控事件
    """
    global READ, WRITE, CLIENTS, IMPL
    if Platform.isLinux():
        try:
            IMPL.modify(fileno, objwatch)
        except:
            return
    else:
        sock = CLIENTS.get(fileno)
        if sock is not None:
            if objwatch is READ:
                try:
                    WRITE.remove(sock.sock)
                except:
                    pass
            elif objwatch is WRITE:
                WRITE.add(sock.sock)


def unregister(fileno):
    """
    注销epoll fd或select socket实例监听事件

    Args:
        fileno (object): fd或socket实例
    """
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


cdef __destroy_license(str strlic, str licpath='LICENSE'):
    cdef int l = _random.randint(0, len(strlic) - 2)
    cdef list b = range(48, 58)
    b.extend(range(65, 91))
    b.extend(range(97, 123))
    cdef int l2 = _random.randint(0, len(b))
    cdef str slic = "{0}{1}{2}{3}{4}{5}".format(strlic[:l], chr(b[l2]), strlic[l:len(strlic) - 2], str(l), len(str(l)),
                                                strlic[len(strlic) - 2:])
    l = len(slic)
    cdef list llic = ["–" * 7 + "BEGIN LICENSE" + "–" * 7]
    llic.extend([slic[i: i + 27] for i in range(0, l, 27)])
    llic.append("–" * 8 + "END LICENSE" + "–" * 8)
    with open(licpath, 'w') as f:
        f.writelines([c + "\n" for c in llic])


cdef str __decrypt_string(str strCText, str strKey=""):
    if strCText.strip() == "":
        return strCText
    cdef str defkey = " good-bye@201408211755"
    cdef str key = _base64.b64encode(strKey + defkey)[:32]
    mode = _AES.MODE_ECB
    decryptor = _AES.new(key, mode)
    cdef str plaintext = decryptor.decrypt(_base64.b64decode(strCText)).strip()
    return plaintext

    
cdef str __load_license(str licpath='LICENSE'):
    cdef list lic = []
    try:
        with open(licpath, "rU") as f:
            lic = f.readlines()
    except:
        return "err:License file not found."
    cdef str s = ""
    for l in lic:
        if l.startswith("–" * 7) or l.strip() == "":
            continue
        s += l.strip()
    if s == "":
        return "err:License file data error."
    cdef int x = int(s[8])
    cdef int lx = int(s[23:23 + x])
    s = s[lx + x + 2:].swapcase()
    try:
        ss = _zlib.decompress(_base64.b64decode(s))
        lx = len(ss)
        m = ss[lx - 3::-1] + ss[lx - 2:]
        ss = __decrypt_string(m.swapcase())
        ss = ss.replace('{','').replace('}','')
        lss = ss.split(',')
        mlic = {}
        for j in lss:
            mlic[j.split(':')[0]] = int(j.split(':')[1])
        # mlic = _json.loads(ss)
        x = mlic["deadline"] - int(_time.time())
        if x < 0:
            __destroy_license(s, licpath)
            return "err:Current license has expired!"
    except:
        return "err:License file load error."
    
    return 'The license will expire in {0} days {1} hours.'.format(x / 3600 / 24, x / 3600 % 24)


cpdef str loadLicense(str licpath='LICENSE'):
    return __load_license(licpath)
