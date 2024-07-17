import decimal
import pymysql
import psycopg2
import threading
import json
import datetime
from pymysql.err import MySQLError
from psycopg2.errors import Error

from flask import request, current_app
from werkzeug.local import LocalProxy
import logging

logger = LocalProxy(lambda: current_app.logger)

import os
env = os.environ

from dbutils.pooled_db import PooledDB, SharedDBConnection

# print(os.environ.get('DB_USER'))

class DBInstance:
    def __init__(self, database_type):
        try:
            self.type = database_type;
            if database_type == 'mysql':
                self.pool = PooledDB(
                    creator=pymysql,
                    maxconnections=None,
                    mincached=2,
                    maxcached=8,
                    blocking=True,
                    maxusage=None,
                    setsession=[],
                    ping=1,
                    host=env.get('DB_HOST'),
                    port=int(env.get('DB_PORT')),
                    user=env.get('DB_USER'),
                    password=env.get('DB_PASS'),
                    database=env.get('DB_NAME'),
                    charset="utf8",
                )
            elif database_type == 'postgres':
                self.pool = PooledDB(
                    creator=psycopg2,
                    maxconnections=None,
                    mincached=2,
                    maxcached=8,
                    blocking=True,
                    maxusage=None,
                    setsession=[],
                    ping=1,
                    host=env.get('DB_HOST'),
                    port=int(env.get('DB_PORT')),
                    user=env.get('DB_USER'),
                    password=env.get('DB_PASS'),
                    database=env.get('DB_NAME'),
                    charset="utf8",
                )
            else:
                raise Exception
            self.connection = self.pool.connection()
        except Exception as e:
            logger.error('Open connection error: %s'%e)
            raise

    def mutate(self, sqlphase):
        db = self.connection
        sql = None
        try:
            logger.info("Open db connection: %s" % (sqlphase))
            # 使用cursor()方法获取操作游标
            cursor = self.cursor()

            # SQL 更新语句
            sql = sqlphase
        
            # 执行SQL语句
            cursor.execute(sql)
            db.commit()
            return (True, [-1, sql])

        except MySQLError as err:
            # 发生错误时回滚
            if db:
                db.rollback()
            if sql:
                logger.error("SQL: %s [%s]" % (sql, err.args[0]))
                return (False, [err.args[0], sql])
            logger.error("%s" % (str(err)))
            return (False, [err.args[0]])
        except Error as err:
            # 发生错误时回滚
            if db:
                db.rollback()
            if sql:
                logger.error("SQL: %s [%s]" % (sql, err.args[0]))
                return (False, [err.args[0], sql])
            logger.error("%s" % (str(err)))
            return (False, [err.args[0]])
        finally:
            if db:
                # 关闭数据库连接
                logger.info("Close db connection")
                db.close()


    def query(self, cols, view, conditions=[], orderby=[]):
        db = self.connection
        sql = None
        try:
            # 打开数据库连接
            logger.info("Open db connection: %s" % (view))
            # 使用cursor()方法获取操作游标
            cursor = self.cursor()

            # SQL 查询语句
            sql = "SELECT %s FROM %s" % (', '.join(cols), view)
            if len(conditions) != 0:
                sql = sql + " WHERE %s" % (' AND '.join(conditions))
            if len(orderby) != 0:
                sql = sql + " ORDER BY %s" % (' , '.join(orderby))
            # print(sql)
            sql += ";"
        
            # 执行SQL语句
            cursor.execute(sql)
            # 获取所有记录列表
            res = cursor.fetchall()
            arr = []
            if res:
                for itemIndex in range(len(res)):
                    item = {}
                    for index in range(len(cols)):
                        item[cols[index]] = res[itemIndex][index]
                    arr.append(item)
            return (True, arr)
        except MySQLError as err:
            if sql:
                logger.error("SQL: %s [%s]" % (sql, err.args[0]))
                return (False, [err.args[0], sql])
            logger.error("%s" % (str(err)))
            return (False, [err.args[0]])
        except Error as err:
            if sql:
                logger.error("SQL: %s [%s]" % (sql, err.args[0]))
                return (False, [err.args[0], sql])
            logger.error("%s" % (str(err)))
            return (False, [err.args[0]])
        finally:
            if db:
                # 关闭数据库连接
                logger.info("Close db connection")
                db.close()
            

