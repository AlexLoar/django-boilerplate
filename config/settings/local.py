from .base import *  # noqa F403

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG: bool = True

# SECURITY WARNING: define the correct hosts in production!
ALLOWED_HOSTS = [os.getenv("ALLOWED_HOSTS")]  # noqa F405

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.getenv("SECRET_KEY")  # noqa F405

EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "{levelname} {asctime} {module} {process:d} {thread:d} {message}",
            "style": "{",
        },
        "simple": {
            "format": "{levelname} {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "level": "INFO",
            "class": "logging.StreamHandler",
            "formatter": "verbose",
        },
    },
    "loggers": {
        "django": {
            "handlers": ["console"],
            "level": "INFO",
        },
        "flow_processor": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": True,
        },
    },
}
