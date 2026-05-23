import warnings

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 480
    UPLOAD_DIR: str = "./uploads"
    CORS_ORIGINS: list[str] = [
        "http://localhost:5173",
        "http://localhost:3000",
        "http://localhost",
        "http://81.10.109.140",
        "http://192.168.1.50",
    ]
    # ⚠️ CORS_ORIGINS must NOT contain wildcard ("*") when credentials are enabled

    def model_post_init(self, __context):
        if self.SECRET_KEY in ("change-this-in-production-use-random-32-chars", "super-secret-inventory-erp-key-2026-change-in-production"):
            warnings.warn("⚠️ SECRET_KEY is still set to a default/placeholder value! Generate a strong random key with: openssl rand -hex 32")

    class Config:
        env_file = ".env"


settings = Settings()
