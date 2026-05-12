from decimal import Decimal

from django.conf import settings
from django.db import models
from django.utils import timezone


class StaffRole(models.TextChoices):
    WAITER = "waiter", "Waiter"
    DIRECTOR = "director", "Director"
    CASHIER = "cashier", "Cashier"


class StaffProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="staff_profile",
    )
    role = models.CharField(max_length=20, choices=StaffRole.choices)
    phone = models.CharField(max_length=32, blank=True)
    shift = models.CharField(max_length=64, blank=True)
    experience = models.CharField(max_length=64, blank=True)

    def __str__(self) -> str:
        return f"{self.user.get_full_name() or self.user.username} ({self.role})"


class DiningTable(models.Model):
    number = models.PositiveIntegerField(unique=True)
    seats = models.PositiveIntegerField(default=4)
    location = models.CharField(max_length=128)
    is_busy = models.BooleanField(default=False)
    assigned_waiters = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        blank=True,
        related_name="assigned_tables",
    )

    class Meta:
        ordering = ["number"]

    def __str__(self) -> str:
        return f"Table {self.number}"


class MenuCategory(models.Model):
    name = models.CharField(max_length=120, unique=True)
    sort_order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["sort_order", "name"]

    def __str__(self) -> str:
        return self.name


class MenuItem(models.Model):
    category = models.ForeignKey(
        MenuCategory,
        on_delete=models.CASCADE,
        related_name="items",
    )
    name = models.CharField(max_length=120)
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=12, decimal_places=2)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["category__sort_order", "name"]
        unique_together = ("category", "name")

    def __str__(self) -> str:
        return self.name


class OrderStatus(models.TextChoices):
    ACTIVE = "active", "Active"
    REJECTED = "rejected", "Rejected"
    PAID = "paid", "Paid"
    CANCELLED = "cancelled", "Cancelled"


class PaymentMethod(models.TextChoices):
    CASH = "cash", "Cash"
    CARD = "card", "Card"
    MIXED = "mixed", "Mixed"


class Order(models.Model):
    table = models.ForeignKey(
        DiningTable,
        on_delete=models.PROTECT,
        related_name="orders",
    )
    waiter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="orders",
    )
    status = models.CharField(max_length=20, choices=OrderStatus.choices, default=OrderStatus.ACTIVE)
    note = models.CharField(max_length=255, blank=True)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal("0.00"))
    paid_amount = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal("0.00"))
    payment_method = models.CharField(
        max_length=20,
        choices=PaymentMethod.choices,
        blank=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    closed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"Order #{self.pk} - Table {self.table.number}"

    def mark_paid(self, payment_method: str, amount: Decimal) -> None:
        self.status = OrderStatus.PAID
        self.payment_method = payment_method
        self.paid_amount = amount
        self.closed_at = timezone.now()
        self.save(
            update_fields=["status", "payment_method", "paid_amount", "closed_at", "updated_at"]
        )


class OrderItem(models.Model):
    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name="items",
    )
    menu_item = models.ForeignKey(
        MenuItem,
        on_delete=models.PROTECT,
        related_name="order_items",
    )
    quantity = models.PositiveIntegerField()
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    note = models.CharField(max_length=255, blank=True)

    class Meta:
        unique_together = ("order", "menu_item")

    @property
    def line_total(self) -> Decimal:
        return self.unit_price * self.quantity

    def __str__(self) -> str:
        return f"{self.menu_item.name} x {self.quantity}"
