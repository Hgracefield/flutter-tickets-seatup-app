# -*- coding: utf-8 -*-
"""
author      : Kenny
Description : MySQL의 python Database와 CRUD on Web
http://192.168.10.65:8000/iris?sepalLength=...&...
"""

from fastapi import FastAPI, Request
from pydantic import BaseModel
import joblib
import pymysql

fastAPIAddress = "192.168.10.48"

app = FastAPI()

class Type(BaseModel):
    type_name: str
    type_create_date: str

def connect():
    return pymysql.connect(
        host="127.0.0.1",
        port=3307,
        user="zero",
        password="Qwer1234!@#$",
        database="seatup",
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )




@app.get("/select")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM type"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    # print(rows)
    # 결과값을 Dictionary로 변환
    result = [{'type_name' : row['type_name'], 'type_create_date' : row['type_create_date']} for row in rows]
    return {'results' : result}

@app.post("/insert")
async def insert(student: Type):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "insert into type(ttype_name, ttype_create_date) values (%s,%s,%s,%s,%s)"
        curs.execute(sql, (type.type_name, type.type_create_date))
        conn.commit()
        conn.close()
        return {'result':'OK'}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}
    

@app.post("/update")
async def update(student: Type):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "update type set ttype_name=%s, ttype_create_date=%s"
        curs.execute(sql, (type.type_name, type.type_create_date))
        conn.commit()
        conn.close()
        return {'result':'OK'}  
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}

# @app.post("/delete")
# async def delete(student: StudentCode):
#     # Connection으로 부터 Cursor 생성
#     conn = connect()
#     curs = conn.cursor()

    # SQL 문장
    # try:
    #     sql = "delete from student where scode = %s"
    #     curs.execute(sql, (student.code))
    #     conn.commit()
    #     conn.close()
    #     return {'result':'OK'}
    # except Exception as ex:
    #     conn.close()
    #     print("Error :", ex)
    #     return {'result':'Error'}

@app.get("/iris")
async def read_iris(sepalLength: str=None, sepalWidth: str=None, petalLength: str=None, petalWidth: str=None):
    sepalLengthW = float(sepalLength)
    sepalWidthW = float(sepalWidth)
    petalLengthW = float(petalLength)
    petalWidthW = float(petalWidth)

    clf=joblib.load("rf_iris2.h5")
    pre=clf.predict([[sepalLengthW, sepalWidthW, petalLengthW, petalWidthW]])

    print(pre)

    return {"result": pre[0][5:]}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="192.168.10.48", port=8000)

# uvicorn types:app --reload