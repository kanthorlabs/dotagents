from pinecrest import config, auth_client


def on_request(request):
    session_id = request.cookies.get("pc_session")
    if session_id is None:
        return
    if config.get("touch_on_request"):
        auth_client.touch(session_id)
