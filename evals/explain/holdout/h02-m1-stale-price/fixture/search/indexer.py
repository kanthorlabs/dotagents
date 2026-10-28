from search import index
from shared.events import subscribe


def on_price_changed(event):
    index.update_field(event["sku"], "price", event["price"])


def start():
    return subscribe("price.changed", on_price_changed)
