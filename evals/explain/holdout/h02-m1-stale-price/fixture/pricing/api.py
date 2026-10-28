from fastapi import APIRouter

from pricing.service import get_price

router = APIRouter()


@router.get("/api/prices")
def prices(sku: str):
    return {"sku": sku, "price": str(get_price(sku))}
