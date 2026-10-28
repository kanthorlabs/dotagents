from fastapi import APIRouter, Depends

from admin.auth import admin_user
from pricing import db
from pricing.service import price_cache
from shared.events import publish

router = APIRouter()


@router.post("/admin/prices/{sku}")
def update_price(sku: str, new_price: str, user=Depends(admin_user)):
    db.write_price(sku, new_price, changed_by=user.email)
    price_cache.pop(sku, None)
    publish("price.changed", {"sku": sku, "price": new_price})
    return {"sku": sku, "price": new_price}
