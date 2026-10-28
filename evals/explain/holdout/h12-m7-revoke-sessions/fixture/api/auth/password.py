from api import db
from api.auth.hashing import hash_password, verify_password
from api.auth.tokens import issue_tokens


def change_password(user, old_password, new_password, device_name):
    if not verify_password(old_password, user.password_hash):
        raise PermissionError("wrong password")
    db.execute("UPDATE users SET password_hash = %s WHERE id = %s", hash_password(new_password), user.id)
    return issue_tokens(user, device_name)
