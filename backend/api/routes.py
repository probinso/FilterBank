from fastapi import APIRouter

from .handlers import health_handler

router = APIRouter(prefix="/api", tags=["api"])

router.get("/status")(health_handler)
