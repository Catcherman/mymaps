#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Abstract: MySQLdb & Model
"""model对象"""
import datetime
import logging

import MySQLdb

from mysql import MysqlPool
from query import MutilQuery, Query
from query import Transaction
DB_CNF = ''


class Model(dict):
    """
    Model
    """
    _db = ""
    _table = ""
    _fields = set()
    _extfds = set()
    _pk = ""
    _scheme = ()
    _engine = "InnoDB"
    _charset = "utf8"

    def __init__(self, obj={}, db=None, ismaster=False, **kargs):
        self.ismaster = ismaster
        self.db = db or self.dbserver(**kargs)
        super(Model, self).__init__(obj)
        # 20131018 yugang update 如果在构造成传入字典，将它们中属于表字段的标识为更改
        # self._changed = set()
        self._changed = set([e for e in obj if e in self._fields]) if obj else set() 
    def dbserver(self, **kargs):
        db, group = self.get_dbase(**kargs), self.get_db_group(**kargs)
        return self.dpool.get_server(db, group, self.ismaster)

    @property
    def dpool(self):
        if not hasattr(Model, '_dpool'):
            Model._dpool = MysqlPool(DB_CNF)
        return Model._dpool

    def __getattr__(self, name):
        if name in self._fields or name in self._extfds:
            return self.__getitem__(name)

    def __setattr__(self, name, value):
        flag = name in self._fields or name in self._extfds
        if name != '_changed' and flag and hasattr(self, '_changed'):
            if name in self._fields:
                self._changed.add(name)
            super(Model, self).__setitem__(name, value)
        else:
            self.__dict__[name] = value

    def __setitem__(self, name, value):
        if name != '_changed' and name in self._fields and hasattr(self,
                                                                   '_changed'):
            self._changed.add(name)
        super(Model, self).__setitem__(name, value)

    def __getitem__(self, k):
        value = super(Model, self).__getitem__(k)
        if isinstance(value, datetime.datetime):
            value = value.strftime("%Y-%m-%d %H:%M:%S")
        return value

    def __delattr__(self, name):
        self.__delitem__(name)

    def begin_transaction(self):
        '''
            通过关闭自动提交，来支持事务
        '''
        self.db.execute("SET autocommit=0")

    def commit_transaction(self):
        '''
            提交事务，并开启自动提交
        '''
        self.db.execute("COMMIT")
        self.db.execute("SET autocommit=1")

    def rollback(self):
        '''
            回滚,关闭连接，事务就自动回滚
        '''
        self.db.close()

    def transaction(self):
        '''
            事物操作
            with model.transaction():
                pass
        '''
        return Transaction(self)

    def init_table(self, **kargs):
        dbase = self.get_dbase(**kargs)
        if not self.is_dbase_exist(**kargs):
            self.db.execute("CREATE DATABASE %s" % (dbase, ))
        if not self.is_table_exist(**kargs):
            self.db.use_dbase(dbase)
            scheme = ",".join(self._scheme)
            sql = "CREATE TABLE `%s` (%s)ENGINE=%s DEFAULT CHARSET=%s"
            self.db.execute(sql % (self.get_table(**kargs), scheme,
                                   self._engine, self._charset))
        return True

    def drop_table(self, **kargs):
        dbase = self.get_dbase(**kargs)
        if not self.is_dbase_exist(**kargs):
            raise Exception('%s not exist' % dbase)
        if self.is_table_exist(**kargs):
            self.db.use_dbase(dbase)
            sql = "DROP TABLE `%s`" % self.get_table(**kargs)
            self.db.execute(sql)
        return True

    def replace(self):
        self.db.use_dbase(self.get_dbase(**self))
        sql = self.replace_sql()
        self.db.execute(sql)
        if self._pk and self._pk not in self:
            self[self._pk] = self.db.lastrowid
        return self

    def before_add(self):
        pass

    def add(self):
        self.before_add()
        self.db.use_dbase(self.get_dbase(**self))
        sql = self.insert_sql()
        self.db.execute(sql)
        if self._pk and (self._pk not in self or not self[self._pk]):
            self[self._pk] = self.db.lastrowid
    # return self
    # 20131018 yugang update
        return self.db.affected_rows()

    def before_update(self):
        pass

    def update(self, condition='', unikey=None):
        if self._changed:
            self._condition_sql = condition
            self.before_update()
            self.db.use_dbase(self.get_dbase(**self))
            sql = self.update_sql(condition, unikey)
            self.db.execute(sql)
            self._changed = set([])
            self._condition_sql = ""
            # 20131018 yugang add
            return self.db.affected_rows()
        return True  # todo: 返回False，None 可能 会合适点

    def save(self):
        # if self.get(self._pk,""):
        #    self.update()
        # else:
        #     self.add()
        # return self
        return self.update() if self.get(self._pk, "") else self.add()

    def before_delete(self):
        pass

    def delete(self, condition=None, unikey=None):
        self.before_delete()
        self.db.use_dbase(self.get_dbase(**self))
        sql = self.delete_sql(unikey, condition)
        self.db.execute(sql)
        # return True
        # 20131018 yugang update
        return self.db.affected_rows()

    @classmethod
    def mgr(cls, ismaster=False, **kargs):
        return cls(ismaster=ismaster, **kargs)

    @classmethod
    def new(cls, ismaster=True, **kargs):
        return cls(ismaster=ismaster, **kargs)

    def one(self, pk, ismaster=False):
        return self.mgr(ismaster).Q().extra('%s = %s' % (self._pk, pk))[0]

    def Q(self, **kargs):
        """
        Query
        """
        return Query(self, **kargs)

    def MutilQuery(self, **kargs):
        """
        Query
        """
        return MutilQuery(self, **kargs)

    def select(self, where, **kargs):
        table = self.get_table(**kargs)
        sql = self.select_sql(table, where)
        self.db.use_dbase(self.get_dbase(**kargs))
        self.db.execute(sql)
        return self.db.rows()

    def raw(self, sql, values=(), **kargs):
        """
        execute raw sql
        """
        self.db.use_dbase(self.get_dbase(**kargs))
        self.db.execute(sql, values)
        return self.db.rows()

    @property
    def lastrowid(self):
        return self.db.lastrowid

    def get_db_group(self, **kargs):
        """
        get db group
        """
        return self._db

    def get_dbase(self, **kargs):
        """
        get db name
        """
        return self._db

    def get_table(self, **kargs):
        """
        get table name
        """
        return self._table

    def set_table(self, tables):
        """
        set table name
        """
        if not tables:
            return
        else:
            self._table = tables

    def is_dbase_exist(self, **kargs):
        dbase = self.get_dbase(**kargs)
        sql = "select SCHEMA_NAME from information_schema.SCHEMATA where SCHEMA_NAME = '%s'"
        self.db.execute(sql % (dbase, ))
        rows = self.db.rows()
        return True if rows else False

    def is_table_exist(self, **kargs):
        """
        判断表是否已经存在
        """
        dbname = self.get_dbase(**kargs)
        tablename = self.get_table(**kargs)
        values = (tablename, dbname)
        sql = "select TABLE_NAME from information_schema.TABLES where TABLE_NAME='%s' AND TABLE_SCHEMA='%s'"
        self.db.execute(sql % values)
        rows = self.db.rows()
        return True if rows else False

    def insert_sql(self):
        obj = self
        table = self.get_table(**obj)
        domains = ','.join(["`%s`" % (e, )
                            for e in obj
                            if e in self._fields and obj[e] is not None])
        values = ','.join(["'%s'" % (MySQLdb.escape_string(str(obj[e].encode('utf-8')) if isinstance(obj[e], unicode) else str(obj[e])), )
                           for e in obj if e in self._fields and obj[e] is not None])
        return "INSERT INTO %s (%s) VALUES (%s)" % (table, str(domains),
                                                    str(values))

    def insert_batch(self, sql, values):
        '''
        批量导入操作

        sql = "insert into bk_comment(title) values(%s)"

        values = [('ninini'), ('koko')]
        '''
        try:
            cursor = self.db.conn.cursor()
            sum = 0
            count = 0
            circle = 1000
            while sum < len(values):
                temp_values = values[count * circle:(count + 1) * circle - 1]
                sum = (count + 1) * circle - 1
                count += 1
                cursor.executemany(sql, temp_values)
                self.db.conn.commit()
        except Exception, e:
            logging.error("------%s" % str(e))
        finally:
            if cursor:
                cursor.close()
            cursor = None
            self.db.close()

    def replace_sql(self):
        obj = self
        table = self.get_table(**obj)
        domains = ','.join(["`%s`" % (e, ) for e in obj if e in self._fields])
        values = ','.join(["'%s'" % (MySQLdb.escape_string(str(obj[e])), )
                           for e in obj if e in self._fields])
        return "REPLACE INTO %s (%s) VALUES (%s)" % (table, domains, values)

    def update_sql(self, condition='', unikey=None):
        obj = self
        table = self.get_table(**obj)
        uni = unikey or self._pk
        values_up = ','.join(["`%s`='%s'" % (
            str(e),
            MySQLdb.escape_string(str(obj[e].encode('utf-8')) if isinstance(
                obj[e], unicode) else str(obj[e])), ) for e in obj
                              if e != uni and e in self._fields and e in
                              self._changed and obj[e] is not None])
        where_condition = condition if condition else "`%s`='%s'" % (
            uni, str(obj[uni]))
        return "UPDATE %s SET %s WHERE %s" % (table, values_up,
                                              where_condition)

    def delete_sql(self, unikey=None, condition=''):
        obj = self
        table = self.get_table(**obj)
        uni = unikey or self._pk
        where_condition = condition if condition else "`%s`='%s'" % (
            uni, str(obj[uni]))
        return "DELETE FROM %s WHERE %s" % (table, where_condition)

    def select_sql(self, table, where):
        return "SELECT * FROM %s %s %s" % (table, where and "WHERE" or "",
                                           where)
