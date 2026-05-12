from decimal import Decimal

from django.contrib.auth.models import User
from rest_framework import serializers

from .models import (
    DiningTable,
    MenuCategory,
    MenuItem,
    Order,
    OrderItem,
    OrderStatus,
    StaffProfile,
)


class StaffProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source="user.username", read_only=True)
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = StaffProfile
        fields = ("username", "full_name", "role", "phone", "shift", "experience")

    def get_full_name(self, obj: StaffProfile) -> str:
        return obj.user.get_full_name() or obj.user.username


class SimpleUserSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ("id", "username", "full_name")

    def get_full_name(self, obj: User) -> str:
        return obj.get_full_name() or obj.username


class DiningTableSerializer(serializers.ModelSerializer):
    assigned_waiters = SimpleUserSerializer(many=True, read_only=True)
    assigned_waiter_ids = serializers.PrimaryKeyRelatedField(
        many=True,
        queryset=User.objects.all(),
        source="assigned_waiters",
        write_only=True,
        required=False,
    )

    class Meta:
        model = DiningTable
        fields = (
            "id",
            "number",
            "seats",
            "location",
            "is_busy",
            "assigned_waiters",
            "assigned_waiter_ids",
        )


class MenuCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = MenuCategory
        fields = ("id", "name", "sort_order")


class MenuItemSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source="category.name", read_only=True)

    class Meta:
        model = MenuItem
        fields = (
            "id",
            "name",
            "category",
            "category_name",
            "description",
            "price",
            "is_active",
            "created_at",
            "updated_at",
        )


class OrderItemReadSerializer(serializers.ModelSerializer):
    menu_item_name = serializers.CharField(source="menu_item.name", read_only=True)
    line_total = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)

    class Meta:
        model = OrderItem
        fields = ("id", "menu_item", "menu_item_name", "quantity", "unit_price", "line_total", "note")


class OrderItemWriteSerializer(serializers.Serializer):
    menu_item = serializers.PrimaryKeyRelatedField(queryset=MenuItem.objects.filter(is_active=True))
    quantity = serializers.IntegerField(min_value=1)
    note = serializers.CharField(max_length=255, required=False, allow_blank=True)


class OrderSerializer(serializers.ModelSerializer):
    waiter = SimpleUserSerializer(read_only=True)
    table = DiningTableSerializer(read_only=True)
    table_id = serializers.PrimaryKeyRelatedField(
        queryset=DiningTable.objects.all(),
        source="table",
        write_only=True,
        required=True,
    )
    items = OrderItemReadSerializer(many=True, read_only=True)
    order_items = OrderItemWriteSerializer(many=True, write_only=True, required=True)

    class Meta:
        model = Order
        fields = (
            "id",
            "table",
            "table_id",
            "waiter",
            "status",
            "note",
            "total_amount",
            "paid_amount",
            "payment_method",
            "created_at",
            "updated_at",
            "closed_at",
            "items",
            "order_items",
        )
        read_only_fields = (
            "status",
            "total_amount",
            "paid_amount",
            "payment_method",
            "created_at",
            "updated_at",
            "closed_at",
        )

    def create(self, validated_data: dict) -> Order:
        order_items_data = validated_data.pop("order_items", [])
        request = self.context["request"]
        order = Order.objects.create(waiter=request.user, **validated_data)

        total_amount = Decimal("0.00")
        for item_data in order_items_data:
            menu_item = item_data["menu_item"]
            quantity = item_data["quantity"]
            unit_price = menu_item.price
            OrderItem.objects.create(
                order=order,
                menu_item=menu_item,
                quantity=quantity,
                unit_price=unit_price,
                note=item_data.get("note", ""),
            )
            total_amount += unit_price * quantity

        order.total_amount = total_amount
        order.save(update_fields=["total_amount", "updated_at"])
        return order


class OrderStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ("status",)

    def validate_status(self, value: str) -> str:
        allowed = {OrderStatus.REJECTED, OrderStatus.CANCELLED}
        if value not in allowed:
            raise serializers.ValidationError("Only rejected or cancelled statuses can be set here.")
        return value


class PaymentSerializer(serializers.ModelSerializer):
    amount = serializers.DecimalField(max_digits=12, decimal_places=2, write_only=True)

    class Meta:
        model = Order
        fields = ("id", "status", "payment_method", "paid_amount", "amount", "closed_at")
        read_only_fields = ("id", "status", "paid_amount", "closed_at")

    def validate(self, attrs: dict) -> dict:
        order = self.instance
        amount = attrs["amount"]
        if amount <= 0:
            raise serializers.ValidationError({"amount": "Amount must be greater than zero."})
        if order.status != OrderStatus.ACTIVE:
            raise serializers.ValidationError("Only active orders can be paid.")
        if amount != order.total_amount:
            raise serializers.ValidationError(
                {"amount": f"Payment must match total amount: {order.total_amount}"}
            )
        return attrs

    def update(self, instance: Order, validated_data: dict) -> Order:
        instance.mark_paid(
            payment_method=validated_data["payment_method"],
            amount=validated_data["amount"],
        )
        return instance
