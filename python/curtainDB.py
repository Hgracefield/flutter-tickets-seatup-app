from fastapi import Form, APIRouter, Query
import pymysql
import config
from pydantic import BaseModel
from typing import Optional

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

# 1. 전체 리스트 (title_seq 컬럼 추가)
@router.get("/simple-list")
async def get_simple_list(type_seq: Optional[int] = None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select 
            c.curtain_id,         -- 0
            c.curtain_title_seq,  -- 1 (추가됨)
            c.curtain_date,       -- 2
            c.curtain_time,       -- 3
            c.curtain_desc,       -- 4
            c.curtain_mov,        -- 5
            c.curtain_pic,        -- 6
            p.place_name,         -- 7
            type.type_name,       -- 8
            t.title_contents,     -- 9
            c.curtain_grade,      -- 10
            c.curtain_area        -- 11
        from curtain as c
            join title as t on c.curtain_title_seq = t.title_seq
            join place as p on c.curtain_place_seq = p.place_seq
            join type on c.curtain_type_seq = type.type_seq
        where c.curtain_date > now()
        """
        
        params = []
        if type_seq:
            sql += " AND c.curtain_type_seq = %s"
            params.append(type_seq)
            
        sql += " ORDER BY c.curtain_date asc"
        
        curs.execute(sql, params)
        rows = curs.fetchall()
        
        result = [{'curtain_id' : row[0], 
                   'title_seq' : row[1], # 매핑 추가
                   'curtain_date' : str(row[2]), 
                   'curtain_time' : str(row[3]), 
                   'curtain_desc' : row[4], 
                   'curtain_mov' : row[5], 
                   'curtain_pic' : row[6], 
                   'place_name' : row[7], 
                   'type_name' : row[8], 
                   'title_contents' : row[9],
                   'curtain_grade' : row[10],
                   'curtain_area' : row[11]
                   } for row in rows]
        
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()

# 2. 검색 리스트 (title_seq 컬럼 추가)
@router.get("/simple-search")
async def get_simple_search(keyword: str, type_seq: Optional[int] = None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select 
            c.curtain_id,         -- 0
            c.curtain_title_seq,  -- 1
            c.curtain_date,       -- 2
            c.curtain_time,       -- 3
            c.curtain_desc,       -- 4
            c.curtain_mov,        -- 5
            c.curtain_pic,        -- 6
            p.place_name,         -- 7
            type.type_name,       -- 8
            t.title_contents,     -- 9
            c.curtain_grade,      -- 10
            c.curtain_area        -- 11
        from curtain as c
            join title as t on c.curtain_title_seq = t.title_seq
            join place as p on c.curtain_place_seq = p.place_seq
            join type on c.curtain_type_seq = type.type_seq
        where t.title_contents like %s
        """
        params = [f"%{keyword}%"]
        if type_seq:
            sql += " AND c.curtain_type_seq = %s"
            params.append(type_seq)
            
        sql += " ORDER BY c.curtain_date asc"
        
        curs.execute(sql, params)
        rows = curs.fetchall()
        result = [{'curtain_id' : row[0], 
                   'title_seq' : row[1],
                   'curtain_date' : str(row[2]), 
                   'curtain_time' : str(row[3]), 
                   'curtain_desc' : row[4], 
                   'curtain_mov' : row[5], 
                   'curtain_pic' : row[6], 
                   'place_name' : row[7], 
                   'type_name' : row[8], 
                   'title_contents' : row[9],
                   'curtain_grade' : row[10],
                   'curtain_area' : row[11]
                   } for row in rows]
        
        return {'results' : result}
    except Exception as ex:
        print("Error :", ex)
        return {'result':'Error'} 
    finally:
        conn.close()

# 3. 개별 선택 (그대로 유지)
@router.get("/select/{seq}")
async def get_one(seq:int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        Select 
            c.curtain_id, c.curtain_title_seq, c.curtain_date, c.curtain_time, 
            c.curtain_desc, c.curtain_mov, c.curtain_pic, p.place_name, 
            type.type_name, t.title_contents, c.curtain_grade, c.curtain_area
        from curtain as c
            join title as t on c.curtain_title_seq = t.title_seq
            join place as p on c.curtain_place_seq = p.place_seq
            join type on c.curtain_type_seq = type.type_seq
        where c.curtain_id = %s;     
        """
        curs.execute(sql, (seq,))
        rows = curs.fetchall()
        result = [{'curtain_id' : row[0], 'title_seq' : row[1], 'curtain_date' : str(row[2]), 
                   'curtain_time' : str(row[3]), 'curtain_desc' : row[4], 'curtain_mov' : row[5], 
                   'curtain_pic' : row[6], 'place_name' : row[7], 'type_name' : row[8], 
                   'title_contents' : row[9], 'curtain_grade' : row[10], 'curtain_area' : row[11]} for row in rows]
        return {'results' : result}
    finally:
        conn.close()