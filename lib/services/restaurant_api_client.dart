part of 'package:andijan_flutter/app.dart';

class RestaurantApiException implements Exception {
  const RestaurantApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiSession {
  const ApiSession({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.profile,
  });

  final String accessToken;
  final String refreshToken;
  final UserRole role;
  final WaiterProfile profile;
}

class RestaurantApiClient {
  RestaurantApiClient({this.baseUrl = backendApiBaseUrl}) {
    _client.connectionTimeout = const Duration(seconds: 30);
  }

  final String baseUrl;
  final HttpClient _client = HttpClient();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _request(
    String method,
    String path, {
    String? token,
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    var uri = _uri(path);
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    debugPrint('🌐 $method $uri');
    if (body != null) debugPrint('📦 REQ: $body');

    final request = await _client.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) {
      final jsonBody = jsonEncode(body);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(jsonBody));
    }

    final response = await request.close();
    final responseText = await response.transform(utf8.decoder).join();
    final data = responseText.isEmpty ? null : jsonDecode(responseText);
    debugPrint('📥 RES [${response.statusCode}]: $data');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Backend xatosi: ${response.statusCode}';
      if (data is Map) {
        if (data['detail'] != null) {
          errorMessage = data['detail'].toString();
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        } else if (data.isNotEmpty) {
          errorMessage = data.toString();
        }
      }
      throw RestaurantApiException(errorMessage);
    }
    return data;
  }

  // ---- Auth ----

  Future<ApiSession> login(String username, String password) async {
    debugPrint('🔑 LOGIN: $username');
    final auth =
        await _request(
              'POST',
              '/v1/auth/login',
              body: {'username': username.trim(), 'password': password.trim()},
            )
            as Map<String, dynamic>;
    debugPrint('🔑 LOGIN response keys: ${auth.keys}');

    final access = auth['access']?.toString();
    final refresh = auth['refresh']?.toString();
    if (access == null || refresh == null) {
      throw const RestaurantApiException('Backend token qaytarmadi.');
    }

    final me = await fetchMe(access);
    return ApiSession(
      accessToken: access,
      refreshToken: refresh,
      role: me['role'],
      profile: me['profile'],
    );
  }

  Future<Map<String, dynamic>> fetchMe(String token) async {
    final me =
        await _request('GET', '/v1/auth/me', token: token)
            as Map<String, dynamic>;
    final role = _roleFromApi(me['role']?.toString());
    return {
      'role': role,
      'profile': WaiterProfile(
        name: me['full_name']?.toString() ?? '',
        position: role == UserRole.director
            ? 'Direktor'
            : (role == UserRole.cashier ? 'Kassir' : 'Ofitsant'),
        shift: me['shift']?.toString() ?? '',
        phone: me['phone']?.toString() ?? '',
        experience: me['experience']?.toString() ?? '',
      ),
    };
  }

  // ---- Tables ----

  Future<List<TableInfo>> fetchTables(String token) async {
    final data = await _request('GET', '/v1/waiter/all-tables', token: token);
    final rows = _results(data);
    return rows.map((row) {
      final item = row as Map<String, dynamic>;
      final rawStatus = item['status']?.toString();
      final isBusy = item['is_busy'] as bool?;
      final status = rawStatus ?? (isBusy == true ? 'busy' : 'free');
      return TableInfo(
        id: item['id'] as int,
        number: item['number'] as int?,
        seats: item['seats'] as int? ?? 4,
        location: item['location']?.toString() ?? '',
        status: status,
        isBusy: isBusy ?? (status != 'free'),
        assignedWaiters: List<Map<String, dynamic>>.from(
          item['assigned_waiters'] ?? [],
        ),
      );
    }).toList();
  }

  Future<void> joinTable(String token, int tableId) async {
    await _request('POST', '/v1/tables/$tableId/join', token: token);
  }

  // ---- Categories ----

  Future<List<MenuCategory>> fetchCategories(String token) async {
    final data = await _request('GET', '/v1/menu/categories', token: token);
    final rows = _results(data);
    return rows.map((row) {
      final item = row as Map<String, dynamic>;
      return MenuCategory(
        id: item['id'] as int,
        name: item['name']?.toString() ?? '',
        sortOrder: item['sort_order'] as int? ?? 0,
      );
    }).toList();
  }

  Future<MenuCategory> createCategory(
    String token,
    String name,
    int sortOrder,
  ) async {
    final data =
        await _request(
              'POST',
              '/v1/menu/categories',
              token: token,
              body: {'name': name, 'sort_order': sortOrder},
            )
            as Map<String, dynamic>;
    return MenuCategory(
      id: data['id'] as int,
      name: data['name']?.toString() ?? '',
      sortOrder: data['sort_order'] as int? ?? 0,
    );
  }

  Future<void> updateCategory(
    String token,
    int id,
    String name,
    int sortOrder,
  ) async {
    await _request(
      'PATCH',
      '/v1/menu/categories/$id',
      token: token,
      body: {'name': name, 'sort_order': sortOrder},
    );
  }

  Future<void> deleteCategory(String token, int id) async {
    await _request('DELETE', '/v1/menu/categories/$id', token: token);
  }

  // ---- Menu Items ----

  Future<List<MenuItemData>> fetchMenuItems(String token) async {
    final data = await _request('GET', '/v1/menu/items', token: token);
    final rows = _results(data);
    return rows.map((row) {
      final item = row as Map<String, dynamic>;
      final categoryName = item['category_name']?.toString() ?? 'Boshqa';
      return MenuItemData(
        id: item['id'] as int,
        name: item['name']?.toString() ?? '',
        category: categoryName,
        categoryId: (item['category_id'] ?? item['category']) as int?,
        description: item['description']?.toString() ?? '',
        price: double.parse((item['price'] ?? 0).toString()).round(),
        icon: _iconForCategory(categoryName),
        color: _colorForCategory(categoryName),
        isActive: item['is_active'] as bool? ?? true,
        remainingToday: item['remaining_today'] as int?,
        isAvailable: item['is_available'] as bool? ?? true,
        imageUrl: item['image_url']?.toString(),
      );
    }).toList();
  }

  Future<void> createMenuItem(String token, Map<String, dynamic> data) async {
    await _request('POST', '/v1/menu/items', token: token, body: data);
  }

  Future<void> updateMenuItem(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    await _request('PATCH', '/v1/menu/items/$id', token: token, body: data);
  }

  Future<void> deleteMenuItem(String token, int id) async {
    await _request('DELETE', '/v1/menu/items/$id', token: token);
  }

  // ---- Orders ----

  Future<List<OrderRecord>> fetchOrders(
    String token,
    List<MenuItemData> menuItems,
  ) async {
    final data = await _request('GET', '/v1/orders', token: token);
    final rows = _results(data);
    final menuById = {for (final item in menuItems) item.id: item};
    final records = <OrderRecord>[];

    for (final row in rows) {
      final order = row as Map<String, dynamic>;
      final orderId = order['id'] as int;
      final table = order['table'] as Map<String, dynamic>?;
      final waiter = order['waiter'] as Map<String, dynamic>?;
      final items = order['items'] as List<dynamic>? ?? [];

      for (final rawItem in items) {
        final item = rawItem as Map<String, dynamic>;
        final menuId = (item['menu_item_id'] ?? item['menu_item']) as int?;
        final menuItem = menuById[menuId];

        records.add(
          OrderRecord(
            id: orderId,
            waiterLogin: waiter?['username']?.toString() ?? '',
            tableId: table?['id'] as int? ?? 0,
            tableNumber: table?['number'] as int?,
            billNumber: order['bill_number'] as int?,
            itemName:
                item['menu_item_name']?.toString() ?? menuItem?.name ?? 'Taom',
            quantity: item['quantity'] as int? ?? 1,
            note: item['note']?.toString() ?? '',
            icon: menuItem?.icon ?? Icons.restaurant,
            color: menuItem?.color ?? const Color(0xFFEFE3D6),
            status: _orderStatusFromApi(order['status']?.toString()),
          ),
        );
      }
    }
    return records;
  }

  Future<int> createOrder({
    required String token,
    required int tableId,
    required List<Map<String, dynamic>> items,
    int? billNumber,
    String note = '',
  }) async {
    final body = <String, dynamic>{
      'table_id': tableId,
      'note': note,
      'order_items': items,
    };
    if (billNumber != null) body['bill_number'] = billNumber;
    final data =
        await _request('POST', '/v1/orders', token: token, body: body)
            as Map<String, dynamic>;
    return (data['id'] as int? ?? 0);
  }

  Future<void> rejectOrder(
    String token,
    int orderId, {
    String reason = 'Rad etildi',
  }) async {
    await _request(
      'POST',
      '/v1/orders/$orderId/reject',
      token: token,
      body: {'reason': reason},
    );
  }

  Future<void> cancelOrder(
    String token,
    int orderId, {
    String reason = 'Bekor qilindi',
  }) async {
    await _request(
      'POST',
      '/v1/orders/$orderId/cancel',
      token: token,
      body: {'reason': reason},
    );
  }

  // ---- Director ----

  Future<DashboardSummary> fetchDashboardSummary(String token) async {
    final data =
        await _request('GET', '/v1/dashboard/summary', token: token)
            as Map<String, dynamic>;
    final tables = data['tables'] as Map<String, dynamic>? ?? {};
    final orders = data['orders'] as Map<String, dynamic>? ?? {};
    final payments = data['payments'] as Map<String, dynamic>? ?? {};
    final staff = data['staff'] as Map<String, dynamic>? ?? {};

    return DashboardSummary(
      totalTables: (tables['total'] ?? 0) as int,
      freeTables: (tables['free'] ?? 0) as int,
      busyTables: (tables['busy'] ?? 0) as int,
      assignedTables: (tables['assigned'] ?? 0) as int,
      activeOrders: (orders['active'] ?? 0) as int,
      rejectedOrders: (orders['rejected'] ?? 0) as int,
      paidTodayOrders: (orders['paid_today'] ?? 0) as int,
      cashToday: _parseAmount((payments['cash_today'] ?? payments['cash'])),
      cardToday: _parseAmount((payments['card_today'] ?? payments['card'])),
      totalToday: _parseAmount((payments['total_today'] ?? payments['total'])),
      activeWaiters: (staff['active_waiters'] ?? staff['waiters'] ?? 0) as int,
    );
  }

  static int _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.round();
    return double.tryParse(value.toString())?.round() ?? 0;
  }

  Future<List<WaiterInfo>> fetchWaiters(String token) async {
    final data = await _request('GET', '/v1/director/waiters', token: token);
    final rows = data as List<dynamic>;
    return rows.map((row) {
      final item = row as Map<String, dynamic>;
      return WaiterInfo(
        id: item['id'] as int,
        username: item['username']?.toString() ?? '',
        fullName: item['full_name']?.toString() ?? '',
        phone: item['phone']?.toString() ?? '',
        shift: item['shift']?.toString() ?? '',
        experience: item['experience']?.toString() ?? '',
        tables: List<int>.from(item['tables'] ?? []),
        activeOrdersCount: item['active_orders_count'] as int? ?? 0,
        rejectedOrdersCount: item['rejected_orders_count'] as int? ?? 0,
      );
    }).toList();
  }

  Future<void> createWaiter(String token, Map<String, dynamic> data) async {
    await _request('POST', '/v1/director/waiters', token: token, body: data);
  }

  Future<void> updateWaiter(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    await _request(
      'PATCH',
      '/v1/director/waiters/$id',
      token: token,
      body: data,
    );
  }

  Future<void> deleteWaiter(String token, int id) async {
    await _request('DELETE', '/v1/director/waiters/$id', token: token);
  }

  Future<RevenueReport> fetchRevenueReport(
    String token, {
    String period = 'daily',
  }) async {
    final data =
        await _request(
              'GET',
              '/v1/director/reports/revenue',
              token: token,
              queryParams: {'period': period},
            )
            as Map<String, dynamic>;

    final totals = data['totals'] as Map<String, dynamic>;
    final breakdown = data['daily_breakdown'] as List<dynamic>;

    return RevenueReport(
      period: data['period']?.toString() ?? period,
      cashTotal: (double.parse(totals['cash'].toString())).round(),
      cardTotal: (double.parse(totals['card'].toString())).round(),
      grandTotal: (double.parse(totals['total'].toString())).round(),
      dailyBreakdown: breakdown.map((b) {
        final item = b as Map<String, dynamic>;
        return DailyBreakdown(
          date: item['date']?.toString() ?? '',
          cash: (double.parse(item['cash'].toString())).round(),
          card: (double.parse(item['card'].toString())).round(),
          total: (double.parse(item['total'].toString())).round(),
        );
      }).toList(),
    );
  }

  Future<List<WaiterReportItem>> fetchWaitersReport(
    String token, {
    String period = 'daily',
  }) async {
    final data =
        await _request(
              'GET',
              '/v1/director/reports/waiters',
              token: token,
              queryParams: {'period': period},
            )
            as Map<String, dynamic>;

    final waiters = data['waiters'] as List<dynamic>;
    return waiters.map((w) {
      final item = w as Map<String, dynamic>;
      return WaiterReportItem(
        id: item['id'] as int,
        fullName: item['full_name']?.toString() ?? '',
        soldOrders: item['sold_orders'] as int? ?? 0,
        rejectedOrders: item['rejected_orders'] as int? ?? 0,
        cancelledOrders: item['cancelled_orders'] as int? ?? 0,
        revenue: (double.parse(item['revenue'].toString())).round(),
      );
    }).toList();
  }

  // ---- Payments & Cashier ----

  Future<List<Map<String, dynamic>>> fetchPayments(String token) async {
    final data = await _request('GET', '/v1/cashier/payments', token: token);
    return List<Map<String, dynamic>>.from(_results(data));
  }

  Future<void> acceptOrderCashier(String token, int orderId) async {
    await _request('POST', '/v1/cashier/orders/$orderId/accept', token: token);
  }

  Future<Map<String, dynamic>> fetchTableBill(String token, int tableId) async {
    return await _request(
          'GET',
          '/v1/cashier/tables/$tableId/bill',
          token: token,
        )
        as Map<String, dynamic>;
  }

  Future<void> closeTable(
    String token,
    int tableId,
    String method,
    double amount,
  ) async {
    await _request(
      'POST',
      '/v1/cashier/tables/$tableId/close',
      token: token,
      body: {'payment_method': method, 'amount': amount},
    );
  }

  // ---- Helpers ----

  static UserRole _roleFromApi(String? role) {
    if (role == 'director') return UserRole.director;
    if (role == 'cashier') return UserRole.cashier;
    return UserRole.waiter;
  }

  static OrderStatus _orderStatusFromApi(String? status) {
    switch (status) {
      case 'paid':
      case 'completed':
        return OrderStatus.paid;
      case 'rejected':
      case 'partially_rejected':
        return OrderStatus.rejected;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.active;
    }
  }

  static List<dynamic> _results(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['results'] is List) {
      return data['results'] as List<dynamic>;
    }
    return const <dynamic>[];
  }

  static IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('kabob') || n.contains('go’sht')) return Icons.restaurant;
    if (n.contains('ichimlik') || n.contains('sharbat'))
      return Icons.local_drink;
    if (n.contains('shirinlik')) return Icons.cake;
    if (n.contains('salat')) return Icons.eco;
    return Icons.flatware;
  }

  static Color _colorForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('kabob')) return const Color(0xFFFDE8E4);
    if (n.contains('ichimlik')) return const Color(0xFFE3F2FD);
    if (n.contains('salat')) return const Color(0xFFE8F5E9);
    return const Color(0xFFEFE3D6);
  }
}
