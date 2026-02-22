import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()


class Settings(BaseSettings):
    # Database
    database_url: str = os.getenv(
        "DATABASE_URL",
        "sqlite:///./okto.db"  # Default SQLite for MVP
    )

    # JWT
    secret_key: str = os.getenv(
        "SECRET_KEY",
        "your-secret-key-change-in-production"
    )
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    # NewsAPI
    newsapi_key: str = os.getenv("NEWSAPI_KEY", "")

    # App
    app_name: str = "Okto API"
    app_version: str = "0.1.0"
    debug: bool = os.getenv("DEBUG", "true").lower() == "true"

    class Config:
        env_file = ".env"


settings = Settings()
