from fastapi import FastAPI
from userDB import router as user_router
from areaDB import router as area_router
from curtainDB import router as curtain_router
from gradeDB import router as grade_router
# from locationDB import router as location_router
# from placeDB import router as place_router
from postDB import router as post_router
# from purchaseDB import router as purchase_router
# from registerDB import router as register_router
from staffDB import router as staff_router
from titleDB import router as title_router
# from typeDB import router as type_router
# from wishlistDB import router as wishlist_router
from curtain_list import router as curtain_list_router
# from bankDB import router as bank_router
import config

app = FastAPI()
app.include_router(user_router, prefix='/user', tags=['user'])
app.include_router(area_router, prefix='/area', tags=['area'])
app.include_router(curtain_router, prefix='/curtain', tags=['curtain'])
app.include_router(curtain_list_router, prefix="/curtain")
app.include_router(grade_router, prefix='/grade', tags=['grade'])
# app.include_router(location_router, prefix='/location', tags=['location'])
# app.include_router(place_router, prefix='/place', tags=['place'])
app.include_router(post_router, prefix='/post', tags=['post'])
# app.include_router(purchase_router, prefix='/purchase', tags=['purchase'])
# app.include_router(register_router, prefix='/register', tags=['register'])
app.include_router(staff_router, prefix='/staff', tags=['staff'])
app.include_router(title_router, prefix='/title', tags=['title'])
# app.include_router(type_router, prefix='/type', tags=['type'])
# app.include_router(wishlist_router, prefix='/wishlist', tags=['wishlist'])



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=config.FASTAPI_HOST, port=8000)