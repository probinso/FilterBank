from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi_events.middleware import EventHandlerASGIMiddleware
from fastapi_events.handlers.local import local_handler
from contextlib import asynccontextmanager

from api.routes import router
from config import Settings
from pydantic import BaseModel

import sys
import time
import functools

settings = Settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup
    yield
    # shutdown


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["tauri://localhost", "http://localhost:1234"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(
    EventHandlerASGIMiddleware,
    handlers=[local_handler]
)

app.include_router(router)


def called(func, slow: bool = True):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print(func.__name__, file=sys.stderr)
        if slow:
            time.sleep(.5)
        return func(*args, **kwargs)
    return wrapper

@app.get("/health")
@called
async def health() -> dict[str, str]:
    return {"status": "ok"}


class CountRequest(BaseModel):
    count: int


@app.post("/counter/inc")
@called
def increment(req: CountRequest):
    return {"count": req.count + 1}


@app.post("/counter/dec")
@called
def decrement(req: CountRequest):
    return {"count": req.count - 1}
