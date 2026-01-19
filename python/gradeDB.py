from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

router = APIRouter()

class Grade(BaseModel):
    seq:int
    name:str
    value:int
    date:str

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
        sql = """
        select grade_seq,
        grade_name,
        grade_value,
        grade_create_date
        from grade
        """
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()   
        result = [{'grade_seq' : row[0], 
                   'grade_name' : row[1], 
                   'grade_value' : row[2], 
                   'grade_create_date' : row[3]} for row in rows]
        return {'results' : result}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}   

@router.post("/insert")
async def insert(grade : Grade):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        insert into grade
        (grade_name, 
        grade_value,
        grade_create_date
        ) values (%s,%s,now())
        """
        curs.execute(sql, (grade.name, grade.value))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
@router.post("/update")
async def insert(grade : Grade):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        update grade set
        grade_name = %s, 
        grade_value = %s
        grade_create_date = now()
        where grade_seq = %s
        """
        curs.execute(sql, (grade.name, grade.value, grade.seq))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
