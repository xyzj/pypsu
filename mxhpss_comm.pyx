# -*- coding: utf-8 -*-

__author__ = 'minamoto'
__ver__ = '0.1'
__doc__ = 'High-performance socket service common module'

from Crypto.Cipher import AES as _AES
from Crypto.Hash import MD5 as _MD5
import random as _random
import json as _json
import zlib as _zlib
import time as _time
import base64 as _base64


cpdef str hash_md5(str sargs):
    """Summary

    Args:
        sargs (TYPE): Description

    Returns:
        TYPE: Description
    """
    m = _MD5.new()
    m.update(sargs)
    return m.hexdigest()


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
        with open(licpath, 'rU') as f:
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
    cdef int x = int(s[7])
    cdef int lx = int(s[18:18 + x])
    s = s[lx + x + 2:]
    try:
        ss = _zlib.decompress(_base64.b64decode(s))
        lx = len(ss)
        m = ss[lx - 3::-1] + ss[lx - 2:]
        ss = __decrypt_string(m.swapcase())
        mlic = _json.loads(ss)
        mlic["timediff"] = mlic["deadline"] - int(_time.time())
        if mlic["timediff"] < 0:
            __destroy_license(s, licpath)
            return "err:Current license has expired！"
    except:
        return "err:License file load error."

    return str(mlic["timediff"])


cpdef str load_license(str licpath='LICENSE'):
    return __load_license(licpath)