POOL = PooledDB(
    creator=pymysql,
    maxconnections=None,
    mincached=2,
    maxcached=8,
    blocking=True,
    maxusage=None,
    setsession=[],
    ping=1,
    host=env.get('DB_HOST'),
    port=int(env.get('DB_PORT')),
    user=env.get('DB_USER'),
    password=env.get('DB_PASS'),
    database=env.get('DB_NAME'),
    # host="localhost",
    # port=6612,
    # user="cranemagic",
    # password="cranemagic++=20211001",
    # database="cranemagic",
    charset="utf8",
)
# POOL = LocalProxy(current_app.pool)
# print(POOL)

class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            return float(o)
        super(DecimalEncoder, self).default(o)


class OnlyDateEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.date):
            return obj.strftime("%Y-%m-%d")
        else:
            return json.JSONEncoder.default(self, obj)
        # print(obj)


class DateEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.date):
            return obj.strftime("%Y-%m-%d %H:%M:%S")
        else:
            return json.JSONEncoder.default(self, obj)
        # print(obj)


class NoSecondEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.date):
            return obj.strftime("%Y-%m-%d %H:%M")
        else:
            return json.JSONEncoder.default(self, obj)
        # print(obj)

def datetimeEncoder(o):
    if isinstance(o, datetime.datetime):
        return o.__str__()


# FULLCOLS = {
#     'view_area': ['id', 'type', 'name',
#                   'length', 'width', 'height',
#                   'xAxis', 'yAxis', 'zAxis', 'degree',
#                   'xAxisCenter', 'yAxisCenter', 'zAxisCenter',
#                   'comment', 'warehouse_id', 'material_count'],
#     'view_equipment': ['id', 'type',
#                        'model_id', 'model_name', 'model_properties',
#                        'status', 'purchaseTime', 'startTime', 'lastModifiedTime', 'expiredTime',
#                        'comment', 'maxHeight', 'warehouse_id'],
#     'view_equipmentmodel': ['id', 'name', 'type', 'properties'],
#     'view_material': ['id', 'areaSeq', 'createTime', 'removeTime',
#                       'model_id', 'model_name', 'model_raws', 'model_thickness', 'model_length', 'model_width', 'model_height',
#                       'model_xAxisDelta', 'model_yAxisDelta', 'model_zAxisDelta',
#                       'area_id', 'area_type', 'area_name', 'area_length', 'area_width', 'area_height',
#                       'area_xAxis', 'area_yAxis', 'area_zAxis', 'area_degree', 'area_xAxisCenter', 'area_yAxisCenter', 'area_zAxisCenter', 'area_comment',
#                       'warehouse_id', 'warehouse_name', 'warehouse_address', 'warehouse_length', 'warehouse_width', 'warehouse_height', 'warehouse_maxHeight', 'warehouse_comment'],
#     'view_materialmodel': ['id', 'name', 'raws', 'thickness', 'length', 'width', 'height', 'xAxisDelta', 'yAxisDelta', 'zAxisDelta'],
#     'view_task': ['id',
#                   'crane_id', 'model_type', 'model_id', 'model_name', 'model_properties', 'model_status',
#                   'status',
#                   'sourceArea_id', 'sourceArea_type', 'sourceArea_name', 'sourceArea_length', 'sourceArea_width', 'sourceArea_height',
#                   'sourceArea_xAxis', 'sourceArea_yAxis', 'sourceArea_zAxis', 'sourceArea_degree',
#                   'sourceArea_xAxisCenter', 'sourceArea_yAxisCenter', 'sourceArea_zAxisCenter', 'sourceArea_comment',
#                   'targetArea_id', 'targetArea_type', 'targetArea_name', 'targetArea_length', 'targetArea_width', 'targetArea_height',
#                   'targetArea_xAxis', 'targetArea_yAxis', 'targetArea_zAxis', 'targetArea_degree',
#                   'targetArea_xAxisCenter', 'targetArea_yAxisCenter', 'targetArea_zAxisCenter', 'targetArea_comment',
#                   'materials', 'actionSeq',
#                   'sendTime', 'startTime', 'endTime', 'warehouse_id'],
#     'view_warehouse': ['id', 'name', 'address', 'length',
#                        'width', 'height', 'maxHeight', 'comment'],
#     'view_user': ['id', 'username', 'password', 'is_full_authority', 'authorities', 'phone', 'email', 'is_active'],
# }


