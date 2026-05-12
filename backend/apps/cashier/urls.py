from django.urls import path

from . import views


app_name = "orders"

urlpatterns = [
    path("", views.dashboard, name="dashboard"),
    path("orders/", views.orders_list, name="orders_list"),
    path("rejected/", views.rejected_orders, name="rejected_orders"),
    path("tables/", views.tables_overview, name="tables_overview"),
    path("orders/<int:pk>/", views.order_detail, name="order_detail"),
    path("orders/<int:pk>/accept/", views.accept_order, name="accept_order"),
    path("orders/<int:pk>/items/<int:item_id>/reject/", views.reject_item, name="reject_item"),
    path("tables/<int:table_id>/", views.table_bill, name="table_bill"),
    path("tables/<int:table_id>/print/", views.table_print, name="table_print"),
    path("tables/<int:table_id>/close/", views.close_table, name="close_table"),
]
