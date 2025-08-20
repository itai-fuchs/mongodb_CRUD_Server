import os

class Config:
    def __init__(self):
        self.MONGO_HOST = os.getenv("MONGO_HOST", "mongodb")
        self.MONGO_PORT = int(os.getenv("MONGO_PORT", "27017"))
        self.MONGO_DB   = os.getenv("MONGO_DB", "ARMI")
        self.MONGO_USER = os.getenv("MONGO_USER", "appuser")
        self.MONGO_PASS = os.getenv("MONGO_PASS", "apppass")
        self.MONGO_AUTH_SOURCE = os.getenv("MONGO_AUTH_SOURCE", self.MONGO_DB)


        self.MONGO_URI  = os.getenv(
            "MONGO_URI",
            f"mongodb://{self.MONGO_USER}:{self.MONGO_PASS}@{self.MONGO_HOST}:{self.MONGO_PORT}/{self.MONGO_DB}?authSource={self.MONGO_AUTH_SOURCE}"
        )
        self.COLLECTION = os.getenv("MONGO_COLLECTION", "soldiers")