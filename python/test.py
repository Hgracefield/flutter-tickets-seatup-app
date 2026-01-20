from fastapi import FastAPI
import pymysql

fastAPIAddress = "192.168.10.48"

app = FastAPI()

def get_conn():
    return pymysql.connect(
        host="127.0.0.1",
        port=3307,
        user="zero",
        password="Qwer1234!@#$",
        database="seatup",
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )

@app.get("/ping-db")
def ping_db():
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT 1 AS ok;")
            return cur.fetchone()
    finally:
        conn.close()
@app.get("/insert/{text}")
async def insert(text:str):
    conn = get_conn()
    curs = conn.cursor()

    try:
        sql = "insert into grade (grade_name, grade_create_date) values (%s, now())" 
        curs.execute(sql, (text,))
        conn.commit()
        return {'results' : 'Success'}
    except Exception as e: 
        return {'results' : f'Error :{e}'}
    finally:
        conn.close()
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=fastAPIAddress, port=8000)

