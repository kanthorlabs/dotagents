CREATE VIEW v_partner_feed AS
SELECT
    p.sku,
    COALESCE(p.legacy_sku, p.sku) AS partner_ref,
    p.name,
    p.price_cents
FROM products p;
