import asyncio
from concurrent.futures import ThreadPoolExecutor

from fastapi import FastAPI

from ranker.model import RankRequest, score

app = FastAPI()
executor = ThreadPoolExecutor(max_workers=64)


@app.post("/rank")
async def rank(request: RankRequest):
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(executor, score, request)
