from django.contrib import admin

from .models import DiningTable, MenuCategory, MenuItem, Order, OrderItem, StaffProfile


@admin.register(StaffProfile)
class StaffProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "role", "phone", "shift")
    search_fields = ("user__username", "user__first_name", "user__last_name", "phone")


@admin.register(DiningTable)
class DiningTableAdmin(admin.ModelAdmin):
    list_display = ("number", "seats", "location", "is_busy")
    list_filter = ("is_busy",)
    search_fields = ("number", "location")
    filter_horizontal = ("assigned_waiters",)


@admin.register(MenuCategory)
class MenuCategoryAdmin(admin.ModelAdmin):
    list_display = ("name", "sort_order")
    ordering = ("sort_order", "name")


@admin.register(MenuItem)
class MenuItemAdmin(admin.ModelAdmin):
    list_display = ("name", "category", "price", "is_active")
    list_filter = ("category", "is_active")
    search_fields = ("name", "description")


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ("id", "table", "waiter", "status", "total_amount", "payment_method", "created_at")
    list_filter = ("status", "payment_method", "created_at")
    search_fields = ("id", "table__number", "waiter__username")
    inlines = [OrderItemInline]
