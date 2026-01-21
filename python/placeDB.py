from fastapi import APIRouter
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

@router.get("/select/{place_seq}")
async def select_one(place_seq: int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        SELECT place_seq, place_name, place_address, place_create_date
        FROM place
        WHERE place_seq = %s
        """
        curs.execute(sql, (place_seq,))
        row = curs.fetchone()

        if row is None:
            return {"result": "Error", "message": "Place not found"}

        return {
            "result": "OK",
            "place_seq": row[0],
            "place_name": row[1],
            "place_address": row[2],
            "place_create_date": str(row[3]) if row[3] is not None else None
        }
    except Exception as ex:
        print("Error:", ex)
        return {"result": "Error"}
    finally:
        conn.close()


