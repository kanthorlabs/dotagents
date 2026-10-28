import time

from mailer import config, smtp


def handle_bounce(message, attempt):
    if attempt >= config.BOUNCE_RETRY_LIMIT:
        message.mark_failed()
        return
    time.sleep(config.BOUNCE_RETRY_INTERVAL_SECONDS)
    smtp.send(message, relay=config.SMTP_RELAY)
