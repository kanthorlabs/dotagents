# harbor-orders API

## GET /orders?page=N

Returns 50 orders per page, newest first. Page numbers start at 1.
Clients export all orders by requesting pages until a page holds fewer than 50 orders.

The database is PostgreSQL 16. Table `orders` has primary key `id` (bigserial).
