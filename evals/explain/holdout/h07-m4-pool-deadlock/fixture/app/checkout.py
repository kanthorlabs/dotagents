from app.db import pool
from app.seats import hold_seats


def checkout(order):
    with pool.connection() as conn:
        with conn.transaction():
            conn.execute(
                "INSERT INTO orders (id, event_id, customer_id, status) VALUES (%s, %s, %s, 'pending')",
                (order.id, order.event_id, order.customer_id),
            )
            hold_seats(order.event_id, order.seat_ids)
            conn.execute("UPDATE orders SET status = 'held' WHERE id = %s", (order.id,))
    return order.id
