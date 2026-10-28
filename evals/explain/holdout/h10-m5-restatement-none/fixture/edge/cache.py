from edge.store import store


def cache_key(request):
    return f"{request.path}?{request.query_string}"


def lookup(request):
    return store.get(cache_key(request))


def save(request, body, content_type):
    store.set(cache_key(request), (body, content_type), ttl=86400)
