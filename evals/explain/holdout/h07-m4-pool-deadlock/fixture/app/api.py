from fastapi import FastAPI

from app.checkout import checkout
from app.models import Order

app = FastAPI()


@app.post("/checkout")
def post_checkout(order: Order):
    return {"order_id": checkout(order)}
