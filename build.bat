SET VS90COMNTOOLS=%VS100COMNTOOLS%
python setup_nt.py build_ext -fi
copy /Y mx*.pyd c:\Python27\Lib\site-packages\