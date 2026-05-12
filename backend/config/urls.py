from django.contrib import admin
from django.urls import include, path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from apps.restaurant.views import (
    DashboardSummaryView,
    MenuCategoryViewSet,
    MenuItemViewSet,
    OrderViewSet,
    PaymentViewSet,
    StaffMeView,
    TableViewSet,
)


router = DefaultRouter()
router.register("staff/tables", TableViewSet, basename="table")
router.register("staff/menu/categories", MenuCategoryViewSet, basename="menu-category")
router.register("staff/menu/items", MenuItemViewSet, basename="menu-item")
router.register("staff/orders", OrderViewSet, basename="order")
router.register("cashier/payments", PaymentViewSet, basename="payment")

urlpatterns = [
    path("admin/", admin.site.urls),
    path("accounts/", include("django.contrib.auth.urls")),
    path("cashier/", include("apps.cashier.urls")),
    path("api/auth/login/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/auth/me/", StaffMeView.as_view(), name="staff-me"),
    path("api/dashboard/summary/", DashboardSummaryView.as_view(), name="dashboard-summary"),
    path("api/", include(router.urls)),
]
