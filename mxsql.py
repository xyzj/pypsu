# -*- coding: utf-8 -*-

__version__ = "0.9"
__author__ = 'minamoto'
__doc__ = 'useful sql func'

try:
    import _mysql as mysql
except:
    pass
import Queue


class MXMariadb(object):

    def __init__(self,
                 host='127.0.0.1',
                 port=3306,
                 user='root',
                 pwd='1234',
                 conv={1: int,
                       2: int,
                       3: int,
                       4: float,
                       5: float,
                       8: int,
                       9: int},
                 client_flag=32 | 65536 | 131072,
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
        self.host = host
        self.port = port
        self.user = user
        self.pwd = pwd
        self.conv = conv
        self.client_flag = client_flag
        self.conn_queue = Queue.Queue(7)
        self.error_msg = ''
        self.show_debug = False

    def __del__(self):
        while self.conn_queue.qsize() > 0:
            cn = self.conn_queue.get_nowait()
            cn.close()
            del cn

    def _build_conn(self):
        try:
            cn = mysql.connect(host=self.host,
                               port=self.port,
                               user=self.user,
                               passwd=self.pwd,
                               conv=self.conv,
                               client_flag=self.client_flag,
                               connect_timeout=7)
            cn.set_character_set('utf8')
        except Exception as ex:
            self.error_msg = '_mysql conn error: {0}'.format(ex)
            if self.show_debug:
                print(self.error_msg)
            return None
        else:
            return cn

    def get_conn(self):
        '''获取mysql连接'''
        if self.conn_queue.qsize() == 0:
            cn = self._build_conn()
        else:
            try:
                cn = self.conn_queue.get(timeout=7)

                if not cn.stat().startswith('Uptime:'):
                    cn.close()
                    del cn
                    raise Exception('MySQL server has something wrong')
            except Exception as ex:
                cn = self._build_conn()
        return cn

    def put_conn(self, conn):
        '''回收mysql连接'''
        try:
            self.conn_queue.put_nowait(conn)
        except:
            conn.close()
            del conn

    def get_last_error_message(self):
        '''获取最近一次操作产生的错误信息, 获取后清空'''
        s = self.error_msg
        self.error_msg = ''
        return s

    def set_debug(self, debug):
        self.show_debug = debug

    def run_fetch(self, strsql):
        '''数据库访问方法，
            用于执行select类语句
        Return:
            结果集的集和'''
        if len(strsql) == 0:
            return None
        else:
            conn = self.get_conn()
            if conn is None:
                return None
            else:
                try:
                    conn.query(strsql)
                except Exception as ex:
                    self.error_msg = '_mysql fetch error: {0}'.format(ex)
                    try:
                        conn.close()
                    except:
                        pass
                    else:
                        del conn

                    if self.show_debug:
                        print(self.error_msg)
                else:
                    cur = conn.use_result()
                    d = None
                    if cur is not None:
                        d = cur.fetch_row(0)
                        del cur
                    else:
                        del cur
                    self.put_conn(conn)
                    return d

    def run_exec(self, strsql):
        '''数据库访问方法
            用于执行delet，insert，update语句，支持多条语句一起提交，用‘;’分割
        Return:
            [(affected_rows,insert_id),...]'''
        if len(strsql) == 0:
            return None
        conn = self.get_conn()
        if conn is None:
            return None
        x = []
        try:
            conn.query(strsql)
        except Exception as ex:
            self.error_msg = '_mysql exec error: {0}'.format(ex)
            if self.show_debug:
                print(self.error_msg)
            conn.close()
            del conn
        else:
            conn.use_result()
            x.append((conn.affected_rows(), conn.insert_id()))
            while conn.next_result() > -1:
                x.append((conn.affected_rows(), conn.insert_id()))

            self.put_conn(conn)
        return x
