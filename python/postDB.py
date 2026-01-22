from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

# 1. 라우터 설정 (이 정의가 반드시 코드 상단에 있어야 합니다)
router = APIRouter()

# 2. 데이터 모델 설정
class Post(BaseModel):
    post_user_id: int
    post_curtain_id: int
    post_grade: int
    post_area: int
    post_quantity: int
    post_price: int
    post_desc: str
    post_create_date: str

# 3. DB 연결 함수
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

# 4. 구매 조건 상세 필터링 검색
@router.get("/filter")
async def filter_posts(curtain: int, date: str, time: str, grade: int, area: str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        SELECT 
            p.post_seq, 
            p.post_user_id, 
            u.user_name, 
            p.post_curtain_id,
            p.post_create_date, 
            p.post_quantity, 
            p.post_price, 
            p.post_grade, 
            p.post_area, 
            p.post_desc
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
          AND p.post_status = 0
        """
        curs.execute(sql, (curtain, date, f"{time}%", grade, area))
        rows = curs.fetchall()
        result = [
            {
                'post_seq': int(row[0]), 'post_user_id': int(row[1]), 'user_name': row[2],
                'post_curtain_id': int(row[3]), 'post_create_date': str(row[4]),
                'post_quantity': int(row[5]), 'post_price': int(row[6]),
                'post_grade': int(row[7]), 'post_area': int(row[8]),
                'post_desc': row[9] if row[9] else ""
            } for row in rows
        ]
        return {'results': result}
    except Exception as ex:
        print("Error in filter_posts:", ex)
        return {'results': 'Error'}
    finally:
        conn.close()

# 5. 티켓 판매 상태 업데이트
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

# 6. 전체 목록 조회
@router.get("/allSelect")
async def allSelect():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        select p.post_seq, p.post_user_id, u.user_name, p.post_curtain_id, 
               p.post_create_date, p.post_quantity, p.post_price, 
               p.post_grade, p.post_area, p.post_desc
        from post as p
        join user as u on p.post_user_id = u.user_id
        """
        curs.execute(sql)
        rows = curs.fetchall()
        result = [{'post_seq': row[0], 'post_user_id': row[1], 'user_name': row[2], 
                   'post_curtain_id': row[3], 'post_create_date': str(row[4]), 
                   'post_quantity': row[5], 'post_price': row[6], 
                   'post_grade': row[7], 'post_area': row[8], 'post_desc': row[9]} for row in rows]
        return {'results': result}
    except Exception as ex:
        print("Error :", ex)
        return {'results':'Error'}
    finally:
        conn.close()

@router.get("/allSelectAdmin")
async def allSelectAdmin():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        select 
          p.post_seq,
          u.user_name,
          t.type_name,
          ti.title_contents,
          p.post_create_date,
          p.post_quantity,
          p.post_price,
          p.post_grade,
          p.post_area,
          p.post_desc
        from post p
        join user u on p.post_user_id = u.user_id
        join curtain c on p.post_curtain_id = c.curtain_id
        join type t on c.curtain_type_seq = t.type_seq
        join title ti on c.curtain_title_seq = ti.title_seq
        """
        curs.execute(sql)
        rows = curs.fetchall()

        result = [{
            'post_seq': row[0],
            'user_name': row[1],
            'type_name': row[2],
            'title_contents': row[3],
            'post_create_date': str(row[4]),
            'post_quantity': row[5],
            'post_price': row[6],
            'post_grade': row[7],
            'post_area': row[8],
            'post_desc': row[9],
        } for row in rows]

        return {'results': result}

    except Exception as ex:
        print("Error :", ex)
        return {'results': 'Error'}
    finally:
        conn.close()

# 7. 판매 티켓 등록
@router.post("/insert")
async def insert(post : Post):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        insert into post
        (post_user_id, post_curtain_id, post_create_date, post_quantity,
        post_price, post_grade, post_area, post_desc) 
        values (%s,%s,now(),%s,%s,%s,%s,%s)
        """
        curs.execute(sql, (post.post_user_id, post.post_curtain_id, post.post_quantity, 
                           post.post_price, post.post_grade, post.post_area, post.post_desc))
        return {'results':'OK'}
    except Exception as ex:
        print("Error :", ex)
        return {'results':'Error'}
    finally:
        conn.close()

# 8. 개별 상세 조회 (상세 페이지용)
@router.get("/selectPost/{seq}")
async def selectPost(seq:int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select
            p.post_seq, u.user_name, p.post_create_date, p.post_quantity,
            g.grade_name, a.area_value, a.area_number, p.post_desc,
            c.curtain_id, c.curtain_date, c.curtain_desc, c.curtain_mov, 
            c.curtain_pic, pl.place_name, ty.type_name, t.title_contents, 
            c.curtain_grade, c.curtain_area, p.post_user_id, p.post_price
        from post as p
            left join user as u on u.user_id = p.post_user_id
            left join curtain as c on c.curtain_id = p.post_curtain_id
            left join title as t on t.title_seq = c.curtain_title_seq
            left join place as pl on pl.place_seq = c.curtain_place_seq
            left join type as ty on ty.type_seq = c.curtain_type_seq
            left join grade as g on g.grade_seq = p.post_grade
            left join area as a on a.area_seq = p.post_area
        where p.post_seq = %s;     
        """
        curs.execute(sql, (seq,))
        rows = curs.fetchall()
        result = [{'post_seq' : row[0], 'user_name' : row[1], 'post_create_date' : str(row[2]), 
                   'post_quantity' : row[3], 'grade_name' : row[4], 'area_value' : row[5], 
                   'area_number' : row[6], 'post_desc' : row[7], 'curtain_id' : row[8],
                   'curtain_date' : str(row[9]), 'curtain_desc' : row[10], 'curtain_mov' : row[11],
                   'curtain_pic' : row[12], 'place_name' : row[13], 'type_name' : row[14],
                   'title_contents' : row[15], 'curtain_grade' : row[16], 'curtain_area' : row[17],
                   'post_user_id' : row[18], 'post_price' : row[19]} for row in rows]
        return {'results' : result}
    except Exception as ex:
        print("Error in selectPost:", ex)
        return {'results':'Error'} 
    finally:
        conn.close()



        # 5. ticketdetail에 사용
@router.get("/selectPostDetail/{seq}")
async def selectPost(seq:int):
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
                   'curtain_area' : row[17],'post_price' : row[18] , 'curtain_time' : str(row[19]), 'post_user_id' : row[20]} for row in rows]
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()

