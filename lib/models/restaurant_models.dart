part of 'package:andijan_flutter/app.dart';

enum UserRole { waiter, director, cashier }

enum WaiterSection { orders, profile }

enum DirectorSection { dashboard, waiters, menu, reports, profile }

enum OrderStep { tables, menu }

enum OrderStatus { active, rejected, paid, cancelled }

class WaiterProfile {
  const WaiterProfile({
    required this.name,
    required this.position,
    required this.shift,
    required this.phone,
    required this.experience,
  });

  final String name;
  final String position;
  final String shift;
  final String phone;
  final String experience;
}

class TableInfo {
  const TableInfo({
    required this.id,
    required this.seats,
    required this.location,
    this.number,
    this.status = 'free',
    this.assignedWaiters = const [],
    this.isBusy = false,
  });

  final int id;
  final int? number;
  final int seats;
  final String location;
  final String status;
  final List<Map<String, dynamic>> assignedWaiters;
  final bool isBusy;

  bool get isFree => status == 'free' && assignedWaiters.isEmpty && !isBusy;
  bool get isAssigned => assignedWaiters.isNotEmpty || status == 'assigned';
}

class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final int sortOrder;
}

class MenuItemData {
  const MenuItemData({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
    this.categoryId,
    this.isActive = true,
    this.remainingToday,
    this.isAvailable = true,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String category;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
  final int? categoryId;
  final bool isActive;
  final int? remainingToday;
  final bool isAvailable;
  final String? imageUrl;

  MenuItemData copyWith({
    String? name,
    String? category,
    String? description,
    int? price,
    IconData? icon,
    Color? color,
    int? categoryId,
  }) {
    return MenuItemData(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive,
      remainingToday: remainingToday,
      isAvailable: isAvailable,
      imageUrl: imageUrl,
    );
  }
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.waiterLogin,
    required this.tableId,
    required this.itemName,
    required this.quantity,
    required this.note,
    required this.icon,
    required this.color,
    required this.status,
    this.tableNumber,
  });

  final int id;
  final String waiterLogin;
  final int tableId;
  final int? tableNumber;
  final String itemName;
  final int quantity;
  final String note;
  final IconData icon;
  final Color color;
  final OrderStatus status;

  OrderRecord copyWith({OrderStatus? status}) {
    return OrderRecord(
      id: id,
      waiterLogin: waiterLogin,
      tableId: tableId,
      tableNumber: tableNumber,
      itemName: itemName,
      quantity: quantity,
      note: note,
      icon: icon,
      color: color,
      status: status ?? this.status,
    );
  }
}

class WaiterInfo {
  const WaiterInfo({
    required this.id,
    required this.username,
    required this.fullName,
    this.phone = '',
    this.shift = '',
    this.experience = '',
    this.tables = const [],
    this.activeOrdersCount = 0,
    this.rejectedOrdersCount = 0,
  });

  final int id;
  final String username;
  final String fullName;
  final String phone;
  final String shift;
  final String experience;
  final List<int> tables;
  final int activeOrdersCount;
  final int rejectedOrdersCount;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalTables,
    required this.freeTables,
    required this.busyTables,
    required this.assignedTables,
    required this.activeOrders,
    required this.rejectedOrders,
    required this.paidTodayOrders,
    required this.cashToday,
    required this.cardToday,
    required this.totalToday,
    required this.activeWaiters,
  });

  final int totalTables;
  final int freeTables;
  final int busyTables;
  final int assignedTables;
  final int activeOrders;
  final int rejectedOrders;
  final int paidTodayOrders;
  final int cashToday;
  final int cardToday;
  final int totalToday;
  final int activeWaiters;
}

class RevenueReport {
  const RevenueReport({
    required this.period,
    required this.cashTotal,
    required this.cardTotal,
    required this.grandTotal,
    required this.dailyBreakdown,
  });

  final String period;
  final int cashTotal;
  final int cardTotal;
  final int grandTotal;
  final List<DailyBreakdown> dailyBreakdown;
}

class DailyBreakdown {
  const DailyBreakdown({
    required this.date,
    required this.cash,
    required this.card,
    required this.total,
  });

  final String date;
  final int cash;
  final int card;
  final int total;
}

class WaiterReportItem {
  const WaiterReportItem({
    required this.id,
    required this.fullName,
    required this.soldOrders,
    required this.rejectedOrders,
    required this.cancelledOrders,
    required this.revenue,
  });

  final int id;
  final String fullName;
  final int soldOrders;
  final int rejectedOrders;
  final int cancelledOrders;
  final int revenue;
}

class ProductSales {
  const ProductSales({
    required this.productName,
    required this.quantity,
    required this.revenue,
  });

  final String productName;
  final int quantity;
  final int revenue;
}

// ---- Helper functions ----

IconData _iconForCategory(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('milliy')) return Icons.rice_bowl;
  if (normalized.contains('turk')) return Icons.kebab_dining;
  if (normalized.contains('fast')) return Icons.fastfood;
  if (normalized.contains('salat')) return Icons.eco;
  if (normalized.contains('ichimlik')) return Icons.emoji_food_beverage;
  if (normalized.contains('desert')) return Icons.cake;
  return Icons.restaurant;
}

Color _colorForCategory(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('milliy')) return const Color(0xFFF2D7B5);
  if (normalized.contains('turk')) return const Color(0xFFF3D0C7);
  if (normalized.contains('fast')) return const Color(0xFFF9D6A2);
  if (normalized.contains('salat')) return const Color(0xFFDFF0D8);
  if (normalized.contains('ichimlik')) return const Color(0xFFD7EBF3);
  if (normalized.contains('desert')) return const Color(0xFFF5DDED);
  return const Color(0xFFEFE3D6);
}

OrderStatus _orderStatusFromApi(String? status) {
  switch (status) {
    case 'rejected':
      return OrderStatus.rejected;
    case 'paid':
    case 'completed':
      return OrderStatus.paid;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.active;
  }
}
