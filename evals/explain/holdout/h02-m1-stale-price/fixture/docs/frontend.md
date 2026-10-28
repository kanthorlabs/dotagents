# saltmarsh-shop frontend

- `shop-api` serves `/product/*`, `/api/*` and `/admin/*`. The load balancer spreads requests over all `shop-api` pods.
- A product page under `/product/*` holds no price in its HTML. After load, the page calls `fetch('/api/prices?sku=...')` and renders the price.
- The cart and the checkout read prices from `/api/prices` too.
