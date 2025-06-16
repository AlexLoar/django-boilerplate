from django.urls import path  # noqa F401
from .api.v1.health import HealthCheckView, SimpleHealthCheckView, ReadinessCheckView

urlpatterns = [
    path("health/", HealthCheckView.as_view()),
    path("simple_health/", SimpleHealthCheckView.as_view()),
    path("readiness_check/", ReadinessCheckView.as_view()),
]
