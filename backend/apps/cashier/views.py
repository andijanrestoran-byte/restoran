from decimal import Decimal

from django.contrib.auth.decorators import login_required
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_GET, require_POST

from apps.restaurant.models import DiningTable, Order, OrderStatus


ACTIVE_ORDER_STATUSES = (OrderStatus.ACTIVE,)


def _order_total(order: Order) -> Decimal:
    return sum((item.line_total for item in order.items.all()), Decimal("0.00"))


def _table_summary(table: DiningTable) -> dict:
    active_orders = list(
        Order.objects.filter(table=table, status__in=ACTIVE_ORDER_STATUSES)
        .select_related("waiter", "table", "waiter__staff_profile")
        .prefetch_related("items__menu_item")
        .order_by("-created_at")
    )
    total_amount = sum((_order_total(order) for order in active_orders), Decimal("0.00"))
    total_items = sum(order.items.count() for order in active_orders)
    latest_order = active_orders[0] if active_orders else None
    return {
        "table": table,
        "active_orders": active_orders,
        "orders_count": len(active_orders),
        "items_count": total_items,
        "total_amount": total_amount,
        "latest_order": latest_order,
    }


def _base_context() -> dict:
    active_orders = Order.objects.filter(status__in=ACTIVE_ORDER_STATUSES)
    return {
        "active_orders_count": active_orders.count(),
        "new_orders_count": active_orders.count(),
        "accepted_orders_count": active_orders.count(),
        "rejected_orders_count": Order.objects.filter(status=OrderStatus.REJECTED).count(),
    }


@require_GET
@login_required
def dashboard(request):
    return render(
        request,
        "orders/dashboard.html",
        {
            **_base_context(),
            "tables_count": DiningTable.objects.count(),
        },
    )


@require_GET
@login_required
def orders_list(request):
    orders = (
        Order.objects.filter(status__in=ACTIVE_ORDER_STATUSES)
        .select_related("waiter", "table", "waiter__staff_profile")
        .prefetch_related("items__menu_item")
    )
    return render(request, "orders/orders_list.html", {**_base_context(), "orders": orders})


@require_GET
@login_required
def rejected_orders(request):
    rejected = (
        Order.objects.filter(status=OrderStatus.REJECTED)
        .select_related("waiter", "table", "waiter__staff_profile")
        .prefetch_related("items__menu_item")
    )
    return render(
        request,
        "orders/rejected_orders.html",
        {**_base_context(), "rejected_orders": rejected},
    )


@require_GET
@login_required
def tables_overview(request):
    tables = [_table_summary(table) for table in DiningTable.objects.all().order_by("number")]
    return render(request, "orders/tables_overview.html", {**_base_context(), "tables": tables})


@require_GET
@login_required
def order_detail(request, pk: int):
    order = get_object_or_404(
        Order.objects.select_related("waiter", "table", "waiter__staff_profile").prefetch_related(
            "items__menu_item",
            "items__menu_item__category",
        ),
        pk=pk,
    )
    return render(request, "orders/order_detail.html", {"order": order, **_base_context()})


@require_GET
@login_required
def table_bill(request, table_id: int):
    table = get_object_or_404(DiningTable, pk=table_id)
    summary = _table_summary(table)
    return render(request, "orders/table_bill.html", {**summary, **_base_context()})


@require_GET
@login_required
def table_print(request, table_id: int):
    table = get_object_or_404(DiningTable, pk=table_id)
    summary = _table_summary(table)
    summary["auto_print"] = True
    return render(request, "orders/table_print.html", summary)


@require_POST
@login_required
def close_table(request, table_id: int):
    table = get_object_or_404(DiningTable, pk=table_id)
    orders = Order.objects.filter(table=table, status__in=ACTIVE_ORDER_STATUSES)
    for order in orders:
        order.mark_paid(payment_method=request.POST.get("payment_method", "cash"), amount=order.total_amount)
    table.assigned_waiters.clear()
    table.is_busy = False
    table.save(update_fields=["is_busy"])
    return redirect("orders:table_bill", table_id=table_id)


@require_POST
@login_required
def accept_order(request, pk: int):
    return redirect("orders:order_detail", pk=pk)


@require_POST
@login_required
def reject_item(request, pk: int, item_id: int):
    order = get_object_or_404(Order, pk=pk)
    order.status = OrderStatus.REJECTED
    order.save(update_fields=["status", "updated_at"])
    return redirect("orders:order_detail", pk=pk)
