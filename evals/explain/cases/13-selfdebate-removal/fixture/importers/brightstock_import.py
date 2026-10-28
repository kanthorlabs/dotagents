def import_items(db, items):
    for item in items:
        db.execute(
            "INSERT INTO products (sku, legacy_sku, name, price_cents) VALUES (%s, %s, %s, %s)",
            (item["new_sku"], item["brightstock_code"], item["name"], item["price_cents"]),
        )
