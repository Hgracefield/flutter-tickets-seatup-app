from fastapi import APIRouter, Query
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
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )

def res_list(rows):
    return {"results": rows}

def res_error(e):
    return {"results": "Error", "message": str(e)}

# 공연 리스트: 포스터 + 공연명 + title_seq
@router.get("/simple-list")
async def simple_list():
    conn = connect()
    try:
        curs = conn.cursor()
        sql = """
         SELECT
          c.curtain_id         AS curtain_id,
          c.curtain_title_seq  AS title_seq,
          t.title_contents     AS title_contents,
          c.curtain_pic        AS curtain_pic,
          COALESCE(p.place_name, '') AS place_name
        FROM curtain c
        JOIN title t ON c.curtain_title_seq = t.title_seq
        LEFT JOIN place p ON c.curtain_place_seq = p.place_seq
        ORDER BY c.curtain_date DESC
        """
        curs.execute(sql)
        rows = curs.fetchall()
        return res_list(rows)

    except Exception as e:
        return res_error(e)

    finally:
        conn.close()


# 검색
@router.get("/simple-search")
async def simple_search(keyword: str):
    conn = connect()
    try:
        curs = conn.cursor()
        like = f"%{keyword}%"
        sql = """
         SELECT
          c.curtain_id         AS curtain_id,
          c.curtain_title_seq  AS title_seq,
          t.title_contents     AS title_contents,
          c.curtain_pic        AS curtain_pic,
          COALESCE(p.place_name, '') AS place_name
        FROM curtain c
        JOIN title t ON c.curtain_title_seq = t.title_seq
        LEFT JOIN place p ON c.curtain_place_seq = p.place_seq
        WHERE t.title_contents LIKE %s
        ORDER BY c.curtain_date DESC
        """
        curs.execute(sql, (like,))
        rows = curs.fetchall()
        return res_list(rows)

    except Exception as e:
        return res_error(e)

    finally:
        conn.close()
