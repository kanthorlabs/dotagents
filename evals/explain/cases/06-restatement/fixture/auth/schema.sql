CREATE TABLE sessions (
    id text PRIMARY KEY,
    user_id bigint NOT NULL,
    last_seen_at timestamptz NOT NULL
);
