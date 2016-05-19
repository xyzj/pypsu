# -*- mode: python -*-

block_cipher = pyi_crypto.PyiBlockCipher(key='Bye-bye my love.')


a = Analysis(['planb.py'],
             pathex=['/home/minamoto/work/python/mxpsu'],
             binaries=None,
             datas=[('.LICENSE','.'),('OURHISTORY','.')],
             hiddenimports=['gevent','mxhpss_comm','mxpsu', 'json','uuid','greenlet','platform','logging.handlers','Crypto.Hash.MD5','Crypto.Cipher.AES'],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='pb',
          debug=False,
          strip=False,
          upx=False,
          console=True )
