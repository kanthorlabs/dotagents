import os

import requests

PAYRAIL_URL = "https://api.payrail.example/v1/charges"


def charge(customer_id, amount_cents, description):
    response = requests.post(
        PAYRAIL_URL,
        json={"customer": customer_id, "amount": amount_cents, "currency": "eur", "description": description},
        headers={"Authorization": f"Bearer {os.environ['PAYRAIL_SECRET']}"},
        timeout=15,
    )
    response.raise_for_status()
    return response.json()["id"]
