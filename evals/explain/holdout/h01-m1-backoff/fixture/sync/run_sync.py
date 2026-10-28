import logging
from concurrent.futures import ThreadPoolExecutor

from sync.crm_client import upsert_contact
from sync.source import changed_contacts, mark_synced

WORKERS = 8

log = logging.getLogger("tidepool-sync")


def sync_one(contact):
    try:
        upsert_contact(contact)
    except Exception as error:
        log.warning("upsert failed external_id=%s error=%s", contact["external_id"], error)
        return
    mark_synced(contact["external_id"])


def main():
    contacts = changed_contacts()
    log.info("sync start: %d changed contacts", len(contacts))
    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        list(pool.map(sync_one, contacts))
