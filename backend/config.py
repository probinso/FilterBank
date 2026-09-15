from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "app"
    debug: bool = False
    port: int = 8008

    class Config:
        env_file = ".env"
