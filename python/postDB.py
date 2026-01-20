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

# post에서 해당하는 seq가져오기
@router.get("/selectPost/{seq}")
async def search(seq:int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select
			post.post_seq,
            u.user_name,
            post.post_create_date,
            post.post_quantity,
            g.grade_name,
            a.area_value,
            a.area_number,
            post.post_desc,
            c.curtain_id, 
            c.curtain_date,
            c.curtain_desc, 
            c.curtain_mov, 
            c.curtain_pic, 
            p.place_name, 
            type.type_name, 
            t.title_contents, 
            c.curtain_grade, 
            c.curtain_area
        from curtain as c
            join title as t
                on c.curtain_title_seq = t.title_seq
            join place as p
                on c.curtain_place_seq = p.place_seq
            join type 
                on c.curtain_type_seq = type.type_seq
			join post
				on c.curtain_id = post.post_curtain_id
			join user as u
				on u.user_id = post.post_user_id
			join grade as g
				on g.grade_seq = post.post_grade
			join area as a
				on a.area_seq = post.post_area
			where post.post_seq = %s;     
        """
        curs.execute(sql, (seq,))
        rows = curs.fetchall()
        result = [{'post_seq' : row[0], 
                   'user_name' : row[1], 
                   'post_create_date' : row[2], 
                   'post_quantity' : row[3], 
                   'grade_name' : row[4], 
                   'area_value' : row[5], 
                   'area_number' : row[6],
                   'post_desc' : row[7],
                   'curtain_id' : row[8],
                   'curtain_date' : row[9],
                   'curtain_desc' : row[10],
                   'curtain_mov' : row[11],
                   'curtain_pic' : row[12],
                   'place_name' : row[13],
                   'type_name' : row[14],
                   'title_contents' : row[15],
                   'curtain_grade' : row[16],
                   'curtain_area' : row[17]
                   } for row in rows]
        
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()
