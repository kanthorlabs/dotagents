from flask import Flask


def create_app():
    app = Flask(__name__)
    app.config.from_object("app.settings")
    from app.uploads import uploads

    app.register_blueprint(uploads)
    return app
