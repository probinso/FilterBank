async def health_handler() -> dict[str, str]:
    """Return application health status."""
    return {"status": "healthy"}
