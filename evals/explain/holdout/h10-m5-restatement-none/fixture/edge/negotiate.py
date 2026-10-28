def negotiate(accept_header):
    if "image/avif" in accept_header:
        return "avif"
    if "image/webp" in accept_header:
        return "webp"
    return "orig"
