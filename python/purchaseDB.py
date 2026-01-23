from fastapi import APIRouter
from pydantic import BaseModel
import pymysql
import config
from datetime import datetime

router = APIRouter()

class PurchaseIn(BaseModel):
    purchase_user_id: int
    purchase_post_id: int
    purchase_create_date: datetime  # Flutter에서 ISO 문자열로 보내면 자동 파싱됨

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

@router.post("/insert")
async def insert(p: PurchaseIn):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        INSERT INTO purchase (purchase_user_id, purchase_post_id, purchase_date, purchase_create_date)
        VALUES (%s, %s, NOW(), %s)
        """
        curs.execute(sql, (p.purchase_user_id, p.purchase_post_id, p.purchase_create_date))
        conn.commit()
        return {"result": "OK"}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        # 에러를 클라가 보게 해야 디버깅 쉬움
        return {"result": "Error", "detail": str(ex)}
    finally:
        conn.close()


@router.get("/selectPurchaseDetail/{userId}")
async def select_purchase_detail(userId:int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
            SELECT
                pc.purchase_seq,
                pc.purchase_user_id,
                pc.purchase_post_id,
                pc.purchase_date,
                u.user_name,
                u.user_bank_name,
                c.curtain_date,
                c.curtain_time,
                p.place_name,
                p.place_address,
                tp.type_name,
                t.title_contents,
                post.post_quantity,
                post.post_price,
                g.grade_name,
                a.area_number,
                post.post_desc,
                post.post_seq,
                post.post_create_date
            FROM purchase pc
            JOIN user u
                ON pc.purchase_user_id = u.user_id
            JOIN post
                ON post.post_seq = pc.purchase_post_id
            JOIN curtain c
                ON c.curtain_id = post.post_curtain_id
            JOIN place p
                ON c.curtain_place_seq = p.place_seq
            JOIN type tp
                ON c.curtain_type_seq = tp.type_seq
            JOIN title t
                ON c.curtain_title_seq = t.title_seq
            JOIN grade g
                ON g.grade_seq = post.post_grade
            JOIN area a
                ON a.area_seq = post.post_area
            WHERE pc.purchase_user_id = %s;
            """
        curs.execute(sql, (userId,))
        rows = curs.fetchall()
        result = [{'purchase_seq' : row[0], 'purchase_user_id' : row[1], 'purchase_post_id' : row[2], 
                   'purchase_date' : row[3], 'user_name' : row[4], 'user_bank_name' : row[5], 
                   'curtain_date' : row[6], 'curtain_time' : str(row[7]), 'place_name' : row[8],
                   'place_address' : row[9], 'type_name' : row[10], 'title_contents' : row[11],
                   'post_quantity' : row[12], 'post_price' : row[13], 'grade_name' : row[14],
                   'area_number' : row[15], 'post_desc' : row[16], 'post_seq' : row[17],
                    'post_create_date' : row[18]
                   } for row in rows]
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()