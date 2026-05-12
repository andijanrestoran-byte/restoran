from django.contrib.auth.models import User
from django.db.models import Count, Q, Sum
from django.utils import timezone
from rest_framework import generics, status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import DiningTable, MenuCategory, MenuItem, Order, OrderStatus, StaffProfile, StaffRole
from .permissions import IsDirectorOrCashier, IsRestaurantStaff, IsWaiter
from .serializers import (
    DiningTableSerializer,
    MenuCategorySerializer,
    MenuItemSerializer,
    OrderSerializer,
    OrderStatusSerializer,
    PaymentSerializer,
    StaffProfileSerializer,
)


class StaffMeView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = StaffProfileSerializer

    def get_object(self) -> StaffProfile:
        return self.request.user.staff_profile


class DashboardSummaryView(APIView):
    permission_classes = [IsDirectorOrCashier]

    def get(self, request, *args, **kwargs):
        today = timezone.localdate()
        today_orders = Order.objects.filter(created_at__date=today)
        paid_today = today_orders.filter(status=OrderStatus.PAID)

        data = {
            "tables": {
                "total": DiningTable.objects.count(),
                "busy": DiningTable.objects.filter(Q(is_busy=True) | Q(orders__status=OrderStatus.ACTIVE)).distinct().count(),
                "free": DiningTable.objects.exclude(Q(is_busy=True) | Q(orders__status=OrderStatus.ACTIVE)).distinct().count(),
            },
            "staff": {
                "waiters": User.objects.filter(staff_profile__role=StaffRole.WAITER).count(),
                "cashiers": User.objects.filter(staff_profile__role=StaffRole.CASHIER).count(),
                "directors": User.objects.filter(staff_profile__role=StaffRole.DIRECTOR).count(),
            },
            "orders": {
                "today_total": today_orders.count(),
                "active": Order.objects.filter(status=OrderStatus.ACTIVE).count(),
                "rejected": Order.objects.filter(status=OrderStatus.REJECTED).count(),
                "paid_today": paid_today.count(),
            },
            "payments": {
                "cash": str(
                    paid_today.filter(payment_method="cash").aggregate(total=Sum("paid_amount"))["total"]
                    or 0
                ),
                "card": str(
                    paid_today.filter(payment_method="card").aggregate(total=Sum("paid_amount"))["total"]
                    or 0
                ),
                "total": str(paid_today.aggregate(total=Sum("paid_amount"))["total"] or 0),
            },
        }
        return Response(data)


class TableViewSet(viewsets.ModelViewSet):
    queryset = DiningTable.objects.prefetch_related("assigned_waiters").all()
    serializer_class = DiningTableSerializer
    permission_classes = [IsRestaurantStaff]
    filterset_fields = ("is_busy",)
    search_fields = ("number", "location")
    ordering_fields = ("number", "seats")

    def get_permissions(self):
        if self.action in {"create", "update", "partial_update", "destroy"}:
            return [IsDirectorOrCashier()]
        return super().get_permissions()

    @action(detail=True, methods=["post"], permission_classes=[IsWaiter])
    def join(self, request, pk=None):
        table = self.get_object()
        table.assigned_waiters.add(request.user)
        serializer = self.get_serializer(table)
        return Response(serializer.data)


class MenuCategoryViewSet(viewsets.ModelViewSet):
    queryset = MenuCategory.objects.all()
    serializer_class = MenuCategorySerializer
    permission_classes = [IsDirectorOrCashier]
    search_fields = ("name",)
    ordering_fields = ("sort_order", "name")


class MenuItemViewSet(viewsets.ModelViewSet):
    queryset = MenuItem.objects.select_related("category").all()
    serializer_class = MenuItemSerializer
    permission_classes = [IsRestaurantStaff]
    filterset_fields = ("category", "is_active")
    search_fields = ("name", "description", "category__name")
    ordering_fields = ("name", "price", "created_at")

    def get_permissions(self):
        if self.action in {"create", "update", "partial_update", "destroy"}:
            return [IsDirectorOrCashier()]
        return super().get_permissions()


class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.select_related("table", "waiter").prefetch_related("items__menu_item").all()
    serializer_class = OrderSerializer
    permission_classes = [IsRestaurantStaff]
    filterset_fields = ("status", "table", "waiter")
    search_fields = ("id", "table__number", "waiter__username", "waiter__first_name", "waiter__last_name")
    ordering_fields = ("created_at", "updated_at", "total_amount")

    def get_queryset(self):
        queryset = super().get_queryset()
        profile = self.request.user.staff_profile
        if profile.role == StaffRole.WAITER:
            queryset = queryset.filter(waiter=self.request.user)
        return queryset

    def get_serializer_class(self):
        if self.action in {"reject", "cancel"}:
            return OrderStatusSerializer
        return super().get_serializer_class()

    def perform_create(self, serializer):
        serializer.save()

    @action(detail=True, methods=["post"], permission_classes=[IsDirectorOrCashier])
    def reject(self, request, pk=None):
        order = self.get_object()
        serializer = OrderStatusSerializer(order, data={"status": OrderStatus.REJECTED})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(OrderSerializer(order, context=self.get_serializer_context()).data)

    @action(detail=True, methods=["post"], permission_classes=[IsDirectorOrCashier])
    def cancel(self, request, pk=None):
        order = self.get_object()
        serializer = OrderStatusSerializer(order, data={"status": OrderStatus.CANCELLED})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(OrderSerializer(order, context=self.get_serializer_context()).data)


class PaymentViewSet(viewsets.GenericViewSet):
    queryset = Order.objects.select_related("table", "waiter").all()
    serializer_class = PaymentSerializer
    permission_classes = [IsDirectorOrCashier]
    filterset_fields = ("status", "payment_method")
    search_fields = ("id", "table__number", "waiter__username")
    ordering_fields = ("created_at", "closed_at", "total_amount")

    def list(self, request, *args, **kwargs):
        queryset = self.filter_queryset(self.get_queryset())
        data = OrderSerializer(queryset, many=True, context={"request": request}).data
        return Response(data)

    def retrieve(self, request, *args, **kwargs):
        order = self.get_object()
        data = OrderSerializer(order, context={"request": request}).data
        return Response(data)

    def partial_update(self, request, *args, **kwargs):
        order = self.get_object()
        serializer = self.get_serializer(order, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(OrderSerializer(order, context={"request": request}).data, status=status.HTTP_200_OK)
