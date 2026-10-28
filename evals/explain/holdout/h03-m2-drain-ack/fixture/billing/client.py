import requests

METER_URL = "https://meter.internal/v1/usage"


def record_usage(account_id, metric, ref):
    response = requests.post(
        METER_URL,
        json={"account_id": account_id, "metric": metric, "ref": ref, "quantity": 1},
        timeout=5,
    )
    response.raise_for_status()