# def connect(hostaddr, usr, pwd, hostport, database):
#     # 打开数据库连接
#     db = pymysql.connect(host=hostaddr, user=usr,
#                          password=pwd, port=hostport, db=database)

#     # 使用 cursor() 方法创建一个游标对象 cursor
#     cursor = db.cursor()

#     # 使用 execute()  方法执行 SQL 查询
#     cursor.execute("SELECT VERSION()")

#     # 使用 fetchone() 方法获取单条数据.
#     data = cursor.fetchone()

#     print("Database version : %s " % data)

#     # 关闭数据库连接
#     db.close()


def mutate(hostaddr, usr, pwd, hostport, database, sqlphase):
    db = None
    sql = None
    try:
        # 打开数据库连接
        # db = pymysql.connect(host=hostaddr, user=usr,
        #                     password=pwd, port=hostport, db=database)
        
        db = POOL.connection()
        logger.info("Open db connection: %s" % (sqlphase))
        # 使用cursor()方法获取操作游标
        cursor = db.cursor()

        # SQL 更新语句
        sql = sqlphase
    
        # 执行SQL语句
        cursor.execute(sql)
        # print("Success: %s" % sql)
        # 提交到数据库执行
        db.commit()
        # 关闭数据库连接
        # db.close()
        return (True, [-1, sql])
        return "Success: %s" % sql

    except MySQLError as err:
        
        # 发生错误时回滚
        if db:
            db.rollback()
        # 关闭数据库连接
        # db.close()
        if sql:
            logger.error("SQL: %s [%s]" % (sql, err.args[0]))
            return (False, [err.args[0], sql])
        logger.error("%s" % (str(err)))
        return (False, [err.args[0]])
        return "Error: %s" % sql
    finally:
        if db:
            # 关闭数据库连接
            logger.info("Close db connection")
            db.close()


def query(hostaddr, usr, pwd, hostport, database, cols, view, conditions=[], orderby=[]):
    db = None
    sql = None
    try:
        # 打开数据库连接
        # db = pymysql.connect(host=hostaddr, user=usr,
        #                     password=pwd, port=hostport, db=database)
        
        db = POOL.connection()
        logger.info("Open db connection: %s" % (view))
        # 使用cursor()方法获取操作游标
        cursor = db.cursor()

        # SQL 查询语句
        sql = "SELECT %s FROM %s" % (', '.join(cols), view)
        if len(conditions) != 0:
            sql = sql + " WHERE %s" % (' AND '.join(conditions))
        if len(orderby) != 0:
            sql = sql + " ORDER BY %s" % (' , '.join(orderby))
        # print(sql)
        sql += ";"
    
        # 执行SQL语句
        cursor.execute(sql)
        # 获取所有记录列表
        res = cursor.fetchall()
        arr = []
        if res:
            for itemIndex in range(len(res)):
                item = {}
                for index in range(len(cols)):
                    item[cols[index]] = res[itemIndex][index]
                arr.append(item)
        # 关闭数据库连接
        # db.close()
        return (True, arr)
    except MySQLError as err:
        # 关闭数据库连接
        # db.close()
        # print(err.args[0], type(err))
        if sql:
            logger.error("SQL: %s [%s]" % (sql, err.args[0]))
            return (False, [err.args[0], sql])
        logger.error("%s" % (str(err)))
        return (False, [err.args[0]])
        return "Error: unable to fetch data"
    finally:
        if db:
            # 关闭数据库连接
            logger.info("Close db connection")
            db.close()


def clean_outdate_task(hostaddr, usr, pwd, hostport, database):
    print('Cleaning Outdate Task...')
    