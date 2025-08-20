from typing import List, Dict, Any
from motor.motor_asyncio import AsyncIOMotorClient
from .config import Config
from .solider import Solider

class MongoDal:
    def __init__(self):
        self.conn: AsyncIOMotorClient | None = None
        self.soldier = None
        self.conf = Config()

    # Open connection
    def open_conn(self) -> AsyncIOMotorClient:
        if self.conn is None:
            self.conn = AsyncIOMotorClient(self.conf.MONGO_URI)
        return self.conn

    def get_collection(self):
        cli = self.open_conn()
        return cli[self.conf.MONGO_DB][self.conf.COLLECTION]

    async def read_collection(self) -> List[Dict[str, Any]]:
        col = self.get_collection()
        docs = []
        async for d in col.find({}, {"_id": 0}):
            docs.append(d)
        return docs

    async def create_soldier(self, id: int, first_name: str, last_name: str, phone_number: int, rank: int) -> Dict[str, Any]:
        col = self.get_collection()
        self.soldier = Solider(id, first_name, last_name, phone_number, rank).convert_to_json()
        await col.insert_one(self.soldier)
        return self.soldier

    async def update_soldier(self, id: int, update_values: dict) -> Dict[str, Any]:
        col = self.get_collection()
        res = await col.update_one({"id": id}, {"$set": update_values})
        return {
            "acknowledged": res.acknowledged,
            "matched": res.matched_count,
            "modified": res.modified_count
        }

    async def delete_soldier(self, id: int) -> Dict[str, Any]:
        col = self.get_collection()
        res = await col.delete_one({"id": id})
        return {
            "acknowledged": res.acknowledged,
            "deleted": res.deleted_count
        }

    async def close_conn(self):
        if self.conn is not None:
            self.conn.close()
            self.conn = None
