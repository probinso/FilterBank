import functools
import sys
import time
from contextlib import asynccontextmanager

from api.routes import router
from config import Settings
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

settings = Settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup
    yield
    # shutdown


app = FastAPI(lifespan=lifespan)
event_handler_id: int = id(app)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["tauri://localhost", "http://localhost:1234"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


def called(func, slow: bool = True):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        print(func.__name__, file=sys.stderr)
        if slow:
            time.sleep(0.5)
        return func(*args, **kwargs)

    return wrapper


@app.get("/health")
@called
async def health() -> dict[str, str]:
    return {"status": "ok"}


class CountRequest(BaseModel):
    count: int


registry: dict[str, callable] = {}
events = []


def registered_endpoint_event(app, method: str, end_point: str):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            events.append(end_point)
            return func(*args, **kwargs)

        assert end_point not in registry
        registry[end_point] = wrapper
        getattr(app, method)(end_point)(wrapper)  # register the route
        return wrapper

    return decorator


@app.post("/counter/replay")
@called
def replay(req: CountRequest):
    for e in events:
        req = registry[e](req)
    return req


@registered_endpoint_event(app, "post", "/counter/inc")
@called
def increment(req: CountRequest):
    return CountRequest(count=req.count + 1)


@registered_endpoint_event(app, "post", "/counter/dec")
@called
def decrement(req: CountRequest):
    return CountRequest(count=req.count - 1)
