from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel

router = APIRouter()

class Curtain(BaseModel):
    curtain_id:int
    curtain_date:str
    curtain_time:str
    curtain_desc:str
    curtain_pic:str
    curtain_place:int
    curtain_type:int
    curtain_title:int
    curtain_grade:int
    curtain_area:int

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
            c.curtain_title_seq, 
            c.curtain_type_seq, 
            c.curtain_place_seq, 
            c.curtain_grade, 
            c.curtain_area
        from curtain as c
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
                   'curtain_title_seq' : row[6], 
                   'curtain_type_seq' : row[7], 
                   'curtain_place_seq' : row[8],
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

# 시간만 가져오기위한 sql
@router.get("/selectTime")
async def search():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select 
            c.curtain_id, 
            c.curtain_date,
            c.curtain_desc, 
            c.curtain_mov, 
            c.curtain_pic, 
            p.place_name, 
            type.type_name, 
            t.title_contents, 
            c.curtain_grade, 
            c.curtain_area,
            DATE_FORMAT(c.curtain_time, '%H:%i:%s') as curtain_time
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
                   'curtain_desc' : row[2], 
                   'curtain_mov' : row[3], 
                   'curtain_pic' : row[4], 
                   'place_name' : row[5], 
                   'type_name' : row[6], 
                   'title_contents' : row[7], 
                   'curtain_grade' : row[8],
                   'curtain_area' : row[9],
                   'curtain_time' : row[10]
                   } for row in rows]
        
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()

# insert
@router.post("/insert")
async def insert(curtain : Curtain):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        insert into curtain
        (
        curtain_date, 
        curtain_time,
        curtain_desc,
        curtain_pic,
        curtain_place_seq,
        curtain_type_seq,
        curtain_title_seq,
        curtain_grade,
        curtain_area
        ) values (%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        curs.execute(sql, (curtain.curtain_date, 
                           curtain.curtain_time, 
                           curtain.curtain_desc, 
                           curtain.curtain_pic, 
                           curtain.curtain_place, 
                           curtain.curtain_type, 
                           curtain.curtain_title,
                           curtain.curtain_grade,
                           curtain.curtain_area))

        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
# insert
@router.post("/update")
async def insert(curtain : Curtain):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        update curtain set
        curtain_date = %s, 
        curtain_time = %s,
        curtain_desc = %s,
        curtain_pic = %s,
        curtain_place_seq = %s,
        curtain_type_seq = %s,
        curtain_title_seq = %s,
        curtain_grade = %s,
        curtain_area = %s
        where curtain_id = %s"""
        curs.execute(sql, (curtain.curtain_date, 
                           curtain.curtain_time, 
                           curtain.curtain_desc, 
                           curtain.curtain_pic, 
                           curtain.curtain_place, 
                           curtain.curtain_type, 
                           curtain.curtain_title,
                           curtain.curtain_grade,
                           curtain.curtain_area,
                           curtain.curtain_id))

        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()


    