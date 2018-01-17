# -*- coding: utf-8 -*-

__version__ = "0.9"
__author__ = 'minamoto'
__doc__ = 'Perhaps something useful'

# from Crypto.Cipher import AES as _AES
import base64 as _base64
import zlib as _xlib
import time as _time
import json as _json
import random as _random
import hashlib as _hashlib
import bz2 as _bz2
import hashlib as _hashlib


def __time2stamp(timestr, tocsharp=0, format_type='%Y-%m-%d %H:%M:%S'):
    try:
        if tocsharp:
            return int(
                _time.mktime(_time.strptime(timestr, format_type)) * 10000000 +
                621356256000000000)
        else:
            return int(_time.mktime(_time.strptime(timestr, format_type)))
    except:
        return 0


def __buildhistory():
    s = """2007-12-07  We met ...
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

    b = []
    d = ""
    ff = ""
    for x in s:
        b.append(hex(ord(x) - 7))

    for c in b:
        ff += chr(int(c, 16))
        d += c + ", "
    # print(d[:len(d) - 2])
    with open('.OURHISTORY', 'w') as f:
        f.write(d)
    with open("OURHISTORY", "w") as f:
        f.writelines(ff)
    return None


def __destroy_license(strlic, licpath='LICENSE'):
    l = _random.randint(0, len(strlic) - 2)
    b = range(48, 58)
    b.extend(range(65, 91))
    b.extend(range(97, 123))
    l2 = _random.randint(0, len(b))
    slic = "{0}{1}{2}{3}{4}{5}".format(strlic[:l],
                                       chr(b[l2]), strlic[l:len(strlic) - 2],
                                       str(l),
                                       len(str(l)), strlic[len(strlic) - 2:])
    l = len(slic)
    llic = ["–" * 7 + "BEGIN LICENSE" + "–" * 7]
    llic.extend([slic[i:i + 27] for i in range(0, l, 27)])
    llic.append("–" * 8 + "END LICENSE" + "–" * 8)
    with open(licpath, 'w') as f:
        f.writelines([c + "\n" for c in llic])
    return None


# __decrypt_string(str strCText, str strKey=""):
#     if strCText.strip() == "":
#         return strCText
#     defkey = "good-bye@201408211755"
#     key = _base64.b64encode(strKey + defkey)[:32]
#     mode = _AES.MODE_ECB
#     decryptor = _AES.new(key, mode)
#     plaintext = decryptor.decrypt(_base64.b64decode(strCText)).strip()
#     return plaintext


def __decrypt_string(strCText, strKey=""):
    if strCText.strip() == "":
        return strCText
    return _bz2.decompress(_base64.b64decode(strCText.swapcase()))


def __encrypt_string(strText, strKey=""):
    md5 = _hashlib.md5()
    md5.update(strKey)
    if strText.strip(
    ) == "" or md5.hexdigest() != '0e9cf665704b62ef1d9e87680b6e3633':
        return strText
    print(_base64.b64encode(_bz2.compress(strText, 9)).swapcase())
    return _base64.b64encode(_bz2.compress(strText, 9)).swapcase()

    # __encrypt_string(str strText, str strKey=""):
    #     if strText.strip() == "":
    #         return strText
    #     defkey = "good-bye@201408211755"
    #     key = _base64.b64encode(strKey + defkey)[:32]
    #     mode = _AES.MODE_ECB
    #     encryptor = _AES.new(key, mode)
    #     ciphertext = _base64.b64encode(encryptor.encrypt(strText.rjust(((len(strText) / 16) + 1) * 16)))
    #     return ciphertext


def __build_history():
    ss = ""
    with open("OURHISTORY", "r") as f:
        ss = f.readline()
    oh = ""
    for s in ss:
        oh += chr(ord(s) + 7)

    a = _base64.b64encode(oh)
    x = a.count("=")
    l = len(a)
    return "{0}{1}{2}{3}{4}{5}".format(a[:8],
                                       len(str(l)), x, a[8:21], l,
                                       a[21:]).replace("=", "z")


def __generate_license(deadline_year, max_client=2100, strKey=""):
    zlic = {
        "deadline": __time2stamp('{0}-08-21 17:55:00'.format(deadline_year)),
        "maxclients": max_client
    }
    lic = _json.dumps(zlic, separators=(',', ':'))
    # lic = str(zlic).replace("'", "")
    slic = __encrypt_string(lic, strKey).swapcase()
    l = len(slic)
    sl = slic[l - 3::-1] + slic[l - 2:]
    slic = _base64.b64encode(_xlib.compress(sl, 9)).swapcase()
    slic = __build_history() + slic
    l = len(slic)
    llic = ['{0}BEGIN LICENSE{1}'.format('-' * 7, '-' * 7)]
    llic.extend([slic[i:i + 27] for i in range(0, l, 27)])
    llic.append('{0}END LICENSE{1}'.format('-' * 8, '-' * 8))
    with open("LICENSE", 'w') as f:
        f.writelines([c + "\n" for c in llic])
    with open(".LICENSE", 'w') as f:
        f.writelines([c + "\n" for c in llic])
    return 'License generation success.'


def __load_license(licpath='LICENSE'):
    lic = []
    try:
        with open(licpath, "rU") as f:
            lic = f.readlines()
    except:
        return "err:License file not found."
    s = ""
    for l in lic:
        if '-' * 7 in l or l.strip() == "":
            continue
        s += l.strip()
    if s == "":
        return "err:License file data error."
    x = int(s[8])
    lx = int(s[23:23 + x])
    s = s[lx + x + 2:].swapcase()
    try:
        ss = _xlib.decompress(_base64.b64decode(s))
        lx = len(ss)
        m = ss[lx - 3::-1] + ss[lx - 2:]
        ss = __decrypt_string(m.swapcase())
        # ss = ss.replace('{','').replace('}','')
        # lss = ss.split(',')
        # for j in lss:
        #     mlic[j.split(':')[0]] = int(j.split(':')[1])
        mlic = _json.loads(ss)
        x = mlic["deadline"] - int(_time.time())
        if x < 0:
            __destroy_license(s, licpath)
            return "err:Current license has expired!"
    except:
        return "err:License file load error."

    return 'The license will expire in {0} days {1} hours.'.format(
        x / 3600 / 24, x / 3600 % 24)


def generate_license(deadline_year, max_client=2100, strKey=""):
    return __generate_license(deadline_year, max_client, strKey)


def load_license(licpath='LICENSE'):
    return __load_license(licpath)


def code_md5(src):
    '''
    Args:
    src (str)
    withsalt (bool): 0-False,1-True, saltstr is secret
    '''
    src = str(src) + ' ZhouJue@1983'
    md5 = _hashlib.md5()
    md5.update(src.encode('utf-8'))
    return md5.hexdigest()


def code_message(str_in):
    try:
        oh = ''
        x = _random.randint(1, 128)
        oh = chr(x)
        for s in str_in:
            oh += chr(ord(s) + x)
        return _base64.b64encode(oh).swapcase().replace('=', '')
    except:
        return 'You screwed up.'


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


def code_string(str_in, scode=''):
    '''
    Args:
        str_in (str): input string
    Return:
        code string
    '''
    try:
        if code_md5(scode) == '17e08ec6e74ecc4f22c59f32d2218c5a':
            x = _random.randint(10, 99)
            y = _xlib.compress(str_in[::-1])[:1:-1]
            z = ''.join([
                chr(ord(a) + x if ord(a) <= 255 - x else ord(a) + x - 256)
                for a in y
            ])
            return _base64.b64encode('{0}{1}'.format(x, z)).swapcase().replace(
                '=', '')
        else:
            return _base64.b64encode(str(_time.time())).replace('=', '')
    except:
        return 'You screwed up.'


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
    except:
        return 'You screwed up.'
