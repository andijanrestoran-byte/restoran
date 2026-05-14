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


class V1StaffProfileSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = StaffProfile
        fields = ("role", "full_name", "phone", "shift", "experience")

    def get_full_name(self, obj):
        return obj.user.get_full_name() or obj.user.username


class V1SimpleUserSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ("id", "username", "full_name")

    def get_full_name(self, obj):
        return obj.get_full_name() or obj.username


class V1DiningTableSerializer(serializers.ModelSerializer):
    assigned_waiters = V1SimpleUserSerializer(many=True, read_only=True)
    status = serializers.SerializerMethodField()

    class Meta:
        model = DiningTable
        fields = (
            "id",
            "number",
            "seats",
            "location",
            "status",
            "is_busy",
            "assigned_waiters",
        )

    def get_status(self, obj):
        if obj.is_busy or obj.orders.filter(status=OrderStatus.ACTIVE).exists():
            return "busy"
        if obj.assigned_waiters.exists():
            return "assigned"
        return "free"


class V1MenuCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = MenuCategory
        fields = ("id", "name", "sort_order")


class V1MenuItemSerializer(serializers.ModelSerializer):
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


class V1OrderItemReadSerializer(serializers.ModelSerializer):
    menu_item_id = serializers.IntegerField(source="menu_item_id", read_only=True)
    menu_item_name = serializers.CharField(source="menu_item.name", read_only=True)

    class Meta:
        model = OrderItem
        fields = ("id", "menu_item_id", "menu_item_name", "quantity", "unit_price", "note")


class V1OrderItemWriteSerializer(serializers.Serializer):
    menu_item_id = serializers.PrimaryKeyRelatedField(
        queryset=MenuItem.objects.filter(is_active=True),
        source="menu_item",
    )
    quantity = serializers.IntegerField(min_value=1)
    note = serializers.CharField(max_length=255, required=False, allow_blank=True)


class V1OrderSerializer(serializers.ModelSerializer):
    waiter = V1SimpleUserSerializer(read_only=True)
    table = V1DiningTableSerializer(read_only=True)
    table_id = serializers.PrimaryKeyRelatedField(
        queryset=DiningTable.objects.all(),
        source="table",
        write_only=True,
        required=True,
    )
    items = V1OrderItemReadSerializer(many=True, read_only=True)
    order_items = V1OrderItemWriteSerializer(many=True, write_only=True, required=True)

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

    def create(self, validated_data):
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


class V1WaiterInfoSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    phone = serializers.SerializerMethodField()
    shift = serializers.SerializerMethodField()
    experience = serializers.SerializerMethodField()
    tables = serializers.SerializerMethodField()
    active_orders_count = serializers.SerializerMethodField()
    rejected_orders_count = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            "id",
            "username",
            "full_name",
            "phone",
            "shift",
            "experience",
            "tables",
            "active_orders_count",
            "rejected_orders_count",
        )

    def get_full_name(self, obj):
        return obj.get_full_name() or obj.username

    def get_phone(self, obj):
        return getattr(obj, "staff_profile", None).phone if hasattr(obj, "staff_profile") else ""

    def get_shift(self, obj):
        return getattr(obj, "staff_profile", None).shift if hasattr(obj, "staff_profile") else ""

    def get_experience(self, obj):
        return getattr(obj, "staff_profile", None).experience if hasattr(obj, "staff_profile") else ""

    def get_tables(self, obj):
        return list(obj.assigned_tables.values_list("id", flat=True))

    def get_active_orders_count(self, obj):
        return obj.orders.filter(status=OrderStatus.ACTIVE).count()

    def get_rejected_orders_count(self, obj):
        return obj.orders.filter(status=OrderStatus.REJECTED).count()


class V1WaiterCreateSerializer(serializers.ModelSerializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(write_only=True, required=True)
    full_name = serializers.CharField(required=True)
    phone = serializers.CharField(required=False, allow_blank=True)
    shift = serializers.CharField(required=False, allow_blank=True)
    experience = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ("id", "username", "password", "full_name", "phone", "shift", "experience")

    def create(self, validated_data):
        full_name = validated_data.pop("full_name", "")
        phone = validated_data.pop("phone", "")
        shift = validated_data.pop("shift", "")
        experience = validated_data.pop("experience", "")
        password = validated_data.pop("password")

        name_parts = full_name.split(" ", 2)
        user = User(
            username=validated_data["username"],
            first_name=name_parts[0] if len(name_parts) > 0 else "",
            last_name=name_parts[1] if len(name_parts) > 1 else "",
        )
        user.set_password(password)
        user.save()

        StaffProfile.objects.create(
            user=user,
            role="waiter",
            phone=phone,
            shift=shift,
            experience=experience,
        )
        return user

    def to_representation(self, instance):
        return V1WaiterInfoSerializer(instance).data


class V1WaiterUpdateSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(required=False)
    password = serializers.CharField(write_only=True, required=False)
    phone = serializers.CharField(required=False, allow_blank=True)
    shift = serializers.CharField(required=False, allow_blank=True)
    experience = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ("id", "full_name", "password", "phone", "shift", "experience")

    def update(self, instance, validated_data):
        full_name = validated_data.pop("full_name", None)
        password = validated_data.pop("password", None)

        if full_name:
            name_parts = full_name.split(" ", 2)
            instance.first_name = name_parts[0] if len(name_parts) > 0 else ""
            instance.last_name = name_parts[1] if len(name_parts) > 1 else ""

        if password:
            instance.set_password(password)

        instance.save()

        profile = getattr(instance, "staff_profile", None)
        if profile:
            for field in ("phone", "shift", "experience"):
                if field in validated_data:
                    setattr(profile, field, validated_data[field])
            profile.save()

        return instance

    def to_representation(self, instance):
        return V1WaiterInfoSerializer(instance).data
