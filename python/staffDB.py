from fastapi import Form, APIRouter
import pymysql
import config


router = APIRouter()

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

@router.post("/staffLogin")
async def select(staff_email : str = Form(...), staff_password : str = Form(...)):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = """
        SELECT staff_seq, staff_name, staff_address, staff_phone
        FROM staff
        WHERE staff_email = %s
        AND staff_password = %s
    """
    curs.execute(sql, (staff_email , staff_password))
    rows = curs.fetchall()
    conn.close()
    # 결과값을 Dictionary로 변환
    result = [{'staff_seq' : row[0], 'staff_name' : row[1],'staff_address' : row[2],'staff_phone' : row[3]} for row in rows]
    return {'results' : result}    

@router.get("/select")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM staff"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    # 결과값을 Dictionary로 변환
    result = [{'staff_seq' : row[0], 'staff_email' : row[1], 'staff_password' : row[2], 'staff_name' : row[3],'staff_address' : row[4],'staff_phone' : row[5]} for row in rows]
    return {'results' : result}

@router.post("/delete")
async def delete(staff_seq : int = Form(...)):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "delete from staff where staff_seq = %s"
        curs.execute(sql, (staff_seq,))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()