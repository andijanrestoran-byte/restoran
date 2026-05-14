from django.contrib.auth.models import User
from django.db.models import Count, Q, Sum
from django.utils import timezone
from rest_framework import generics, status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .models import DiningTable, MenuCategory, MenuItem, Order, OrderItem, OrderStatus, StaffProfile, StaffRole
from .permissions import IsDirector, IsDirectorOrCashier, IsRestaurantStaff, IsWaiter
from .serializers import OrderSerializer, OrderStatusSerializer
from .v1_serializers import (
    V1DiningTableSerializer,
    V1MenuCategorySerializer,
    V1MenuItemSerializer,
    V1OrderSerializer,
    V1StaffProfileSerializer,
    V1WaiterCreateSerializer,
    V1WaiterInfoSerializer,
    V1WaiterUpdateSerializer,
)


class V1StaffMeView(generics.RetrieveAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = V1StaffProfileSerializer

    def get_object(self):
        return self.request.user.staff_profile


class V1DashboardSummaryView(APIView):
    permission_classes = [IsDirectorOrCashier]

    def get(self, request, *args, **kwargs):
        today = timezone.localdate()
        today_orders = Order.objects.filter(created_at__date=today)
        paid_today = today_orders.filter(status=OrderStatus.PAID)
        active_orders = Order.objects.filter(status=OrderStatus.ACTIVE)

        free_tables = DiningTable.objects.exclude(
            Q(is_busy=True) | Q(orders__status=OrderStatus.ACTIVE)
        ).distinct().count()
        busy_tables = DiningTable.objects.filter(
            Q(is_busy=True) | Q(orders__status=OrderStatus.ACTIVE)
        ).distinct().count()
        assigned_tables = DiningTable.objects.filter(assigned_waiters__isnull=False).distinct().count()

        data = {
            "tables": {
                "total": DiningTable.objects.count(),
                "free": free_tables,
                "busy": busy_tables,
                "assigned": assigned_tables,
            },
            "orders": {
                "active": active_orders.count(),
                "rejected": Order.objects.filter(status=OrderStatus.REJECTED).count(),
                "paid_today": paid_today.count(),
                "today_total": today_orders.count(),
            },
            "payments": {
                "cash_today": str(
                    paid_today.filter(payment_method="cash").aggregate(total=Sum("paid_amount"))["total"] or 0
                ),
                "card_today": str(
                    paid_today.filter(payment_method="card").aggregate(total=Sum("paid_amount"))["total"] or 0
                ),
                "total_today": str(paid_today.aggregate(total=Sum("paid_amount"))["total"] or 0),
            },
            "staff": {
                "active_waiters": User.objects.filter(
                    staff_profile__role=StaffRole.WAITER,
                    assigned_tables__isnull=False,
                ).distinct().count(),
                "waiters": User.objects.filter(staff_profile__role=StaffRole.WAITER).count(),
                "cashiers": User.objects.filter(staff_profile__role=StaffRole.CASHIER).count(),
                "directors": User.objects.filter(staff_profile__role=StaffRole.DIRECTOR).count(),
            },
        }
        return Response(data)


class V1AllTablesView(generics.ListAPIView):
    queryset = DiningTable.objects.prefetch_related("assigned_waiters").all()
    serializer_class = V1DiningTableSerializer
    permission_classes = [IsRestaurantStaff]


class V1TablesViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = DiningTable.objects.prefetch_related("assigned_waiters").all()
    serializer_class = V1DiningTableSerializer
    permission_classes = [IsRestaurantStaff]

    @action(detail=True, methods=["post"], permission_classes=[IsWaiter])
    def join(self, request, pk=None):
        table = self.get_object()
        table.assigned_waiters.add(request.user)
        serializer = self.get_serializer(table)
        return Response(serializer.data)


class V1MenuCategoryViewSet(viewsets.ModelViewSet):
    queryset = MenuCategory.objects.all()
    serializer_class = V1MenuCategorySerializer
    permission_classes = [IsDirectorOrCashier]


class V1MenuItemViewSet(viewsets.ModelViewSet):
    queryset = MenuItem.objects.select_related("category").all()
    serializer_class = V1MenuItemSerializer
    permission_classes = [IsRestaurantStaff]

    def get_permissions(self):
        if self.action in {"create", "update", "partial_update", "destroy"}:
            return [IsDirectorOrCashier()]
        return super().get_permissions()


class V1OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.select_related("table", "waiter").prefetch_related("items__menu_item").all()
    serializer_class = V1OrderSerializer
    permission_classes = [IsRestaurantStaff]

    def get_queryset(self):
        qs = super().get_queryset()
        profile = getattr(self.request.user, "staff_profile", None)
        if profile and profile.role == StaffRole.WAITER:
            qs = qs.filter(waiter=self.request.user)
        return qs

    def get_serializer_class(self):
        if self.action in {"reject", "cancel"}:
            return OrderStatusSerializer
        return super().get_serializer_class()

    @action(detail=True, methods=["post"], permission_classes=[IsDirectorOrCashier])
    def reject(self, request, pk=None):
        order = self.get_object()
        serializer = OrderStatusSerializer(order, data={"status": OrderStatus.REJECTED})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(V1OrderSerializer(order, context=self.get_serializer_context()).data)

    @action(detail=True, methods=["post"], permission_classes=[IsDirectorOrCashier])
    def cancel(self, request, pk=None):
        order = self.get_object()
        serializer = OrderStatusSerializer(order, data={"status": OrderStatus.CANCELLED})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(V1OrderSerializer(order, context=self.get_serializer_context()).data)


class V1DirectorWaitersView(generics.ListCreateAPIView):
    permission_classes = [IsDirector]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return V1WaiterCreateSerializer
        return V1WaiterInfoSerializer

    def get_queryset(self):
        return User.objects.filter(staff_profile__role=StaffRole.WAITER).prefetch_related(
            "assigned_tables", "orders"
        )


class V1DirectorWaiterDetailView(generics.RetrieveUpdateDestroyAPIView):
    permission_classes = [IsDirector]
    queryset = User.objects.filter(staff_profile__role=StaffRole.WAITER)

    def get_serializer_class(self):
        if self.request.method in ("PATCH", "PUT"):
            return V1WaiterUpdateSerializer
        return V1WaiterInfoSerializer


class V1RevenueReportView(APIView):
    permission_classes = [IsDirectorOrCashier]

    def get(self, request, *args, **kwargs):
        period = request.query_params.get("period", "daily")
        today = timezone.localdate()

        if period == "weekly":
            start_date = today - timezone.timedelta(days=today.weekday())
        elif period == "monthly":
            start_date = today.replace(day=1)
        else:
            start_date = today

        paid_orders = Order.objects.filter(
            status=OrderStatus.PAID,
            closed_at__date__gte=start_date,
            closed_at__date__lte=today,
        )

        cash_total = paid_orders.filter(payment_method="cash").aggregate(
            total=Sum("paid_amount")
        )["total"] or 0
        card_total = paid_orders.filter(payment_method="card").aggregate(
            total=Sum("paid_amount")
        )["total"] or 0
        grand_total = paid_orders.aggregate(total=Sum("paid_amount"))["total"] or 0

        daily_breakdown = []
        current = start_date
        while current <= today:
            day_orders = paid_orders.filter(closed_at__date=current)
            day_cash = day_orders.filter(payment_method="cash").aggregate(
                total=Sum("paid_amount")
            )["total"] or 0
            day_card = day_orders.filter(payment_method="card").aggregate(
                total=Sum("paid_amount")
            )["total"] or 0
            day_total = day_orders.aggregate(total=Sum("paid_amount"))["total"] or 0
            daily_breakdown.append({
                "date": current.isoformat(),
                "cash": str(day_cash),
                "card": str(day_card),
                "total": str(day_total),
            })
            current += timezone.timedelta(days=1)

        data = {
            "period": period,
            "totals": {
                "cash": str(cash_total),
                "card": str(card_total),
                "total": str(grand_total),
            },
            "daily_breakdown": daily_breakdown,
        }
        return Response(data)


class V1WaitersReportView(APIView):
    permission_classes = [IsDirectorOrCashier]

    def get(self, request, *args, **kwargs):
        period = request.query_params.get("period", "daily")
        today = timezone.localdate()

        if period == "weekly":
            start_date = today - timezone.timedelta(days=today.weekday())
        elif period == "monthly":
            start_date = today.replace(day=1)
        else:
            start_date = today

        waiters = User.objects.filter(staff_profile__role=StaffRole.WAITER)
        data = []
        for waiter in waiters:
            waiter_orders = Order.objects.filter(
                waiter=waiter,
                created_at__date__gte=start_date,
                created_at__date__lte=today,
            )
            sold = waiter_orders.filter(status=OrderStatus.PAID).count()
            rejected = waiter_orders.filter(status=OrderStatus.REJECTED).count()
            cancelled = waiter_orders.filter(status=OrderStatus.CANCELLED).count()
            revenue = waiter_orders.filter(status=OrderStatus.PAID).aggregate(
                total=Sum("paid_amount")
            )["total"] or 0

            data.append({
                "id": waiter.id,
                "full_name": waiter.get_full_name() or waiter.username,
                "sold_orders": sold,
                "rejected_orders": rejected,
                "cancelled_orders": cancelled,
                "revenue": str(revenue),
            })

        return Response({"waiters": data})


class V1CashierPaymentsView(APIView):
    permission_classes = [IsDirectorOrCashier]

    def get(self, request, *args, **kwargs):
        orders = Order.objects.filter(status=OrderStatus.PAID).select_related("table", "waiter")
        data = OrderSerializer(orders, many=True, context={"request": request}).data
        return Response(data)

    def post(self, request, *args, **kwargs):
        order_id = request.data.get("order_id")
        payment_method = request.data.get("payment_method")
        amount = request.data.get("amount")

        try:
            order = Order.objects.get(id=order_id, status=OrderStatus.ACTIVE)
        except Order.DoesNotExist:
            return Response({"detail": "Buyurtma topilmadi yoki aktiv emas"}, status=404)

        if amount is None or float(amount) <= 0:
            return Response({"detail": "Noto'g'ri summa"}, status=400)
        if float(amount) != float(order.total_amount):
            return Response({"detail": "Summa buyurtma summasiga teng bo'lishi kerak"}, status=400)

        order.mark_paid(payment_method=payment_method, amount=amount)
        return Response(OrderSerializer(order, context={"request": request}).data)


class V1CashierOrderAcceptView(APIView):
    permission_classes = [IsDirectorOrCashier]

    def post(self, request, order_id):
        try:
            order = Order.objects.get(id=order_id, status=OrderStatus.ACTIVE)
        except Order.DoesNotExist:
            return Response({"detail": "Buyurtma topilmadi"}, status=404)
        return Response(OrderSerializer(order, context={"request": request}).data)


class V1CashierTableBillView(APIView):
    permission_classes = [IsDirectorOrCashier]

    def get(self, request, table_id):
        try:
            table = DiningTable.objects.get(id=table_id)
        except DiningTable.DoesNotExist:
            return Response({"detail": "Stol topilmadi"}, status=404)

        orders = Order.objects.filter(
            table=table, status__in=[OrderStatus.ACTIVE, OrderStatus.PAID]
        ).select_related("waiter").prefetch_related("items__menu_item")

        total = orders.filter(status=OrderStatus.ACTIVE).aggregate(
            total=Sum("total_amount")
        )["total"] or 0

        data = {
            "table": V1DiningTableSerializer(table).data,
            "orders": V1OrderSerializer(orders, many=True, context={"request": request}).data,
            "total": str(total),
        }
        return Response(data)


class V1CashierTableCloseView(APIView):
    permission_classes = [IsDirectorOrCashier]

    def post(self, request, table_id):
        payment_method = request.data.get("payment_method", "cash")
        amount = request.data.get("amount")

        try:
            table = DiningTable.objects.get(id=table_id)
        except DiningTable.DoesNotExist:
            return Response({"detail": "Stol topilmadi"}, status=404)

        active_orders = Order.objects.filter(table=table, status=OrderStatus.ACTIVE)
        if not active_orders.exists():
            return Response({"detail": "Faol buyurtmalar yo'q"}, status=400)

        total = active_orders.aggregate(total=Sum("total_amount"))["total"] or 0
        if amount is None:
            amount = total

        for order in active_orders:
            order.mark_paid(payment_method=payment_method, amount=order.total_amount)

        return Response({
            "status": "closed",
            "table_id": table_id,
            "payment_method": payment_method,
            "amount": str(amount),
        })
