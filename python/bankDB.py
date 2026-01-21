from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

router = APIRouter()

class Bank(BaseModel):
    seq:int
    name:str
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
        select bank_seq,
        bank_name,
        bank_create_date
        from bank
        """
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()   
        result = [{'bank_seq' : row[0], 
                   'bank_name' : row[1], 
                   'bank_create_date' : row[2]} for row in rows]
        return {'results' : result}
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}   

@router.post("/insert")
async def insert(bank : Bank):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        insert into bank
        (bank_name, 
        bank_create_date
        ) values (%s,now())
        """
        curs.execute(sql, (bank.name))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()

@router.post("/update")
async def insert(bank : Bank):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        update bank set
        bank_name = %s, 
        bank_create_date = now()
        where bank_seq = %s
        """
        curs.execute(sql, (bank.name, bank.seq))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
