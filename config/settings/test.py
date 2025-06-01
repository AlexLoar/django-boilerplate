import os

from config.settings.base import *  # noqa F403

TEST_RUNNER = "django.test.runner.DiscoverRunner"

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
    }
}

DEBUG = False

PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.MD5PasswordHasher",
]

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
        "LOCATION": "unique-snowflake",
    }
}

MEDIA_ROOT = os.path.join(BASE_DIR, "test_media")  # noqa F405
EMAIL_BACKEND = "django.core.mail.backends.locmem.EmailBackend"

LOGGING = {
    "version": 1,
    "disable_existing_loggers": True,
    "handlers": {
        "null": {
            "class": "logging.NullHandler",
        },
    },
    "loggers": {
        "django": {
            "handlers": ["null"],
            "propagate": False,
        },
    },
}

SECRET_KEY = "TEST-SECRET_KEY"
ALLOWED_HOSTS = ["*"]
