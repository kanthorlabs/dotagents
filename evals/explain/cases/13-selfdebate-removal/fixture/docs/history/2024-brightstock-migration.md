# Migration from Brightstock ERP, March 2024

`importers/brightstock_import.py` loaded 6,140 products from Brightstock once, on 12 March 2024.
Each product received a new `sku`. The column `legacy_sku` keeps the Brightstock item code.
Products created after the migration have no `legacy_sku`.
Our wholesale partner Oakline Supply still keys its catalog on the Brightstock code.
The nightly job `partner_feed_export` sends the feed to Oakline Supply.
