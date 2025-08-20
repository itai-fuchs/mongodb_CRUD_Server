from fastapi import FastAPI, HTTPException, Path, Body
from fastapi.responses import JSONResponse
from typing import List, AsyncIterator
from contextlib import asynccontextmanager
from .mongo_dal import MongoDal

dal = MongoDal()

@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    dal.open_conn()
    try:
        yield
    finally:
        await dal.close_conn()

app = FastAPI(
    title="Enemy Soldiers CRUD API",
    version="1.0.0",
    lifespan=lifespan
)

@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}

@app.get("/read collection/")
async def read_collection():
    docs = await dal.read_collection()
    return docs

@app.post("/create soldier/", status_code=201)
async def create_soldier(id: int, first_name: str, last_name: str, phone_number: int, rank: int):
    try:
        res = await dal.create_soldier(id, first_name, last_name, phone_number, rank)
        return JSONResponse(status_code=201, content={"ok": True, **res})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.put("/update-soldier/{soldier_id}")
async def update_soldier(
    soldier_id: int = Path(..., description="Numeric Soldier ID to update"),
    update_values: dict = Body(..., embed=False)
):
    res = await dal.update_soldier(soldier_id, update_values)
    if res.get("matched", 0) == 0:
        raise HTTPException(status_code=404, detail="Soldier not found")
    return {"ok": True, **res}

@app.delete("/delete-soldier/{soldier_id}")
async def delete_soldier(soldier_id: int):
    res = await dal.delete_soldier(soldier_id)
    if res.get("deleted", 0) == 0:
        raise HTTPException(status_code=404, detail="Soldier not found")
    return {"ok": True, **res}
