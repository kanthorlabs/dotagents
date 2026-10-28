from stockpile import locks, purchasing


def run_reorder(region_config, db):
    if not locks.acquire("reorder", backend=region_config["lock_backend"], ttl_seconds=60):
        return "skipped"
    for item in db.items_below_reorder_point():
        purchasing.create_purchase_order(item.sku, item.reorder_quantity)
    return "done"
