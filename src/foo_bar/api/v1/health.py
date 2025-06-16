import logging
from datetime import datetime

from celery import current_app
from django.core.cache import cache
from django.db import connection
from django.http import JsonResponse
from django.views import View
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods

logger = logging.getLogger(__name__)


@csrf_exempt
@require_http_methods(["GET", "HEAD"])
class HealthCheckView(View):
    """
    Verify critical components of the system.
    """

    def get(self, request):
        health_status = {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "checks": {},
        }

        # Check 1: Database
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                result = cursor.fetchone()
                if result and result[0] == 1:
                    health_status["checks"]["database"] = {
                        "status": "healthy",
                        "response_time": connection.queries[-1]["time"]
                        if connection.queries
                        else "0",
                    }
                else:
                    raise Exception("Database query returned unexpected result")
        except Exception as e:
            logger.error(f"Database health check failed: {str(e)}")
            health_status["status"] = "unhealthy"
            health_status["checks"]["database"] = {"status": "unhealthy", "error": str(e)}

        # Check 2: Redis Cache
        try:
            test_key = "health_check_test"
            test_value = "ok"
            cache.set(test_key, test_value, 5)
            retrieved_value = cache.get(test_key)

            if retrieved_value == test_value:
                health_status["checks"]["redis"] = {"status": "healthy"}
                cache.delete(test_key)
            else:
                raise Exception("Cache test failed: value mismatch")
        except Exception as e:
            logger.error(f"Redis health check failed: {str(e)}")
            health_status["status"] = "unhealthy"
            health_status["checks"]["redis"] = {"status": "unhealthy", "error": str(e)}

        # Check 3: Celery Workers
        try:
            inspector = current_app.control.inspect()
            active_queues = inspector.active_queues()

            if active_queues:
                worker_count = len(active_queues)
                health_status["checks"]["celery"] = {
                    "status": "healthy",
                    "workers": worker_count,
                    "queues": list(active_queues.keys()),
                }
            else:
                health_status["status"] = "unhealthy"
                health_status["checks"]["celery"] = {
                    "status": "unhealthy",
                    "error": "No active workers found",
                }
        except Exception as e:
            logger.error(f"Celery health check failed: {str(e)}")
            health_status["status"] = "unhealthy"
            health_status["checks"]["celery"] = {"status": "unhealthy", "error": str(e)}

        # Check 4: Disk Space
        try:
            import shutil

            stat = shutil.disk_usage("/")
            disk_usage_percent = (stat.used / stat.total) * 100

            if disk_usage_percent < 90:
                health_status["checks"]["disk"] = {
                    "status": "healthy",
                    "usage_percent": round(disk_usage_percent, 2),
                }
            else:
                health_status["status"] = "unhealthy"
                health_status["checks"]["disk"] = {
                    "status": "unhealthy",
                    "usage_percent": round(disk_usage_percent, 2),
                    "error": "Disk usage above 90%",
                }
        except Exception as e:
            logger.warning(f"Disk check failed: {str(e)}")
            health_status["checks"]["disk"] = {"status": "unknown", "error": str(e)}

        status_code = 200 if health_status["status"] == "healthy" else 503

        return JsonResponse(health_status, status=status_code)


@csrf_exempt
@require_http_methods(["GET"])
class SimpleHealthCheckView(View):
    """
    Verify that Django is up and responding.
    """

    def get(self, request):
        return JsonResponse({"status": "ok"})


@csrf_exempt
@require_http_methods(["GET"])
class ReadinessCheckView(View):
    """
    Verify is the application is ready to receive requests.
    """

    def get(self, request):
        ready = True
        details = {}

        try:
            from django.db.migrations.executor import MigrationExecutor

            executor = MigrationExecutor(connection)
            plan = executor.migration_plan(executor.loader.graph.leaf_nodes())
            if plan:
                ready = False
                details["migrations"] = "Pending migrations"
            else:
                details["migrations"] = "All migrations applied"
        except Exception as e:
            ready = False
            details["migrations"] = f"Error checking migrations: {str(e)}"

        status_code = 200 if ready else 503
        return JsonResponse({"ready": ready, "details": details}, status=status_code)
