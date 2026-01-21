from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

router = APIRouter()

# 1. Pydantic 모델에 price 필드 추가
class Grade(BaseModel):
    seq: int
    name: str
    value: int
    price: int  # 추가된 부분
    date: str

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

@router.get('/select')
async def select():
    conn = connect()
    curs = conn.cursor()

    try:
        # 2. SQL 쿼리에 grade_price 추가
        sql = """
        select grade_seq,
        grade_name,
        grade_value,
        grade_price,
        grade_create_date
        from grade
        """
        curs.execute(sql)
        rows = curs.fetchall()
        
        # 3. 결과 리스트에 grade_price 매핑
        result = [{'grade_seq' : row[0], 
                   'grade_name' : row[1], 
                   'grade_value' : row[2], 
                   'grade_price' : row[3], # 추가
                   'grade_create_date' : str(row[4])} for row in rows] # 날짜는 문자열로 변환 권장
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'}   
    finally:
        conn.close()

@router.post("/insert")
async def insert(grade : Grade):
    conn = connect()
    curs = conn.cursor()

    try:
        # 4. Insert 문에 grade_price 반영
        sql = """
        insert into grade
        (grade_name, 
        grade_value,
        grade_price,
        grade_create_date
        ) values (%s, %s, %s, now())
        """
        curs.execute(sql, (grade.name, grade.value, grade.price))
        return {'result':'OK'}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()

@router.post("/update")
async def update(grade : Grade): # 함수명이 insert로 중복되어 있어 update로 수정했습니다.
    conn = connect()
    curs = conn.cursor()

    try:
        # 5. Update 문에 grade_price 반영 및 콤마 오류 수정
        sql = """
        update grade set
        grade_name = %s, 
        grade_value = %s,
        grade_price = %s,
        grade_create_date = now()
        where grade_seq = %s
        """
        curs.execute(sql, (grade.name, grade.value, grade.price, grade.seq))
        return {'result':'OK'}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()