from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

router = APIRouter()

class Post(BaseModel):
    post_user_id: int
    post_curtain_id: int
    post_grade: int
    post_area: int
    post_quantity: int
    post_price: int
    post_desc: str

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

# 1. 필터 검색 (판매 중인 post_status = 0 인 것만 조회하도록 수정)
@router.get("/filter")
async def filter_posts(curtain: int, date: str, time: str, grade: int, area: str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        SELECT 
            p.post_seq, p.post_user_id, u.user_name, p.post_curtain_id,
            p.post_create_date, p.post_quantity, p.post_price, 
            p.post_grade, p.post_area, p.post_desc
        FROM post AS p
        JOIN user AS u ON p.post_user_id = u.user_id
        JOIN curtain AS c ON p.post_curtain_id = c.curtain_id
        JOIN grade AS g ON p.post_grade = g.grade_seq
        JOIN area AS a ON p.post_area = a.area_seq
        WHERE p.post_curtain_id = %s 
          AND c.curtain_date = %s 
          AND c.curtain_time LIKE %s
          AND (1 << g.grade_value) = %s
          AND a.area_number = %s
          AND p.post_status = 0  -- [추가] 팔리지 않은 티켓만 검색
        """
        curs.execute(sql, (curtain, date, f"{time}%", grade, area))
        rows = curs.fetchall()
        result = [{
                'post_seq': int(row[0]), 'post_user_id': int(row[1]), 'user_name': row[2],
                'post_curtain_id': int(row[3]), 'post_create_date': str(row[4]),
                'post_quantity': int(row[5]), 'post_price': int(row[6]),
                'post_grade': int(row[7]), 'post_area': int(row[8]),
                'post_desc': row[9] if row[9] else ""
            } for row in rows]
        return {'results': result}
    except Exception as ex:
        print("Error in filter_posts:", ex)
        return {'results': 'Error'}
    finally:
        conn.close()

# 2. 티켓 상태 업데이트 (결제 완료 시 호출)
@router.get("/updateStatus")
async def update_status(seq: int, status: int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "update post set post_status = %s where post_seq = %s"
        curs.execute(sql, (status, seq))
        return {'results': 'OK'}
    except Exception as ex:
        print("Error in updateStatus:", ex)
        return {'results': 'Error'}
    finally:
        conn.close()

# --- 아래 기존 코드 (allSelect, insert, search, selectPost) 동일 유지 ---
@router.get("/allSelect")
async def allSelect():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "select p.post_seq, p.post_user_id, u.user_name, p.post_curtain_id, p.post_create_date, p.post_quantity, p.post_price, p.post_grade, p.post_area, p.post_desc from post as p join user as u on p.post_user_id = u.user_id"
        curs.execute(sql)
        rows = curs.fetchall()
        result = [{'post_seq' : row[0], 'post_user_id' : row[1], 'user_name' : row[2], 'post_curtain_id' : row[3], 'post_create_date' : str(row[4]), 'post_quantity' : row[5], 'post_price' : row[6], 'post_grade' : row[7], 'post_area' : row[8], 'post_desc' : row[9]} for row in rows]
        return {'results' : result}
    except Exception as ex:
        return {'results':'Error'}
    finally:
        conn.close()

@router.post("/insert")
async def insert(post : Post):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select
            post.post_seq, u.user_name, post.post_create_date, post.post_quantity,
            g.grade_name, a.area_value, a.area_number, post.post_desc,
            c.curtain_id, c.curtain_date, c.curtain_desc, c.curtain_mov, 
            c.curtain_pic, p.place_name, type.type_name, t.title_contents, 
            c.curtain_grade, c.curtain_area, post.post_price, c.curtain_time
        from post
            join curtain as c on c.curtain_id = post.post_curtain_id
            join title as t on c.curtain_title_seq = t.title_seq
            join place as p on c.curtain_place_seq = p.place_seq
            join type on c.curtain_type_seq = type.type_seq
            join user as u on u.user_id = post.post_user_id
            join grade as g on g.grade_seq = post.post_grade
            join area as a on a.area_seq = post.post_area
        where post.post_seq = %s;     
        """
        curs.execute(sql, (seq,))
        rows = curs.fetchall()
        result = [{'post_seq' : row[0], 'user_name' : row[1], 'post_create_date' : str(row[2]), 
                   'post_quantity' : row[3], 'grade_name' : row[4], 'area_value' : row[5], 
                   'area_number' : row[6], 'post_desc' : row[7], 'curtain_id' : row[8],
                   'curtain_date' : str(row[9]), 'curtain_desc' : row[10], 'curtain_mov' : row[11],
                   'curtain_pic' : row[12], 'place_name' : row[13], 'type_name' : row[14],
                   'title_contents' : row[15], 'curtain_grade' : row[16], 
                   'curtain_area' : row[17],'post_price' : row[18] , 'curtain_time' : str(row[19])} for row in rows]
        return {'results' : result}
    except Exception as ex:
        return {'results':'Error'}
    finally:
        conn.close()