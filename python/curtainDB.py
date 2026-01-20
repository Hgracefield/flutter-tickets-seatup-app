from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

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
async def search():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select 
            c.curtain_id, 
            c.curtain_date,
            c.curtain_time,
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
        where curtain_date > now()
order by curtain_date asc     
        """
        curs.execute(sql)
        rows = curs.fetchall()
        result = [{'curtain_id' : row[0], 
                   'curtain_date' : row[1], 
                   'curtain_time' : str(row[2]), 
                   'curtain_desc' : row[3], 
                   'curtain_mov' : row[4], 
                   'curtain_pic' : row[5], 
                   'place_name' : row[6], 
                   'type_name' : row[7], 
                   'title_contents' : row[8],
                   'curtain_grade' : row[9],
                   'curtain_area' : row[10]
                   } for row in rows]
        
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()

@router.get("/select/{seq}")
async def search(seq:int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select 
            c.curtain_id, 
            c.curtain_date,
            c.curtain_time,
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
        where c.curtain_id = %s;     
        """
        curs.execute(sql, (seq,))
        rows = curs.fetchall()
        result = [{'curtain_id' : row[0], 
                   'curtain_date' : row[1], 
                   'curtain_time' : str(row[2]), 
                   'curtain_desc' : row[3], 
                   'curtain_mov' : row[4], 
                   'curtain_pic' : row[5], 
                   'place_name' : row[6], 
                   'type_name' : row[7], 
                   'title_contents' : row[8],
                   'curtain_grade' : row[9],
                   'curtain_area' : row[10]
                   } for row in rows]
        
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()

@router.get("/search")
async def search(keyword:str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select 
            c.curtain_id, 
            c.curtain_date,
            c.curtain_time,
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
        where t.title_contents like %s;     
        """
        curs.execute(sql, (f"%{keyword}%",))
        rows = curs.fetchall()
        result = [{'curtain_id' : row[0], 
                   'curtain_date' : row[1], 
                   'curtain_time' : str(row[2]), 
                   'curtain_desc' : row[3], 
                   'curtain_mov' : row[4], 
                   'curtain_pic' : row[5], 
                   'place_name' : row[6], 
                   'type_name' : row[7], 
                   'title_contents' : row[8],
                   'curtain_grade' : row[9],
                   'curtain_area' : row[10]
                   } for row in rows]
        
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()
    

    