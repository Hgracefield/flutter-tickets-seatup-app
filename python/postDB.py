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

# 1. 구매자가 선택한 상세 조건으로 판매글 검색
@router.get("/filter")
async def filter_posts(curtain: int, date: str, time: str, grade: int, area: str):
    conn = connect()
    curs = conn.cursor()
    try:
        # 에러 해결 포인트:
        # p.post_area는 a.area_seq와 연결되므로 JOIN 조건을 area_seq로 수정
        # 비트 연산 방식 반영: (1 << g.grade_value)를 통해 Flutter의 bit 값과 비교
        sql = """
        SELECT 
            p.post_seq,
            u.user_name,
            p.post_create_date,
            p.post_quantity,
            p.post_price,
            p.post_desc,
            a.area_number
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
        """
        # Flutter에서 '14:00'을 보내면 '14:00%'로 검색하여 초 단위(00) 무시
        curs.execute(sql, (curtain, date, f"{time}%", grade, area))
        rows = curs.fetchall()
        
        result = [{
            'post_seq': row[0],
            'user_name': row[1],
            'post_create_date': str(row[2]),
            'post_quantity': row[3],
            'post_price': row[4],
            'post_desc': row[5],
            'area_number': row[6]
        } for row in rows]
        
        return {'results': result}
    except Exception as ex:
        print("Error in filter_posts:", ex)
        return {'results': 'Error'}
    finally:
        conn.close()

# 2. 전체 판매글 목록 불러오기
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
        result = [
            {'post_seq' : row[0], 
             'post_user_id' : row[1], 
             'post_curtain_id' : row[2], 
             'post_create_date' : str(row[3]), 
             'post_quantity' : row[4], 
             'post_price' : row[5], 
             'post_grade' : row[6], 
             'post_area' : row[7], 
             'post_desc' : row[8]
            } for row in rows]
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'results':'Error'}
    finally:
        conn.close()

# 3. 키워드(작품명)로 판매글 검색
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
            join curtain as c on p.post_curtain_id = c.curtain_id
            join title as t on c.curtain_title_seq = t.title_seq
        where t.title_contents like %s
        """
        curs.execute(sql, (f"%{keyword}%",))
        rows = curs.fetchall()
        result = [{'post_seq' : row[0], 
                   'post_user_id' : row[1], 
                   'post_curtain_id' : row[2], 
                   'post_create_date' : str(row[3]), 
                   'post_quantity' : row[4], 
                   'post_price' : row[5]
                    } for row in rows]
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'results':'Error'}
    finally:
        conn.close()

# 4. 판매글 등록
@router.post("/insert")
async def insert(post : Post):
    conn = connect()
    curs = conn.cursor()
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
        curs.execute(sql, (post.post_user_id, post.post_curtain_id, post.post_quantity, 
                           post.post_price, post.post_grade, post.post_area, post.post_desc))
        return {'results':'OK'}
    except Exception as ex:
        print("Error :", ex)
        return {'results':'Error'}
    finally:
        conn.close()

# 5. 특정 판매글 상세 정보 가져오기
@router.get("/selectPost/{seq}")
async def selectPost(seq:int):
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
        result = [{'post_seq' : row[0], 
                   'user_name' : row[1], 
                   'post_create_date' : str(row[2]), 
                   'post_quantity' : row[3], 
                   'grade_name' : row[4], 
                   'area_value' : row[5], 
                   'area_number' : row[6],
                   'post_desc' : row[7],
                   'curtain_id' : row[8],
                   'curtain_date' : str(row[9]),
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
        return {'results':'Error'} 
    finally:
        conn.close()