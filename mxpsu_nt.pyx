#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""通过调用API获取进程列表"""

import ctypes
import os

from mxpsu import SCRIPT_DIR


__metaclass__ = type


class PROCESSENTRY32(ctypes.Structure):
    _fields_ = [
        ("dwSize", ctypes.c_ulong),
        ("cntUsage", ctypes.c_ulong),
        ("th32ProcessID", ctypes.c_ulong),
        ("th32DefaultHeapID", ctypes.c_void_p),
        ("th32ModuleID", ctypes.c_ulong),
        ("cntThreads", ctypes.c_ulong),
        ("th32ParentProcessID", ctypes.c_ulong),
        ("pcPriClassBase", ctypes.c_long),
        ("dwFlags", ctypes.c_ulong),
        ("szExeFile", ctypes.c_char * 260)
    ]

def get_pid(imagename):
    kernel32 = ctypes.windll.LoadLibrary("kernel32.dll")
    phandle = kernel32.CreateToolhelp32Snapshot(0x2, 0x0)

    if phandle == -1:
        return -1

    proc = PROCESSENTRY32()
    proc.dwSize = ctypes.sizeof(proc)

    try:
        while kernel32.Process32Next(phandle, ctypes.byref(proc)):
            if ctypes.string_at(proc.szExeFile) == imagename:
                return proc.th32ProcessID
    except:
        print ("err")

    return -1


def get_image_count(imagename):
    kernel32 = ctypes.windll.LoadLibrary("kernel32.dll")
    phandle = kernel32.CreateToolhelp32Snapshot(0x2, 0x0)

    if phandle == -1:
        return -1

    proc = PROCESSENTRY32()
    proc.dwSize = ctypes.sizeof(proc)

    icount = 0
    try:
        while kernel32.Process32Next(phandle, ctypes.byref(proc)):
            if ctypes.string_at(proc.szExeFile) == imagename:
                icount += 1
    except:
        print ("err")

    return icount


def clean_mem(name=None):
    # BackupMydatabase()
    if not os.path.isfile(os.path.join(SCRIPT_DIR, "empty.exe")):
        return "can not found file empty.exe."

    kernel32 = ctypes.windll.LoadLibrary("kernel32.dll")
    phandle = kernel32.CreateToolhelp32Snapshot(0x2, 0x0)

    if phandle == -1:
        return "kernel32.dll handle error."

    proc = PROCESSENTRY32()
    proc.dwSize = ctypes.sizeof(proc)

    try:
        if name is None:
            while kernel32.Process32Next(phandle, ctypes.byref(proc)):
                sname = ctypes.string_at(proc.szExeFile)
                # print ("ProcessName : %s - ProcessID : %d"%(ctypes.string_at(proc.szExeFile),proc.th32ProcessID));
                os.system("empty.exe {0:s}".format(sname))
        else:
            while kernel32.Process32Next(phandle, ctypes.byref(proc)):
                sname = ctypes.string_at(proc.szExeFile)
                # print ("ProcessName : %s - ProcessID : %d"%(ctypes.string_at(proc.szExeFile),proc.th32ProcessID));
                if name in sname:
                    os.system("empty.exe {0:s}".format(sname))
    except Exception as ex:
        print(ex)

    kernel32.CloseHandle(phandle)
    return "mem release success."
