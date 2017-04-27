# -*- coding: utf-8 -*-

__version__ = "0.9"
__author__ = 'minamoto'
__doc__ = 'useful sql func'

import _mysql as mysql
import Queue


class MXMariadb(object):

    def __init__(self,
                 host='127.0.0.1',
                 port=3006,
                 user='root',
                 pwd='1234',
                 conv={1: int,
                       2: int,
                       3: int,
                       4: float,
                       5: float,
                       8: int,
                       9: int},
                 flag=32 | 65536 | 131072,
                 maxconn=20):
        """mariadb访问类初始化
        Args:    
            host: mariadb服务器名
            port: mariadb服务端口
            user: mariradb访问用户名
            pwd:  mariadb访问密码
            conv: 字段类型自动转换设置
            flag: 客户端访问标记,默认压缩,允许多语句提交,允许多结果集
        """
        self.__host = host
        self.__port = port
        self.__user = user
        self.__pwd = pwd
        self.__conv = conv
        self.__flag = flag
        self.__conn_queue = Queue.Queue(20)
        self.__error_msg = ''
        self.__show_debug = False

    def __del__(self):
        while self.__conn_queue.qsize() > 0:
            cn = self.__conn_queue.get_nowait()
            cn.close()
            del cn

    def __get_conn(self):
        try:
            return self.__conn_queue.get_nowait()
        except:
            try:
                cn = mysql.connect(host=self.__host,
                                   port=self.__port,
                                   user=self.__user,
                                   passwd=self.__pwd,
                                   conv=self.__conv,
                                   client_flag=self.__flag,
                                   connect_timeout=7)
                cn.set_character_set('utf8')
            except Exception as ex:
                self.__error_msg = '_mysql conn error: {0}'.format(ex)
                if self.__show_debug:
                    print(self.__error_msg)
                return None
            else:
                return cn

    def __put_conn(self, conn):
        try:
            self.__conn_queue.put_nowait(conn)
        except:
            pass

    def run_fetch(self, strsql):
        '''数据库访问方法，
            用于执行select类语句
        Return:
            结果集的迭代器'''
        if len(strsql) == 0:
            return None
        else:
            conn = self.__get_conn()
            if conn is None:
                return None
            else:
                try:
                    conn.query(strsql)
                except Exception as ex:
                    self.__error_msg = '_mysql fetch error: {0}'.format(ex)
                    if self.__show_debug:
                        print(self.__error_msg)
                else:
                    cur = conn.use_result()
                    if cur is not None:
                        d = cur.fetch_row(0)
                        return d
                    else:
                        return None
                    del cur
                self.__put_conn(conn)

    def run_exec(self, strsql):
        '''数据库访问方法
            用于执行delet，insert，update语句，支持多条语句一起提交，用‘;’分割
            Return:
            [(affected_rows,insert_id),...]'''
        if len(strsql) == 0:
            return None
        conn = self.__get_conn()
        if conn is None:
            return None
        x = []
        try:
            conn.query(strsql)
        except Exception as ex:
            self.__error_msg = '_mysql exec error: {0}'.format(ex)
            if self.__show_debug:
                print(self.__error_msg)
        else:
            conn.use_result()
            x.append((conn.affected_rows(), conn.insert_id()))
            while conn.next_result() > -1:
                # if conn.next_result() == -1:
                #     break
                x.append((conn.affected_rows(), conn.insert_id()))

        self.__put_conn(conn)
        return x

    def get_last_error_message(self):
        return self.__error_msg

    def set_debug(self, debug):
        self.__show_debug = debug
