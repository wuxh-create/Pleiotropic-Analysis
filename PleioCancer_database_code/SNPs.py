from pymongo import MongoClient, ASCENDING, DESCENDING
from bson.son import SON
from pprint import pprint
from flask import request


##
# Class for managing access to a MongoDB 'books' collection
##
class SNPsInfo:

    ##
    # Initialise MongoDB connection, database and collection handles
    ##
    def __init__(self, uri, dbname, collname):
        self.uri = uri
        self.connection = MongoClient(host=uri)
        self.db = self.connection[dbname]
        self.coll = self.db[collname]

    def get(self):
        """列表查询接口"""
        class_type = request.args.get("class_type")  # 获取前端参数"type"
        create_date = request.args.getlist("create_date[]")  # 获取前端传来的list格式数据（前端叫做array，数组）
        page_num = int(request.args.get("page_num"))  # 当前页码
        page_size = int(request.args.get("page_size"))  # 每页显示数据条数
        print("********************")
        # print(class_type)
        print(create_date)
        # print(page_num)
        # print(page_size)
        # print(type(page_num))

        class_type_data = {  # 定义一个字典，映射数据类型与类型编号的关系
            "1": "电话号码",
            "2": "身份证id",
            "3": "姓名"
        }

        sql1 = None
        sql2 = None

        if class_type == "":
            if not create_date or create_date == ['']:
                sql1 = "select type_name, value, date_format(create_time, '%Y-%m-%d') from data_list LIMIT {},{}"\
                       .format((page_num-1)*page_size, page_size)

                sql2 = "select count(*) from data_list;"
            else:
                startDate = create_date[0]  # request.args.get("startDate")
                endDate = create_date[1]  # request.args.get("endDate")
                sql1 = "select type_name, value, date_format(create_time, '%Y-%m-%d') from data_list where " \
                       "create_time between '{}' AND '{}' LIMIT {},{};"\
                       .format(startDate, endDate, (page_num-1)*page_size, page_size)

                sql2 = "select count(*) from data_list where create_time between '{}' AND '{}';"\
                       .format(startDate, endDate)

        elif class_type != "":
            if not create_date or create_date == ['']:
                sql1 = "select type_name, value, date_format(create_time, '%Y-%m-%d') from data_list " \
                       "where type_name='{}' LIMIT {},{};"\
                       .format(class_type_data[class_type], (page_num-1)*page_size, page_size)

                sql2 = "select count(*) from data_list where type_name='{}';".format(class_type_data[class_type])

            else:
                startDate = create_date[0]  # request.args.get("startDate")
                endDate = create_date[1]  # request.args.get("endDate")
                sql1 = "select type_name, value, date_format(create_time, '%Y-%m-%d') from data_list " \
                       "where type_name='{}'" \
                       "and create_time between '{}' AND '{}' LIMIT {},{};"\
                       .format(class_type_data[class_type], startDate, endDate, (page_num-1)*page_size, page_size)

                sql2 = "select count(*) from data_list " \
                       "where type_name='{}'" \
                       "and create_time between '{}' AND '{}';".format(class_type_data[class_type], startDate, endDate)

        print("################### 打印sql1 #########################")
        print(sql1)

        history_data = self.db.select_all(sql1)
        print("################### 打印查询到的所有数据 #########################")
        print(history_data)

        print("################### 打印sql2 #########################")
        print(sql2)

        count = self.db.select_one(sql2)[0]
        print("################### 打印查询到的数据总条数 #########################")
        print(count)

        self.db.close()
        data = {
            "code": 200,
            "records": history_data,
            "count": count
        }
        time.sleep(0.5)
        return data