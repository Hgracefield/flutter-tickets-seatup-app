from fastapi import Form, APIRouter
import pymysql
import config
from pydantic import BaseModel


router = APIRouter()

class LoginRequest(BaseModel):
    email:str
    password:str

class User(BaseModel):
    email:str
    password:str
    name:str
    phone:str
    address:str
    bank:str
    account:str



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
@router.get("/exist")
async def exist(email:str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        select count(user_id) from user
        where user_email = %s
        """
        curs.execute(sql, (email,))
        row = curs.fetchone()
        conn.close()   
        return {'result': row[0]}  
    except Exception as ex:
        conn.close()
        print("Error :", ex)
        return {'result':'Error'}    
# @router.get("/exist")
# async def exist(email:str, password:str):
#     # Connection으로 부터 Cursor 생성
#     conn = connect()
#     curs = conn.cursor()
#     try:
        
#         sql = """
#         select user_id, 
#         user_email, 
#         user_password, 
#         user_name, 
#         user_phone, 
#         user_address, 
#         user_signup_date, 
#         user_account, 
#         user_bank_name, 
#         user_withdraw_date
#         from user 
#         where user_email = %s and user_password = %s
#         """
#         curs.execute(sql, (email, password))
#         rows = curs.fetchall()
#         # 결과값을 Dictionary로 변환
#         result = [{'user_id' : row[0], 
#                    'user_email' : row[1], 
#                    'user_password' : row[2], 
#                    'user_name' : row[3], 
#                    'user_phone' : row[4], 
#                    'user_address' : row[5], 
#                    'user_signup_date' : row[6], 
#                    'user_account' : row[7], 
#                    'user_bank_name' : row[8], 
#                    'user_withdraw_date' : row[9]} for row in rows]
#     except Exception as ex:
#         conn.rollback()
#         print("Error :", ex)
#         return {'result':'Error'}
#     finally:    
#         conn.close()
#     return {'results' : result}
@router.post("/login")
async def login(request:LoginRequest):
    # Connection으로 부터 Cursor 생성
    email = request.email
    password = request.password
    conn = connect()
    curs = conn.cursor()
    try:
        
        sql = """
        select user_id, 
        user_email, 
        user_password, 
        user_name, 
        user_phone, 
        user_address, 
        user_signup_date, 
        user_account, 
        user_bank_name, 
        user_withdraw_date
        from user 
        where user_email = %s and user_password = %s
        """
        curs.execute(sql, (email, password))
        rows = curs.fetchall()
        # 결과값을 Dictionary로 변환
        result = [{'user_id' : row[0], 
                   'user_email' : row[1], 
                   'user_password' : row[2], 
                   'user_name' : row[3], 
                   'user_phone' : row[4], 
                   'user_address' : row[5], 
                   'user_signup_date' : row[6], 
                   'user_account' : row[7], 
                   'user_bank_name' : row[8], 
                   'user_withdraw_date' : row[9]} for row in rows]
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:    
        conn.close()
    return {'results' : result}

@router.post("/insert")
async def insert(user : User):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        insert into user
        (user_email, 
        user_password,
        user_name,
        user_phone,
        user_address,
        user_bank_name,
        user_account,
        user_signup_date,
        user_withdraw_date
        ) values (%s,%s,%s,%s,%s,%s,%s,now(),null)"""
        curs.execute(sql, (user.email, user.password, user.name, user.phone, user.address, user.bank, user.account))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
@router.post("/update")
async def insert(user : User):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        update user set
        user_password = %s,
        user_name = %s,
        user_phone = %s,
        user_address = %s,
        user_bank_name = %s,
        user_account = %s
        where user_email = %s
        """
        curs.execute(sql, (user.password, user.name, user.phone, user.address, user.bank, user.account, user.email))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()

@router.get("/withdrawUser")
async def delete(user : int):
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    try:
        sql = """
        update user set
        user_withdraw_date = now() 
        where user_id = %s
        """
        curs.execute(sql, (user))
        conn.commit()
        return {'result':'OK'}
    except Exception as ex:
        conn.rollback()
        print("Error :", ex)
        return {'result':'Error'}
    finally:
        conn.close()
@router.get("/address/{user_id}")   #주소만 뽑는 api 하나 추가함 pjs
async def get_user_address(user_id: int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
        SELECT user_id, user_address
        FROM user
        WHERE user_id = %s
        """
        curs.execute(sql, (user_id,))
        row = curs.fetchone()
        if row is None:
            return {"result": "Error", "message": "User not found"}

        return {"result": "OK", "user_id": row[0], "user_address": row[1]}
    except Exception as ex:
        print("Error:", ex)
        return {"result": "Error"}
    finally:
        conn.close()        
    
@router.get("/select")
async def select():
    # Connection으로 부터 Cursor 생성
    conn = connect()
    curs = conn.cursor()

    # SQL 문장
    sql = "SELECT * FROM user"
    curs.execute(sql)
    rows = curs.fetchall()
    conn.close()
    # 결과값을 Dictionary로 변환
    result = [{'user_id' : row[0], 'user_email' : row[1], 'user_password' : row[2], 'user_name' : row[3], 'user_phone' : row[4], 'user_address' : row[5], 'user_signup_date' : row[6], 'user_account' : row[7], 'user_bank_name' : row[8], 'user_withdraw_date' : row[9]} for row in rows]
    return {'results' : result}
    
