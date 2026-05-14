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
from apps.restaurant.v1_views import (
    V1AllTablesView,
    V1CashierOrderAcceptView,
    V1CashierPaymentsView,
    V1CashierTableBillView,
    V1CashierTableCloseView,
    V1DashboardSummaryView,
    V1DirectorWaiterDetailView,
    V1DirectorWaitersView,
    V1MenuCategoryViewSet,
    V1MenuItemViewSet,
    V1OrderViewSet,
    V1RevenueReportView,
    V1StaffMeView,
    V1TablesViewSet,
    V1WaitersReportView,
)


router = DefaultRouter()
router.register("staff/tables", TableViewSet, basename="table")
router.register("staff/menu/categories", MenuCategoryViewSet, basename="menu-category")
router.register("staff/menu/items", MenuItemViewSet, basename="menu-item")
router.register("staff/orders", OrderViewSet, basename="order")
router.register("cashier/payments", PaymentViewSet, basename="payment")

v1_router = DefaultRouter()
v1_router.register("tables", V1TablesViewSet, basename="v1-table")
v1_router.register("menu/categories", V1MenuCategoryViewSet, basename="v1-menu-category")
v1_router.register("menu/items", V1MenuItemViewSet, basename="v1-menu-item")
v1_router.register("orders", V1OrderViewSet, basename="v1-order")

urlpatterns = [
    path("admin/", admin.site.urls),
    path("accounts/", include("django.contrib.auth.urls")),
    path("cashier/", include("apps.cashier.urls")),
    # Non-versioned API
    path("api/auth/login/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/auth/me/", StaffMeView.as_view(), name="staff-me"),
    path("api/dashboard/summary/", DashboardSummaryView.as_view(), name="dashboard-summary"),
    path("api/", include(router.urls)),
    # v1 API
    path("api/v1/auth/login", TokenObtainPairView.as_view(), name="v1-token-obtain-pair"),
    path("api/v1/auth/refresh", TokenRefreshView.as_view(), name="v1-token-refresh"),
    path("api/v1/auth/me", V1StaffMeView.as_view(), name="v1-staff-me"),
    path("api/v1/dashboard/summary", V1DashboardSummaryView.as_view(), name="v1-dashboard-summary"),
    path("api/v1/waiter/all-tables", V1AllTablesView.as_view(), name="v1-waiter-all-tables"),
    path("api/v1/director/waiters", V1DirectorWaitersView.as_view(), name="v1-director-waiters"),
    path("api/v1/director/waiters/<int:pk>", V1DirectorWaiterDetailView.as_view(), name="v1-director-waiter-detail"),
    path("api/v1/director/reports/revenue", V1RevenueReportView.as_view(), name="v1-revenue-report"),
    path("api/v1/director/reports/waiters", V1WaitersReportView.as_view(), name="v1-waiters-report"),
    path("api/v1/cashier/payments", V1CashierPaymentsView.as_view(), name="v1-cashier-payments"),
    path("api/v1/cashier/orders/<int:order_id>/accept", V1CashierOrderAcceptView.as_view(), name="v1-cashier-order-accept"),
    path("api/v1/cashier/tables/<int:table_id>/bill", V1CashierTableBillView.as_view(), name="v1-cashier-table-bill"),
    path("api/v1/cashier/tables/<int:table_id>/close", V1CashierTableCloseView.as_view(), name="v1-cashier-table-close"),
    path("api/v1/", include(v1_router.urls)),
]
