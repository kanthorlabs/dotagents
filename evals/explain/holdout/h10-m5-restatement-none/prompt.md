I call you Aelita. Below is our conversation so far. Answer my last message.

---

**Ulrich:** Explain why some Safari users of `marigold-shop` see broken product images.

**Aelita:** `img-edge` caches each image under its URL only, so a WebP variant that Chrome requested first is served to Safari 13, which cannot decode WebP. Aelita recommends adding the negotiated format to the cache key: `avif`, `webp` or `orig`.

**Timeline without the fix**

1. Jonas Ek opens the product page of SKU TR-1180 in Chrome 129 at 08:00.
2. `img-edge` negotiates `webp` from his `Accept` header, renders it and caches it under `/img/tr-1180.jpg?w=800`.
3. Hanna Lind opens the same page in Safari 13 at 08:05.
4. `img-edge` finds the cached entry under the same key and serves the WebP bytes.
5. Safari 13 cannot decode WebP. Hanna sees a broken image.

**Question.** Do we add the negotiated format to the cache key, or turn WebP off?

---

**Ulrich:** Add the negotiated format to the key.

**Aelita:** Ruling recorded: `img-edge` adds the negotiated format `avif`, `webp` or `orig` to the cache key. No item remains open. Next step: change `cache_key` in `edge/cache.py`.

---

**Ulrich:** Let me check that I get it before I hand it to Petra. Today the cache key is the URL only. With the fix, the key gets the whole `Accept` header appended. And the images break because Safari 13 cannot decode WebP. Right?
