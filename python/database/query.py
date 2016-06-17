#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Abstract: MySQLdb & Model
""" query, MutilQuery, page, transaction"""
from mysql import Mysql


class Query(object):
    """ query
    """

    def __init__(self,
                 model=None,
                 qtype="SELECT *",
                 as_condition=True,
                 **kargs):
        self.model = model
        self.cache = None
        self.qtype = qtype
        # 2013.12.06 yugang update
        # self.conditions = {}
        self.conditions = self.init_condition(**kargs) if as_condition else {}
        self.limit = ()
        self.extras = []
        self.order = ""
        self.group = ""
        self.placeholder = "%s"
        self.kargs = kargs  # used to choose table & dbase

    def __getitem__(self, k):
        if self.cache:
            return self.cache[k]
        if isinstance(k, (int, long)):
            self.limit = (k, 1)
            lst = self.data()
            if not lst:
                return None
            return lst[0]
        elif isinstance(k, slice):
            if k.start is not None:
                assert k.stop is not None, "Limit must be set when an offset is present"
                assert k.stop >= k.start, "Limit must be greater than or equal to offset"
                self.limit = k.start, (k.stop - k.start)
            elif k.stop is not None:
                self.limit = 0, k.stop
        return self.data()

    def __len__(self):
        return len(self.data())

    def __iter__(self):
        return iter(self.data())

    def __repr__(self):
        return repr(self.data())

    def query_template(self):
        return "{QTYPE} FROM {TABLE} {CONDITION} {GROUP} {ORDER} {LIMIT}".format(
            QTYPE=self.qtype,
            TABLE=self.model.get_table(**self.kargs),
            CONDITION=self.get_condition_keys(),
            GROUP=self.group,
            ORDER=self.order,
            LIMIT=self.get_limit()
        )

    # condition(where) 相关
    def filter(self, **kwargs):
        """相等的条件, self.conditions"""
        self.cache = None
        self.conditions.update(kwargs)
        return self

    def extra(self, *args):
        """其他条件, self.extras"""
        self.cache = None
        self.extras.extend([e for e in args if e])
        return self

    def get_condition_keys(self):
        where = ""
        if self.conditions:
            where = ' AND '.join("`%s`=%s" % (str(k), self.placeholder)
                                 for k in self.conditions)
        if self.extras:
            where = Mysql.merge_sql(
                where,
                ' AND '.join([i.replace('%', '%%') for i in self.extras]))
        return "WHERE %s" % (where, ) if where else ""

    def clear_extras(self, ext=None):
        if ext:
            exist_ext = []
            for x in ext:
                for con in self.extras:
                    if con.find(x) > 0 and con not in exist_ext:
                        exist_ext.append(con)
            self.extras = exist_ext
        else:
            self.extras = []
        return self

    def _ex_condition(self):
        '''
            排除条件
        '''
        for item in self.extras:
            for condition in self.conditions.copy():
                # 如果条件在extras里面，则在conditions里面移除
                if not item[0:30].find(condition) < 0:
                    self.conditions.pop(condition)

    def init_condition(self, **kargs):
        '''
            用构造参数初始化条件
        '''
        conditions = {}
        for key, value in kargs.items():
            if str(key) in self.model._fields and value is not None:
                conditions[key] = value
        return conditions

    def get_condition_values(self):
        # 20131210 yugang add,排除条件
        self._ex_condition()
        return list(self.conditions.itervalues())
    # condition(where) 相关结束

    def orderby(self, field, direction='ASC'):
        self.cache = None
        self.order = 'ORDER BY %s %s' % (field, direction)
        return self

    def orderbys(self, fields):
        self.cache = None
        self.order = 'ORDER BY %s ' % (fields)
        return self

    def groupby(self, field):
        self.cache = None
        self.group = 'GROUP BY `%s`' % (field, )
        return self

    def set_limit(self, start, size):
        self.limit = start, size
        return self

    def get_limit(self):
        return "LIMIT %s" % ', '.join(
            str(i) for i in self.limit) if self.limit else ""
    # 查询条件相关结束

    def count(self):
        if self.cache is None:
            _qtype = self.qtype
            self.qtype = 'SELECT COUNT(1) AS CNT'
            rows = self.query()
            self.qtype = _qtype
            return rows[0]["CNT"] if rows else 0
        else:
            return len(self.cache)

    def data(self):
        if self.cache is None:
            self.cache = list(self.iterator())
        return self.cache

    def iterator(self):
        """组装mysql返回的数据，并返回"""
        for row in self.query():
            obj = self.model.__class__(
                row,
                db=self.model.db,
                ismaster=self.model.ismaster
            )
            obj._changed = set([])
            yield obj

    def query(self):
        """实际调用mysql获取数据的方法"""
        values = self.get_condition_values()
        return self.model.raw(self.query_template(), values, **self.kargs)


class Page(object):
    '''
        分页: start,end适用于mysql的limit
    '''

    def __init__(self, record_number, page_size, current_page):
        self.record_number = record_number
        self.page_size = page_size
        self.current_page = max(current_page, 1)
        self.page_total = (record_number + page_size - 1) / page_size
        self.current_page = min(self.current_page, self.page_total)
        self.start = 0 if self.current_page == 1 else (
            self.current_page - 1) * page_size
        self.end = self.current_page * page_size
        self.end = self.end if self.end < record_number else record_number


class MutilQuery(Query):
    '''
        多表关联查询, 多了一个set_table 方法, 可以指定table的类型（join之后的）
    '''

    def __init__(self, model=None, qtype="SELECT *", **kargs):
        super(MutilQuery, self).__init__(model, qtype, **kargs)

    def set_table(self, table):
        self.table = table

    def get_table(self):
        return self.table if hasattr(self, "table") \
            else self.model.get_table(**self.kargs)

    # todo 去掉？
    def query_template(self):
        return '%s FROM %s %s %s %s %s' % (self.qtype,
                                           self.get_table(),
                                           self.get_condition_keys(),
                                           self.group,
                                           self.order,
                                           self.get_limit(), )


class Transaction(object):
    '''
        事物对象
    '''

    def __init__(self, model):
        '''
            构造,注入model
            @model, Model, model对象
        '''
        self.model = model

    def begin(self):
        '''
            开事物
        '''
        self.model.begin_transaction()

    def commit(self):
        '''
            提交事物
        '''
        self.model.commit_transaction()

    def rollback(self):
        '''
            回滚事物
        '''
        self.model.rollback()

    def __enter__(self):
        '''
            with前置操作
        '''
        self.begin()
        return self

    def __exit__(self, exc_type, exc_val, exc_trace):
        '''
            with后置操作
        '''
        if exc_type:
            self.rollback()
        else:
            try:
                self.commit()
            except:
                self.rollback()
                raise
