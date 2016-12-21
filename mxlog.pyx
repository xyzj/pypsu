# -*- coding: utf-8 -*-

import os
import sys
from datetime import datetime, timedelta
import traceback
import threading
import codecs
import shutil

CRITICAL = 50
FATAL = CRITICAL
ERROR = 40
WARNING = 30
WARN = WARNING
INFO = 20
DEBUG = 10
NOTSET = 0

LOGLEVEL = {0: 'NOTSET', 10: 'DEBUG', 20: 'INFO', 30: 'WARN', 40: 'ERROR', 50: 'FATAL'}


class Logger():

    def __init__(self,
                 file_name=None,
                 log_level=10,
                 file_size=1024 * 1024 * 300,
                 roll_num=19,
                 roll_midnight=True):
        self.file_max_size = file_size
        self.buffer_lock = threading.Lock()
        self.buffer = {}  # id => line
        self.buffer_size = 1024
        self.last_no = 0
        self.min_level = NOTSET
        self.log_fd = None
        self.setColor()
        self.roll_num = roll_num
        self.roll_midnight = roll_midnight
        self.day = datetime.today().day
        self.setLevel(log_level)
        if file_name:
            self.setFile(file_name)

    def setBuffer(self, buffer_size):
        self.buffer_size = buffer_size

    def setLevel(self, log_level):
        global LOGLEVEL
        if log_level in LOGLEVEL.keys():
            level = LOGLEVEL[log_level]
        else:
            level = 'DEBUG'
        if level == "DEBUG":
            self.min_level = DEBUG
        elif level == "INFO":
            self.min_level = INFO
        elif level == "WARN":
            self.min_level = WARN
        elif level == "ERROR":
            self.min_level = ERROR
        elif level == "FATAL":
            self.min_level = FATAL
        else:
            print("log level not support:%s", level)

    def setColor(self):
        self.err_color = None
        self.warn_color = None
        self.debug_color = None
        self.reset_color = None
        self.set_console_color = lambda x: None
        if hasattr(sys.stderr, 'isatty') and sys.stderr.isatty():
            if os.name == 'nt':
                self.err_color = 0x04
                self.warn_color = 0x06
                self.debug_color = 0x002
                self.reset_color = 0x07

                import ctypes
                SetConsoleTextAttribute = ctypes.windll.kernel32.SetConsoleTextAttribute
                GetStdHandle = ctypes.windll.kernel32.GetStdHandle
                self.set_console_color = lambda color: SetConsoleTextAttribute(GetStdHandle(-11), color)

            elif os.name == 'posix':
                self.err_color = '\033[31m'
                self.warn_color = '\033[33m'
                self.debug_color = '\033[32m'
                self.reset_color = '\033[0m'

                self.set_console_color = lambda color: sys.stderr.write(color)

    def setFile(self, file_name):
        self.log_filename = file_name
        if os.path.exists(file_name):
            self.file_size = os.path.getsize(file_name)
        #     if self.file_size > self.file_max_size:
        #         self.rollLog(self.roll_midnight)
        #         self.file_size = 0
        else:
            self.file_size = 0

        self.log_fd = codecs.open(file_name, 'a', encoding='utf-8')

    def rollLog(self, roll_midnight=True):
        if roll_midnight:
            today = datetime.today()
            yesterday = today + timedelta(days=-1)
            new_name = "{0}.{1:}".format(self.log_filename, yesterday.strftime("%Y-%m-%d"))
            old_name = "{0}".format(self.log_filename)
            if os.path.exists(new_name):
                h = today.time().hour
                m = today.time().minute
                s = today.time().second
                os.rename(new_name, '{0}.{1}'.format(new_name, h * 60 * 60 + m * 60 + s))
            os.rename(old_name, new_name)
            p = os.path.dirname(self.log_filename)
            f = os.path.basename(self.log_filename) + '.'
            x = []
            c = 0
            for root, dirnames, filenames in os.walk(p):
                for fn in filenames:
                    if f in fn:
                        x.append(fn)
            x.sort()
            x.reverse()
            z = x[self.roll_num:]
            if len(z) > 0:
                for f in z:
                    try:
                        os.remove(os.path.join(p, f))
                    except:
                        pass
            # shutil.move(old_name, new_name)
        else:
            for i in range(self.roll_num - 1, 0, -1):
                sfn = "%s.%d" % (self.log_filename, i)
                dfn = "%s.%d" % (self.log_filename, i + 1)
                if os.path.exists(sfn):
                    # print "%s -> %s" % (sfn, dfn)
                    if os.path.exists(dfn):
                        os.remove(dfn)
                    os.rename(sfn, dfn)
            dfn = self.log_filename + ".1"
            if os.path.exists(dfn):
                os.remove(dfn)
            os.rename(self.log_filename, dfn)

    def formatLog(self, fmt, level, *args, **kwargs):
        if self.roll_midnight:
            time_str = datetime.now().strftime("%H:%M:%S.%f")[:12]
        else:
            time_str = datetime.now().strftime("%m-%d %H:%M:%S.%f")[:18]
        if os.name == 'nt':
            lineend = '\r\n'
        else:
            lineend = '\n'
        return '{0} [{1}] {2}{3}'.format(time_str, level, fmt, lineend)

    def resetFile(self):
        try:
            self.log_fd.close()
        except:
            pass
        self.log_fd = None
        self.rollLog(self.roll_midnight)
        self.log_fd = codecs.open(self.log_filename, "a", encoding='utf-8')
        self.file_size = 0

    def log(self, level, console_color, html_color, fmt, *args, **kwargs):
        string = self.formatLog(fmt, level, *args, **kwargs)
        if not os.path.isfile(self.log_filename):
            try:
                self.log_fd.close()
            except:
                pass
            self.log_fd = None
            self.log_fd = codecs.open(self.log_filename, 'a', encoding='utf-8')
            self.file_size = 0

        self.buffer_lock.acquire()
        try:
            self.set_console_color(console_color)
            try:
                sys.stderr.write(string)
            except:
                pass
            self.set_console_color(self.reset_color)

            if self.log_fd:
                if self.roll_midnight:
                    if self.day != datetime.today().day:
                        self.day = datetime.today().day
                        self.resetFile()
                else:
                    if self.file_size > self.file_max_size:
                        self.resetFile()

                self.log_fd.write(string)
                try:
                    self.log_fd.flush()
                except:
                    pass

                self.file_size += len(string)

            # if self.buffer_size:
            #     self.last_no += 1
            #     self.buffer[self.last_no] = string
            #     buffer_len = len(self.buffer)
            #     if buffer_len > self.buffer_size:
            #         del self.buffer[self.last_no - self.buffer_size]
        except Exception as e:
            string = '%s - [%s]LOG_EXCEPT: %s, Except:%s<br> %s' % (
                datetime.now().strftime("%m-%d %H:%M:%S.%f")[:14], level, fmt % args, e,
                traceback.format_exc())
            print(string)
            # self.last_no += 1
            # self.buffer[self.last_no] = string
            # buffer_len = len(self.buffer)
            # if buffer_len > self.buffer_size:
            #     del self.buffer[self.last_no - self.buffer_size]
        finally:
            self.buffer_lock.release()

    def writeLog(self, fmt, log_level=20, *args, **kwargs):
        if log_level == 0:
            string = self.formatLog(fmt, log_level, *args, **kwargs)
            self.set_console_color(self.debug_color)
            try:
                sys.stderr.write(string)
            except:
                pass
            self.set_console_color(self.reset_color)
        elif log_level == 10:
            self.debug(fmt, *args, **kwargs)
        elif log_level == 20:
            self.info(fmt, *args, **kwargs)
        elif log_level == 30:
            self.warning(fmt, *args, **kwargs)
        elif log_level == 40:
            self.error(fmt, *args, **kwargs)
        elif log_level == 50:
            self.critical(fmt, *args, **kwargs)
        else:
            print("log level not support: {0}".format(log_level))

    def debug(self, fmt, *args, **kwargs):
        if self.min_level > DEBUG:
            return
        self.log(DEBUG, self.debug_color, '21610b', fmt, *args, **kwargs)

    def info(self, fmt, *args, **kwargs):
        if self.min_level > INFO:
            return
        self.log(INFO, self.reset_color, '000000', fmt, *args, **kwargs)

    def warning(self, fmt, *args, **kwargs):
        if self.min_level > WARN:
            return
        self.log(WARN, self.warn_color, 'FF8000', fmt, *args, **kwargs)

    def warn(self, fmt, *args, **kwargs):
        self.warning(fmt, *args, **kwargs)

    def error(self, fmt, *args, **kwargs):
        if self.min_level > ERROR:
            return
        self.log(ERROR, self.err_color, 'FE2E2E', fmt, *args, **kwargs)

    def exception(self, fmt, *args, **kwargs):
        self.error(fmt, *args, **kwargs)
        self.error("Except stack:%s", traceback.format_exc(), **kwargs)

    def critical(self, fmt, *args, **kwargs):
        if self.min_level > CRITICAL:
            return
        self.log('CRITICAL', self.err_color, 'D7DF01', fmt, *args, **kwargs)

    # =================================================================
    # def setBufferSize(self, set_size):
    #     self.buffer_lock.acquire()
    #     self.buffer_size = set_size
    #     buffer_len = len(buffer)
    #     if buffer_len > self.buffer_size:
    #         for i in range(self.last_no - buffer_len, self.last_no - self.buffer_size):
    #             try:
    #                 del self.buffer[i]
    #             except:
    #                 pass
    #     self.buffer_lock.release()
    # 
    # def getLastLines(self, max_lines):
    #     self.buffer_lock.acquire()
    #     buffer_len = len(self.buffer)
    #     if buffer_len > max_lines:
    #         first_no = self.last_no - max_lines
    #     else:
    #         first_no = self.last_no - buffer_len + 1
    # 
    #     jd = {}
    #     if buffer_len > 0:
    #         for i in range(first_no, self.last_no + 1):
    #             jd[i] = self.unicodeLine(self.buffer[i])
    #     self.buffer_lock.release()
    #     return json.dumps(jd)
    # 
    # def getNewLines(self, from_no):
    #     self.buffer_lock.acquire()
    #     jd = {}
    #     first_no = self.last_no - len(self.buffer) + 1
    #     if from_no < first_no:
    #         from_no = first_no
    # 
    #     if self.last_no >= from_no:
    #         for i in range(from_no, self.last_no + 1):
    #             jd[i] = self.unicodeLine(self.buffer[i])
    #     self.buffer_lock.release()
    #     return json.dumps(jd)
    # 
    # def unicodeLine(self, line):
    #     try:
    #         # if type(line) is types.UnicodeType:
    #         if isinstance(line, types.UnicodeType):
    #             return line
    #         else:
    #             return unicode(line, errors='ignore')
    #     except Exception as e:
    #         print("unicode err:%r" % e)
    #         print("line can't decode:%s" % line)
    #         print("Except stack:%s" % traceback.format_exc())
    #         return ""


LOGGER_DICT = {}


def getLogger(name=None,
              file_name=None,
              log_level=10,
              file_size=1024 * 1024 * 20,
              roll_num=19,
              roll_midnight=1):
    """
    获取日志实例

    Args:
      name (str): 日志实例名称
      file_name (str): 日志保存完整路径
      file_size (int): 日志文件最大大小(按日期滚动时无效)
      roll_num (int): 日志文件最大数量
      roll_midnight (int): 是否按日期重命名日志文件
    """
    global LOGGER_DICT

    if not isinstance(name, basestring):
        raise TypeError('A logger name must be string or Unicode')
    if isinstance(name, unicode):
        name = name.encode('utf-8')

    if name in LOGGER_DICT:
        return LOGGER_DICT[name]
    else:
        logger_instance = Logger(file_name, log_level, file_size, roll_num, roll_midnight)
        LOGGER_DICT[name] = logger_instance
        return logger_instance


def removeLogger(name=None):
    global LOGGER_DICT
    if name in LOGGER_DICT.keys():
        try:
            del LOGGER_DICT[name]
        except:
            pass


def clearLogger():
    global LOGGER_DICT
    try:
        LOGGER_DICT.clear()
    except:
        pass
