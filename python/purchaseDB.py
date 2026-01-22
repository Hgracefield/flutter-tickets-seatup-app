from fastapi import APIRouter
from pydantic import BaseModel
import pymysql
import config
from datetime import datetime

router = APIRouter()

class PurchaseIn(BaseModel):
    purchase_user_id: int
    purchase_curtain_id: int
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
        INSERT INTO purchase (purchase_user_id, purchase_curtain_id, purchase_date, purchase_create_date)
        VALUES (%s, %s, NOW(), %s)
        """
        curs.execute(sql, (p.purchase_user_id, p.purchase_curtain_id, p.purchase_create_date))
        conn.commit()
        return {"result": "OK"}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        # 에러를 클라가 보게 해야 디버깅 쉬움
        return {"result": "Error", "detail": str(ex)}
    finally:
        conn.close()


@router.get("/selectPurchaseDetail/{seq}")
async def selectPost(id:int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select
            post.post_seq, u.user_name, post.post_create_date, post.post_quantity,
            g.grade_name, a.area_value, a.area_number, post.post_desc,
            c.curtain_id, c.curtain_date, c.curtain_desc, c.curtain_mov, 
            c.curtain_pic, p.place_name, type.type_name, t.title_contents, 
            c.curtain_grade, c.curtain_area, post.post_price, c.curtain_time, post.post_user_id
        from post
            join curtain as c on c.curtain_id = post.post_curtain_id
            join title as t on c.curtain_title_seq = t.title_seq
            join place as p on c.curtain_place_seq = p.place_seq
            join type on c.curtain_type_seq = type.type_seq
            join user as u on u.user_id = post.post_user_id
            join grade as g on g.grade_seq = post.post_grade
            join area as a on a.area_seq = post.post_area
        where post.post_status = 1 and post.post_user_id = %s;
        """
        curs.execute(sql, (id,))
        rows = curs.fetchall()
        result = [{'post_seq' : row[0], 'user_name' : row[1], 'post_create_date' : str(row[2]), 
                   'post_quantity' : row[3], 'grade_name' : row[4], 'area_value' : row[5], 
                   'area_number' : row[6], 'post_desc' : row[7], 'curtain_id' : row[8],
                   'curtain_date' : str(row[9]), 'curtain_desc' : row[10], 'curtain_mov' : row[11],
                   'curtain_pic' : row[12], 'place_name' : row[13], 'type_name' : row[14],
                   'title_contents' : row[15], 'curtain_grade' : row[16], 
                   'curtain_area' : row[17],'post_price' : row[18] , 'curtain_time' : str(row[19]), 'post_user_id' : row[20]} for row in rows]
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()