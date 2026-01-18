from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

router = APIRouter()

def connect():
    return pymysql.connect(
        host=config.DB_HOST,
        port=config.DB_PORT,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME,
        charset=config.DB_CHARSET,
        autocommit=True
    )

@router.get("/allSelect")
async def allSelect():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        select 
            post_seq,
            post_user_id,
            post_curtain_id,
            post_create_date,
            post_quantity,
            post_price
        from post
        """
        curs.execute(sql)
        rows = curs.fetchone()
        conn.close()   
        result = [{'post_seq' : row[0], 
                   'post_user_id' : row[1], 
                   'post_curtain_id' : row[2], 
                   'post_create_date' : row[3], 
                   'post_quantity' : row[4], 
                   'post_price' : row[5], 
                    } for row in rows]
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}    

@router.get("/search")
async def search(keyword:str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        select 
            p.post_seq,
            p.post_user_id,
            p.post_curtain_id,
            p.post_create_date,
            p.post_quantity,
            p.post_price,
            t.title_contents
        from post as p
            join title as t
                on p.post_curtain_id = t.title_seq
        where t.title_contents like %s
        """
        curs.execute(sql, (f"%{keyword}%",))
        rows = curs.fetchone()
        conn.close()   
        result = [{'post_seq' : row[0], 
                   'post_user_id' : row[1], 
                   'post_curtain_id' : row[2], 
                   'post_create_date' : row[3], 
                   'post_quantity' : row[4], 
                   'post_price' : row[5], 
                    } for row in rows]
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}        