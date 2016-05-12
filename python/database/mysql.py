#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Abstract: MySQLdb & Model
"""Mysql"""

import time
import json
import logging

import MySQLdb


class Mysql(object):
    """
    MySQLdb Wrapper
    """
    min_cycle, max_cycle, total_time, counter, succ, fail, ext = 0xffffL, 0L, 0L, 0L, 0L, 0L, ''

    def __init__(self, dba, ismaster=False):
        self.dba = dba
        self.ismaster = ismaster
        self.conn = None
        self.cursor = None
        self.curdb = ""
        self.connect(dba)
        self.reset_stat()

    def __del_(self):
        self.close()

    def __repr__(self):
        return "Mysql(%s)" % (str(self.dba), )

    def __str__(self):
        return "Mysql(%s)" % (str(self.dba), )

    def close(self):
        """close"""
        if self.cursor:
            self.cursor.close()
            self.cursor = None
        if self.conn:
            self.conn.close()
            self.conn = None

    def connect(self, dba):
        """
        connect to mysql server
        """
        self.dba = dba
        self.conn = MySQLdb.connect(host=str(dba['host']),
                                    user=str(dba['user']),
                                    passwd=str(dba['passwd']),
                                    db=str(dba['db']),
                                    unix_socket=str(dba['sock']),
                                    port=dba['port'])
        self.cursor = self.conn.cursor(cursorclass=MySQLdb.cursors.DictCursor)
        self.execute("set names 'utf8'")
        self.execute("set autocommit=1")
        self.curdb = dba['db']
        return True

    def auto_reconnect(self):
        """
        ping mysql server
        """
        try:
            self.conn.ping()
        except Exception, e:
            try:
                self.cursor.close()
                self.conn.close()
            except:
                pass
            self.connect(self.dba)
        return True

    def execute(self, sql, values=()):
        """
        execute sql
        """
        if not self.ismaster and self.isupdate(sql):
            raise Exception("cannot execute[%s] on slave" % (sql, ))
        start = time.time()
        self.auto_reconnect()
       #if options.debug:
       #    logging.info('%s,%s', sql, values)
        if sql.upper().startswith("SELECT"):
            result = self.cursor.execute(sql, values)
        else:
            result = self.cursor.execute(sql)
        self.update_stat((time.time() - start) * 1000, sql, values)
        return True

    def update_stat(self, t, sql, values):
        self.__class__.min_cycle = min(self.min_cycle, t)
        if t > self.__class__.max_cycle:
            self.__class__.max_cycle = t
            self.__class__.ext = '%s%%%s' % (sql, str(values))
        self.__class__.total_time += t
        self.__class__.counter += 1
        self.__class__.succ += 1

    @classmethod
    def reset_stat(cls):
        cls.min_cycle, cls.max_cycle, cls.total_time, cls.counter, cls.succ, cls.fail, cls.ext = 0xffffL, 0L, 0L, 0L, 0L, 0L, ''

    @classmethod
    def stat(cls):
        return cls.min_cycle, cls.max_cycle, cls.total_time, cls.counter, cls.succ, cls.fail, cls.ext

    def isupdate(self, sql):
        """
        """
        opers = ("INSERT", "DELETE", "UPDATE", "CREATE", "RENAME", "DROP",
                 "ALTER", "REPLACE", "TRUNCATE")
        return sql.strip().upper().startswith(opers)

    def use_dbase(self, db):
        if self.curdb != db:
            self.execute("use %s" % (db, ))
            self.curdb = db
        return True

    @classmethod
    def create_sql(cls, sql, params, noescape=""):
        """
        create sql acorrding to sql and params
        """
        result = sql
        for each in params:
            val = params[each]
            if noescape == "" or noescape.find(each) < 0:
                val = MySQLdb.escape_string(str(val))
            result = result.replace(each, val)
        return result

    @classmethod
    def merge_sql(cls, where, cond):
        """
        merge subsqls
        """
        return "%s AND %s" % (where, cond) if where and cond else (where or
                                                                   cond)

    def rows(self):
        return self.cursor.fetchall()

    @property
    def lastrowid(self):
        return self.cursor.lastrowid

    def affected_rows(self):
        return self.conn.affected_rows()

    def connection(self):
        return self.conn


class MysqlPool(object):
    """
    MySQLPool
    """

    def __init__(self, dbcnf):
        self.mcnf, self.scnf = {}, {}
        for i in dbcnf['m']:
            for j in dbcnf['m'][i]:
                self.mcnf[j] = json.loads(i)
        for i in dbcnf['s']:
            for j in dbcnf['s'][i]:
                self.scnf[j] = json.loads(i)
        self.mpool, self.spool = {}, {}

    def get_server(self, mql_db, dbgroup, ismaster=False):
        """get servere"""
        cnf = (self.mcnf if ismaster else self.scnf)[dbgroup]
        cnf['db'] = mql_db
        dbastr = '%s:%s:%s' % (cnf['host'], cnf['port'], cnf['db'])
        pool = self.mpool if ismaster else self.spool
        if dbastr not in pool:
            logging.info('--->get_server:%s,%s,%s,%s', mql_db, dbgroup, dbastr,
                         len(pool))
            pool[dbastr] = Mysql(cnf, ismaster=ismaster)
        return pool[dbastr]

    def disconnect_all(self):
        """disconnect"""
        for i in self.mpool:
            self.mpool[i].close()
        for i in self.spool:
            self.spool[i].close()
