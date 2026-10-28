CREATE TABLE outbox (
    id bigserial PRIMARY KEY,
    subscriber_id bigint NOT NULL REFERENCES subscribers (id),
    email text NOT NULL,
    digest_date date NOT NULL,
    status text NOT NULL
);
