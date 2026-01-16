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
    

@router.get("/select")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM title"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    # 결과값을 Dictionary로 변환
    result = [{'title_seq' : row[0], 'title_contents' : row[1], 'title_create_date' : row[2]} for row in rows]
    return {'results' : result}

@router.post("/insert")
async def insert(title_contents : str = Form(...)):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "insert into title(title_contents, title_create_date) values (%s,now())"
        curs.execute(sql, (title_contents,))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
    

@router.post("/update")
async def update(title_contents : str = Form(...), title_seq : int = Form(...)):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "update title set title_contents=%s , title_create_date=now() where title_seq=%s"
        curs.execute(sql, (title_contents,title_seq))
        conn.commit()
        return {'result':'OK'}  
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()

@router.post("/delete")
async def delete(title_seq : int = Form(...)):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = "delete from title where title_seq = %s"
        curs.execute(sql, (title_seq,))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()