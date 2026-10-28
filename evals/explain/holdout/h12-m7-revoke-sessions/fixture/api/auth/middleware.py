import jwt

from api.auth.keys import SIGNING_KEY


def authenticate(request):
    header = request.headers.get("Authorization", "")
    if not header.startswith("Bearer "):
        return None
    claims = jwt.decode(header.removeprefix("Bearer "), SIGNING_KEY, algorithms=["HS256"])
    return claims["sub"]
