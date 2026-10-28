from edge.cache import lookup, save
from edge.negotiate import negotiate
from edge.render import render


def serve_image(request):
    cached = lookup(request)
    if cached is not None:
        return cached
    image_format = negotiate(request.headers.get("Accept", ""))
    body, content_type = render(request.path, request.query, image_format)
    save(request, body, content_type)
    return body, content_type
