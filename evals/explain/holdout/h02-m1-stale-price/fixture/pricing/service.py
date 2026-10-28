from cachetools import TTLCache

from pricing import db

price_cache = TTLCache(maxsize=50_000, ttl=3600)


def get_price(sku):
    if sku in price_cache:
        return price_cache[sku]
    price = db.fetch_price(sku)
    price_cache[sku] = price
    return price
