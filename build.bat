SET VS90COMNTOOLS=%VS100COMNTOOLS%
copy /Y mxhpss.py mxhpss.pyx
copy /Y mxweb.py mxweb.pyx
copy /Y mxpsu.py mxpsu.pyx
copy /Y mxlog.py mxlog.pyx
copy /Y mxpbjson.py mxpbjson.pyx
copy /Y mxsql.py mxsql.pyx

python setup_nt.py build_ext -fi
copy /Y mx*.pyd c:\Python27\Lib\site-packages\
copy /Y mx*.pyd ..\mwsc\dist\bin\
:: del /Q ..\mwsc\dist\bin\mxsp_nt.pyd