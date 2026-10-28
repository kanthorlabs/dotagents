CREATE TABLE products (
    id bigserial PRIMARY KEY,
    sku text NOT NULL UNIQUE,
    legacy_sku text,
    name text NOT NULL,
    price_cents integer NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now()
);
