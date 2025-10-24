# db.py
import pymongo

myclient = pymongo.MongoClient(
    host="mongodb",
    port=27017,
    username="yyq",
    password="yqx2913196,",
    authSource="PLACO"
)
mydb = myclient["PLACO"]