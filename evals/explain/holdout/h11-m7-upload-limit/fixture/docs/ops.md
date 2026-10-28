# pinewood-docs operations

- nginx buffers each request body to `/var/cache/nginx/client_temp` before it passes the request to `pinewood-app`. The volume holds 20 GB.
- `pinewood-app` runs under gunicorn with 4 sync workers.
- Uploads from `pinewood-app` to the bucket `pinewood-files` run at about 60 MB per second.
- `storage.presign_post` exists in `app/storage.py`, but no code calls it. The web client uploads with a plain form POST to `/api/files`.
