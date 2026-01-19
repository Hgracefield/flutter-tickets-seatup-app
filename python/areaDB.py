from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

router = APIRouter()

class Area(BaseModel):
    seq:int
    number:str
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
        select area_seq,
        area_number,
        area_value,
        area_create_date
        from area
        """
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()   
        result = [{'area_seq' : row[0], 
                   'area_number' : row[1], 
                   'area_value' : row[2], 
                   'area_create_date' : row[3]} for row in rows]
        return {'results' : result}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}   

@router.post("/insert")
async def insert(area : Area):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        insert into area
        (area_number, 
        area_value,
        area_create_date
        ) values (%s,%s,now())
        """
        curs.execute(sql, (area.name, area.value))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
@router.post("/update")
async def insert(area : Area):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        update area set
        area_number = %s, 
        area_value = %s
        area_create_date = now()
        where area_seq = %s
        """
        curs.execute(sql, (area.name, area.value, area.seq))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
