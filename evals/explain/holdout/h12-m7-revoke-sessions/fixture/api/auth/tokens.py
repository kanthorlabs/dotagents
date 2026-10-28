import hashlib
import secrets
from datetime import datetime, timedelta, timezone

import jwt

from api import db
from api.auth.keys import SIGNING_KEY

ACCESS_TTL = timedelta(minutes=15)
REFRESH_TTL = timedelta(days=30)


def _hash(token):
    return hashlib.sha256(token.encode()).hexdigest()


def issue_tokens(user, device_name):
    now = datetime.now(timezone.utc)
    access = jwt.encode({"sub": str(user.id), "iat": now, "exp": now + ACCESS_TTL}, SIGNING_KEY, algorithm="HS256")
    refresh = secrets.token_urlsafe(32)
    db.execute(
        "INSERT INTO refresh_tokens (token_hash, user_id, device_name, expires_at) VALUES (%s, %s, %s, %s)",
        _hash(refresh),
        user.id,
        device_name,
        now + REFRESH_TTL,
    )
    return access, refresh


def refresh_session(refresh_token):
    row = db.one(
        "DELETE FROM refresh_tokens WHERE token_hash = %s AND expires_at > now() RETURNING user_id, device_name",
        _hash(refresh_token),
    )
    if row is None:
        raise PermissionError("invalid refresh token")
    user = db.one("SELECT * FROM users WHERE id = %s", row.user_id)
    return issue_tokens(user, row.device_name)
