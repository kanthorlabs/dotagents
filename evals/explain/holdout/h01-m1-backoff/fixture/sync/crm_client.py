import os

import requests

BASE_URL = "https://api.junipercrm.example/v2"
API_KEY = os.environ["JUNIPER_API_KEY"]


def upsert_contact(contact):
    response = requests.put(
        f"{BASE_URL}/contacts/{contact['external_id']}",
        json=contact,
        headers={"Authorization": f"Bearer {API_KEY}"},
        timeout=10,
    )
    response.raise_for_status()
    return response.json()
