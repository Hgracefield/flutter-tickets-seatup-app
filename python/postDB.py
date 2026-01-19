from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

router = APIRouter()

class Post(BaseModel):
    post_user_id:int
    post_curtain_id:int
    post_grade:int
    post_area:int
    post_quantity:int
    post_price:int
    post_desc:str


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
            post_price,
            post_grade,
            post_area,
            post_desc
        from post
        """
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()   
        result = [
            {'post_seq' : row[0], 
                   'post_user_id' : row[1], 
                   'post_curtain_id' : row[2], 
                   'post_create_date' : row[3], 
                   'post_quantity' : row[4], 
                   'post_price' : row[5], 
                   'post_grade' : row[6], 
                   'post_area' : row[7], 
                   'post_desc' : row[8], 
                    } for row in rows]
        return {'results' : result}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'results':'Error'}    

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
        return {'results' : result}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'results':'Error'}        
    
@router.post("/insert")
async def insert(post : Post):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        insert into post
        (post_user_id, 
        post_curtain_id,
        post_create_date,
        post_quantity,
        post_price,
        post_grade,
        post_area,
        post_desc
        ) values (%s,%s,now(),%s,%s,%s,%s,%s)
        """
        curs.execute(sql, (post.post_user_id, post.post_curtain_id, post.post_quantity, post.post_price, post.post_grade, post.post_area, post.post_desc))
        conn.commit()
        return {'results':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'results':'Error'}
    finally:
        curs.close()
        conn.close()
