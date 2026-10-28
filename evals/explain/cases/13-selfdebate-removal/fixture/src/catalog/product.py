from dataclasses import dataclass


@dataclass
class Product:
    id: int
    sku: str
    name: str
    price_cents: int


def load(db, product_id):
    row = db.query_one("SELECT id, sku, name, price_cents FROM products WHERE id = %s", (product_id,))
    return Product(**row)
