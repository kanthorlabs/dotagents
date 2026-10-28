from datetime import datetime, timedelta, timezone


def purge_tenant(store, tenant):
    cutoff = datetime.now(timezone.utc) - timedelta(days=tenant.retention_days)
    for upload in store.list_uploads(tenant.id):
        if upload.created_at < cutoff:
            store.delete(upload.id)
