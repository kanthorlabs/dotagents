from app.db import pool


def hold_seats(event_id, seat_ids):
    with pool.connection() as conn:
        conn.execute(
            "UPDATE seats SET held_until = now() + interval '10 minutes' "
            "WHERE event_id = %s AND id = ANY(%s) AND held_until IS NULL",
            (event_id, seat_ids),
        )
