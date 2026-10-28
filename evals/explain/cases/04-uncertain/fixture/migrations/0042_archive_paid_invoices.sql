-- applied 2026-10-25 22:10 UTC
UPDATE invoices
SET status = 'archived'
WHERE status = 'paid';
