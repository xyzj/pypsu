# -*- coding: utf-8 -*-

__version__ = "0.9"
__author__ = 'minamoto'
__doc__ = 'Perhaps something useful'

from Crypto.Cipher import AES as _AES
import base64 as _base64
import zlib as _zlib
import time as _time
import random as _random
import json as _json


cdef int __time2stamp(str timestr, int tocsharp=0, str format_type='%Y-%m-%d %H:%M:%S'):
    try:
        if tocsharp:
            return int(_time.mktime(_time.strptime(timestr, format_type)) * 10000000 + 621356256000000000)
        else:
            return int(_time.mktime(_time.strptime(timestr, format_type)))
    except:
        return 0

cdef str __buildhistory():
    cdef str s = """
    2007-12-07  We met ...
    2009-01-28  We conducted the first trip ...
    2009-07-20  We got our marriage certificate ...
    2010-06-05  We got married ...
    2010-12-??  You're pregnant ...
    2011-09-15  We had our lovely daughter ...
    2013-05-01  You are sick ...
    2014-06-05  We welcome our 5th wedding anniversary ...
    2014-08-19  You have your 31 birthday ...
    2014-08-21 17:55  You left me and our daughter forever ...

    NNNNNNNNWWWWWWWWWWWWWWWWWWWWWWWMKNNN..0WNNNNNNNN
    NNNNNNNWWWWWWWWWWWMMMMMMMMMMMOOWWWWWWN..KWNNNNNN
    NNNNNNWWWWWWWWWWMMMMMMMMMMMMt..XWWWWWWWX..WWNNNN
    NNNNNWWWWWWWWWMMMMMMMMWXXWMMMMi.MMWWWWWWW.OONNNN
    NNNNWWWWWWWWWMMMMMMMM..KX...OMM..XMMWWWWM.ttNNNN
    NNNNWWWWWWWWWMMMMMMMi.WMMMMM.xMMX...XWW0..NNNNNN
    NNNNWWWWWWWWWMW.......WMMMMMK.MMMWWW....WWNNNNNN
    NNNNNWWWWWWWWN.KMMMMMMMMMMMM0.MMMWWWWWWWWWNNNNNN
    NNNNNNWWWWWWWK.KMMMMMMMMMMMM.xMWWWWWWWWWWNNNNNNN
    NNNNNN...MWWWW0.rNWWWWWNWM...NWWWWWWWWWWNWNNNNNN
    NNWWr....KWWWWWMW............MWWWWWWWWWNNNNNNNNN
    NNNNNWNWW....WWWWWWWWWWWWWMMWWWWWWWWWNNNNNNNNNNN
    NNNNNNNNNNMM..rWNNWWWWWWWWWWWWWWWWNNNNNNNNNNNNNX
    XNNNNNNNNNNNNM....WWWWWWWWWWWWNNNNNNNNNNNNNNNXXX
    XXXXXNNNNNNNNX..XWNNNNNNNNNNNNNNNNNNNNNNNNNNXXXX
    """

    cdef list b = []
    cdef str d = ""
    cdef str ff = ""
    for x in s:
        b.append(hex(ord(x) - 8))

    for c in b:
        ff += chr(int(c, 16))
        d += c + ", "
    # print(d[:len(d) - 2])
    with open('.OURHISTORY', 'w') as f:
        f.write(d)
    with open("OURHISTORY", "w") as f:
        f.writelines(ff)
    return None


cdef str __destroy_license(str strlic, str licpath='LICENSE'):
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
    return None


cdef str __decrypt_string(str strCText, str strKey=""):
    if strCText.strip() == "":
        return strCText
    cdef str defkey = " good-bye@201408211755"
    cdef str key = _base64.b64encode(strKey + defkey)[:32]
    mode = _AES.MODE_ECB
    decryptor = _AES.new(key, mode)
    cdef str plaintext = decryptor.decrypt(_base64.b64decode(strCText)).strip()
    return plaintext


cdef str __encrypt_string(str strText, str strKey=""):
    if strText.strip() == "":
        return strText
    cdef str defkey = " good-bye@201408211755"
    cdef str key = _base64.b64encode(strKey + defkey)[:32]
    mode = _AES.MODE_ECB
    encryptor = _AES.new(key, mode)
    cdef str ciphertext = _base64.b64encode(encryptor.encrypt(strText.rjust(((len(strText) / 16) + 1) * 16)))
    return ciphertext


cdef str __build_history():
    __buildhistory()
    cdef str ss = ""
    with open("OURHISTORY", "r") as f:
        ss = f.readline()
    cdef str oh = ""
    for s in ss:
        oh += chr(ord(s) + 8)

    cdef str a = _base64.b64encode(oh)
    cdef int x = a.count("=")
    cdef int l = len(a)
    return "{0}{1}{2}{3}{4}{5}".format(a[:7], len(str(l)), x, a[7:16], l, a[16:]).replace("=", "z")


cdef str __generate_license(int deadline_year, int max_client=2100):
    zlic = {"deadline": __time2stamp('{0}-08-21 17:55:00'.format(deadline_year)),
                "maxclients": max_client}
    cdef str lic = _json.dumps(zlic, separators=(',', ':'))
    cdef str slic = __encrypt_string(lic).swapcase()
    cdef int l = len(slic)
    cdef str sl = slic[l - 3::-1] + slic[l - 2:]
    slic = _base64.b64encode(_zlib.compress(sl, 9)).swapcase()
    slic = __build_history() + slic
    l = len(slic)
    cdef list llic = ["–" * 7 + "BEGIN LICENSE" + "–" * 7]
    llic.extend([slic[i: i + 27] for i in range(0, l, 27)])
    llic.append("–" * 8 + "END LICENSE" + "–" * 8)
    with open("LICENSE", 'w') as f:
        f.writelines([c + "\n" for c in llic])
    return 'License generation success.'


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
    cdef int x = int(s[7])
    cdef int lx = int(s[18:18 + x])
    s = s[lx + x + 2:].swapcase()
    try:
        ss = _zlib.decompress(_base64.b64decode(s))
        lx = len(ss)
        m = ss[lx - 3::-1] + ss[lx - 2:]
        ss = __decrypt_string(m.swapcase())
        mlic = _json.loads(ss)
        x = mlic["deadline"] - int(_time.time())
        if x < 0:
            __destroy_license(s, licpath)
            return "err:Current license has expired!"
    except:
        return "err:License file load error."
    
    return 'The license will expire in {0} days {1} hours.'.format(x / 3600 / 24, x / 3600 % 24)



def generate_license(int deadline_year, int max_client=2100):
    return __generate_license(deadline_year, max_client)


def load_license(str licpath='LICENSE'):
    return __load_license(licpath)