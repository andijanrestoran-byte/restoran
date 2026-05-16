part of 'package:andijan_flutter/app.dart';

class RestaurantApiException implements Exception {
  const RestaurantApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  final String message;

  /// Backend qaytargan HTTP status (mavjud bo'lsa). 401 — login/parol xato.
  final int? statusCode;

  /// Serverga umuman ulanib bo'lmadi (internet/timeout/SSL) — bu holatda
  /// muammo login/parolda emas, balki ulanishda.
  final bool isNetworkError;

  /// 401 — autentifikatsiya rad etildi (login yoki parol haqiqatan xato).
  bool get isAuthError => statusCode == 401;

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

  static final _DemoStore _demoStore = _DemoStore();

  /// Testlar uchun: offline demo holatini boshlang'ich qiymatga qaytaradi.
  /// Demo store `static` bo'lgani uchun testlar orasida tozalash kerak.
  @visibleForTesting
  static void resetDemoStore() => _demoStore._reset();

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
    try {
      var uri = _uri(path);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      debugPrint('API $method $uri');
      if (body != null) debugPrint('REQ $body');

      final request = await _client.openUrl(method, uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) {
        final jsonBody = jsonEncode(body);
        final bodyBytes = utf8.encode(jsonBody);
        request.headers.contentType = ContentType.json;
        // MUHIM: contentLength o'rnatilmasa, HttpClient tanani "chunked"
        // Transfer-Encoding bilan yuboradi. Railway/Django bu chunked
        // tanani o'qimaydi -> server bo'sh ma'lumot ko'radi -> 401
        // "Login yoki parol noto'g'ri". Content-Length majburiy.
        request.contentLength = bodyBytes.length;
        request.add(bodyBytes);
      }

      // Railway "cold start" sekin bo'lishi mumkin — umumiy javob uchun
      // ham timeout qo'yamiz, aks holda ilova osilib qoladi.
      final response = await request.close().timeout(
        const Duration(seconds: 45),
      );
      final responseText = await response.transform(utf8.decoder).join();
      final data = responseText.isEmpty ? null : jsonDecode(responseText);
      debugPrint('RES [${response.statusCode}] $data');

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
        throw RestaurantApiException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
      return data;
    } on SocketException {
      throw const RestaurantApiException(
        "Backendga ulanib bo'lmadi. Internet yoki server manzilini tekshiring.",
        isNetworkError: true,
      );
    } on TimeoutException {
      throw const RestaurantApiException(
        "Server javob bermadi (timeout). Biroz kutib, qayta urinib ko'ring.",
        isNetworkError: true,
      );
    } on HandshakeException {
      throw const RestaurantApiException(
        "Xavfsiz ulanishda xato yuz berdi. Server SSL sozlamasini tekshiring.",
        isNetworkError: true,
      );
    } on FormatException {
      throw const RestaurantApiException(
        "Backend noto'g'ri formatdagi javob qaytardi.",
      );
    } on HttpException catch (e) {
      throw RestaurantApiException(
        "HTTP xatosi: ${e.message}",
        isNetworkError: true,
      );
    }
  }

  Future<ApiSession> login(String username, String password) async {
    final session = await _authenticate(username, password);
    return _ensureMobileRole(session);
  }

  // Mobil ilova faqat direktor va ofitsant uchun. Kassir veb-platformada
  // ishlaydi, shu sababli mobil login'da bloklanadi.
  ApiSession _ensureMobileRole(ApiSession session) {
    if (session.role == UserRole.cashier) {
      throw const RestaurantApiException(
        "Kassir veb-platformada ishlaydi. Mobil ilova faqat direktor va ofitsant uchun.",
      );
    }
    return session;
  }

  Future<ApiSession> _authenticate(String username, String password) async {
    // Username trim + lowercase: mobil klaviatura bosh harf qo'shsa ham
    // serverga to'g'ri yetib boradi (server loginlari kichik harfda).
    // Parolni trim QILMAYMIZ — serverdagi parol probel bilan bo'lishi
    // mumkin va trim "to'g'ri parol rad etildi" muammosini keltiradi.
    final normalizedUsername = username.trim().toLowerCase();
    debugPrint('LOGIN $normalizedUsername');

    try {
      final auth =
          await _request(
                'POST',
                '/v1/auth/login',
                body: {
                  'username': normalizedUsername,
                  'password': password,
                },
              )
              as Map<String, dynamic>;

      final access = auth['access']?.toString();
      final refresh = auth['refresh']?.toString();
      if (access == null || refresh == null) {
        throw const RestaurantApiException('Backend token qaytarmadi.');
      }

      final me = await fetchMe(access);
      return ApiSession(
        accessToken: access,
        refreshToken: refresh,
        role: me['role'] as UserRole,
        profile: me['profile'] as WaiterProfile,
      );
    } on RestaurantApiException catch (error) {
      // 401 — server login/parolni haqiqatan rad etdi. Demo'ga o'tib
      // muammoni yashirmaymiz; serverning aniq xabarini ko'rsatamiz.
      if (error.isAuthError) {
        throw RestaurantApiException(
          error.message.isEmpty
              ? "Login yoki parol noto'g'ri."
              : error.message,
          statusCode: 401,
        );
      }

      // Boshqa xatolar (internet/timeout/5xx) — bu login/parol muammosi
      // EMAS. Faqat shunday holatda offline demo rejimga o'tamiz.
      final session = _demoStore.tryLogin(normalizedUsername, password);
      if (session != null) {
        debugPrint('DEMO LOGIN $normalizedUsername');
        return session;
      }

      // Demo ham yo'q — ulanish xatosini O'ZGARTIRMASDAN ko'rsatamiz
      // ("Login yoki parol noto'g'ri" deb noto'g'ri aytmaymiz).
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchMe(String token) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchMe(token);
    }

    final me =
        await _request('GET', '/v1/auth/me', token: token)
            as Map<String, dynamic>;
    final role = _roleFromApi(me['role']?.toString());
    return {
      'role': role,
      'profile': WaiterProfile(
        name: me['full_name']?.toString() ?? '',
        position: role == UserRole.director ? 'Direktor' : 'Ofitsant',
        shift: me['shift']?.toString() ?? '',
        phone: me['phone']?.toString() ?? '',
        experience: me['experience']?.toString() ?? '',
      ),
    };
  }

  Future<List<TableInfo>> fetchTables(
    String token, {
    bool director = false,
  }) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchTables();
    }

    // Direktorga /v1/waiter/all-tables 403 beradi (faqat ofitsant uchun).
    // Direktor /v1/tables dan oladi; ofitsant /v1/waiter/all-tables dan
    // (u yerda assigned_waiters to'ldirilgan bo'ladi).
    final path = director ? '/v1/tables' : '/v1/waiter/all-tables';
    final data = await _request('GET', path, token: token);
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
    if (_isDemoToken(token)) {
      _demoStore.joinTable(token, tableId);
      return;
    }
    await _request('POST', '/v1/tables/$tableId/join', token: token);
  }

  Future<List<MenuCategory>> fetchCategories(String token) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchCategories();
    }

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
    if (_isDemoToken(token)) {
      return _demoStore.createCategory(name, sortOrder);
    }

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
    if (_isDemoToken(token)) {
      _demoStore.updateCategory(id, name, sortOrder);
      return;
    }

    await _request(
      'PATCH',
      '/v1/menu/categories/$id',
      token: token,
      body: {'name': name, 'sort_order': sortOrder},
    );
  }

  Future<void> deleteCategory(String token, int id) async {
    if (_isDemoToken(token)) {
      _demoStore.deleteCategory(id);
      return;
    }
    await _request('DELETE', '/v1/menu/categories/$id', token: token);
  }

  Future<List<MenuItemData>> fetchMenuItems(String token) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchMenuItems();
    }

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
    if (_isDemoToken(token)) {
      _demoStore.createMenuItem(data);
      return;
    }
    await _request('POST', '/v1/menu/items', token: token, body: data);
  }

  Future<void> updateMenuItem(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    if (_isDemoToken(token)) {
      _demoStore.updateMenuItem(id, data);
      return;
    }
    await _request('PATCH', '/v1/menu/items/$id', token: token, body: data);
  }

  Future<void> deleteMenuItem(String token, int id) async {
    if (_isDemoToken(token)) {
      _demoStore.deleteMenuItem(id);
      return;
    }
    await _request('DELETE', '/v1/menu/items/$id', token: token);
  }

  Future<List<OrderRecord>> fetchOrders(
    String token,
    List<MenuItemData> menuItems,
  ) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchOrders(menuItems);
    }

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
    if (_isDemoToken(token)) {
      return _demoStore.createOrder(
        token: token,
        tableId: tableId,
        items: items,
        billNumber: billNumber,
        note: note,
      );
    }

    // Server (kassa) CreateOrderSerializer: table_id, bill_number, note,
    // items[]. Maydon nomi 'items' (avval xato 'order_items' edi).
    final body = <String, dynamic>{
      'table_id': tableId,
      'bill_number': billNumber ?? 1,
      'note': note,
      'items': items,
    };
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
    if (_isDemoToken(token)) {
      _demoStore.rejectOrder(orderId);
      return;
    }

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
    if (_isDemoToken(token)) {
      _demoStore.cancelOrder(orderId);
      return;
    }

    await _request(
      'POST',
      '/v1/orders/$orderId/cancel',
      token: token,
      body: {'reason': reason},
    );
  }

  Future<DashboardSummary> fetchDashboardSummary(String token) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchDashboardSummary();
    }

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
      cashToday: _parseAmount(payments['cash_today'] ?? payments['cash']),
      cardToday: _parseAmount(payments['card_today'] ?? payments['card']),
      totalToday: _parseAmount(payments['total_today'] ?? payments['total']),
      activeWaiters: (staff['active_waiters'] ?? staff['waiters'] ?? 0) as int,
    );
  }

  Future<List<WaiterInfo>> fetchWaiters(String token) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchWaiters();
    }

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
    if (_isDemoToken(token)) {
      _demoStore.createWaiter(data);
      return;
    }
    await _request('POST', '/v1/director/waiters', token: token, body: data);
  }

  Future<void> updateWaiter(
    String token,
    int id,
    Map<String, dynamic> data,
  ) async {
    if (_isDemoToken(token)) {
      _demoStore.updateWaiter(id, data);
      return;
    }

    await _request(
      'PATCH',
      '/v1/director/waiters/$id',
      token: token,
      body: data,
    );
  }

  Future<void> deleteWaiter(String token, int id) async {
    if (_isDemoToken(token)) {
      _demoStore.deleteWaiter(id);
      return;
    }
    await _request('DELETE', '/v1/director/waiters/$id', token: token);
  }

  Future<RevenueReport> fetchRevenueReport(
    String token, {
    String period = 'daily',
  }) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchRevenueReport(period: period);
    }

    final data =
        await _request(
              'GET',
              '/v1/director/reports/revenue',
              token: token,
              queryParams: {'period': period},
            )
            as Map<String, dynamic>;

    final totals = data['totals'] as Map<String, dynamic>? ?? {};
    final breakdown = data['daily_breakdown'] as List<dynamic>? ?? [];

    return RevenueReport(
      period: data['period']?.toString() ?? period,
      cashTotal: _parseAmount(totals['cash']),
      cardTotal: _parseAmount(totals['card']),
      mixedTotal: _parseAmount(totals['mixed']),
      grandTotal: _parseAmount(totals['total']),
      dailyBreakdown: breakdown.map((b) {
        final item = b as Map<String, dynamic>;
        return DailyBreakdown(
          date: item['date']?.toString() ?? '',
          cash: _parseAmount(item['cash']),
          card: _parseAmount(item['card']),
          mixed: _parseAmount(item['mixed']),
          total: _parseAmount(item['total']),
        );
      }).toList(),
    );
  }

  Future<List<WaiterReportItem>> fetchWaitersReport(
    String token, {
    String period = 'daily',
  }) async {
    if (_isDemoToken(token)) {
      return _demoStore.fetchWaitersReport(period: period);
    }

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
        revenue: _parseAmount(item['revenue']),
      );
    }).toList();
  }


  static UserRole _roleFromApi(String? role) {
    if (role == 'director') return UserRole.director;
    if (role == 'cashier') return UserRole.cashier;
    return UserRole.waiter;
  }

  static int _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.round();
    return double.tryParse(value.toString())?.round() ?? 0;
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
    if (n.contains('kabob') || n.contains("go'sht")) return Icons.restaurant;
    if (n.contains('ichimlik') || n.contains('sharbat')) {
      return Icons.local_drink;
    }
    if (n.contains('shirinlik')) return Icons.cake;
    if (n.contains('salat')) return Icons.eco;
    if (n.contains('milliy')) return Icons.rice_bowl;
    return Icons.flatware;
  }

  static Color _colorForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('kabob')) return const Color(0xFFFDE8E4);
    if (n.contains('ichimlik')) return const Color(0xFFE3F2FD);
    if (n.contains('salat')) return const Color(0xFFE8F5E9);
    if (n.contains('milliy')) return const Color(0xFFF2D7B5);
    return const Color(0xFFEFE3D6);
  }

  static bool _isDemoToken(String token) => token.startsWith('demo:');
}

class _DemoUser {
  const _DemoUser({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
    required this.phone,
    required this.shift,
    required this.experience,
  });

  final int id;
  final String username;
  final String password;
  final String fullName;
  final UserRole role;
  final String phone;
  final String shift;
  final String experience;
}

class _DemoOrderLine {
  const _DemoOrderLine({
    required this.menuItemId,
    required this.quantity,
    required this.note,
  });

  final int menuItemId;
  final int quantity;
  final String note;
}

class _DemoOrder {
  const _DemoOrder({
    required this.id,
    required this.waiterLogin,
    required this.tableId,
    required this.billNumber,
    required this.status,
    required this.items,
    required this.createdAt,
  });

  final int id;
  final String waiterLogin;
  final int tableId;
  final int? billNumber;
  final OrderStatus status;
  final List<_DemoOrderLine> items;
  final DateTime createdAt;

  _DemoOrder copyWith({OrderStatus? status}) {
    return _DemoOrder(
      id: id,
      waiterLogin: waiterLogin,
      tableId: tableId,
      billNumber: billNumber,
      status: status ?? this.status,
      items: items,
      createdAt: createdAt,
    );
  }
}

class _DemoStore {
  _DemoStore() {
    _reset();
  }

  final Map<String, _DemoUser> _users = <String, _DemoUser>{};
  List<TableInfo> _tables = <TableInfo>[];
  List<MenuCategory> _categories = <MenuCategory>[];
  List<MenuItemData> _menuItems = <MenuItemData>[];
  List<_DemoOrder> _orders = <_DemoOrder>[];
  int _nextOrderId = 1;
  int _nextWaiterId = 3;
  int _nextCategoryId = 3;
  int _nextMenuItemId = 3;

  void _reset() {
    _users
      ..clear()
      ..addAll({
        'azizbek': const _DemoUser(
          id: 2,
          username: 'azizbek',
          password: '12345',
          fullName: 'Azizbek Tursunov',
          role: UserRole.waiter,
          phone: '+998901234568',
          shift: '1-smena',
          experience: '1 yil',
        ),
        'direktor': const _DemoUser(
          id: 1,
          username: 'direktor',
          password: '99999',
          fullName: 'Direktor Admin',
          role: UserRole.director,
          phone: '+998901234567',
          shift: 'Kunlik',
          experience: '3 yil',
        ),
      });

    _tables = <TableInfo>[
      const TableInfo(id: 1, number: 1, seats: 4, location: 'Asosiy zal'),
      const TableInfo(id: 2, number: 2, seats: 6, location: 'Asosiy zal'),
      const TableInfo(id: 3, number: 3, seats: 2, location: 'Terrasa'),
    ];

    _categories = const <MenuCategory>[
      MenuCategory(id: 1, name: 'Milliy taomlar', sortOrder: 1),
      MenuCategory(id: 2, name: 'Ichimliklar', sortOrder: 2),
    ];

    _menuItems = <MenuItemData>[
      MenuItemData(
        id: 1,
        name: 'Osh',
        category: 'Milliy taomlar',
        description: "An'anaviy osh",
        price: 45000,
        icon: RestaurantApiClient._iconForCategory('Milliy taomlar'),
        color: RestaurantApiClient._colorForCategory('Milliy taomlar'),
        categoryId: 1,
      ),
      MenuItemData(
        id: 2,
        name: 'Choy',
        category: 'Ichimliklar',
        description: 'Qora choy',
        price: 5000,
        icon: RestaurantApiClient._iconForCategory('Ichimliklar'),
        color: RestaurantApiClient._colorForCategory('Ichimliklar'),
        categoryId: 2,
      ),
    ];

    _orders = <_DemoOrder>[];
    _nextOrderId = 1;
    _nextWaiterId = 3;
    _nextCategoryId = 3;
    _nextMenuItemId = 3;
  }

  ApiSession? tryLogin(String username, String password) {
    final user = _users[username];
    if (user == null || user.password != password) return null;
    return ApiSession(
      accessToken: 'demo:${user.username}',
      refreshToken: 'demo-refresh:${user.username}',
      role: user.role,
      profile: _profileForUser(user),
    );
  }

  Map<String, dynamic> fetchMe(String token) {
    final user = _requireUserByToken(token);
    return {'role': user.role, 'profile': _profileForUser(user)};
  }

  List<TableInfo> fetchTables() => List<TableInfo>.from(_tables);

  void joinTable(String token, int tableId) {
    final user = _requireUserByToken(token);
    final index = _tables.indexWhere((table) => table.id == tableId);
    if (index == -1) return;

    final table = _tables[index];
    final assigned = List<Map<String, dynamic>>.from(table.assignedWaiters);
    if (!assigned.any((waiter) => waiter['username'] == user.username)) {
      assigned.add({
        'id': user.id,
        'username': user.username,
        'full_name': user.fullName,
      });
    }

    _tables[index] = TableInfo(
      id: table.id,
      number: table.number,
      seats: table.seats,
      location: table.location,
      status: table.isBusy ? 'busy' : 'assigned',
      assignedWaiters: assigned,
      isBusy: table.isBusy,
    );
  }

  List<MenuCategory> fetchCategories() => List<MenuCategory>.from(_categories);

  MenuCategory createCategory(String name, int sortOrder) {
    final category = MenuCategory(
      id: _nextCategoryId++,
      name: name,
      sortOrder: sortOrder,
    );
    _categories = [..._categories, category];
    return category;
  }

  void updateCategory(int id, String name, int sortOrder) {
    _categories = _categories
        .map(
          (category) => category.id == id
              ? MenuCategory(id: id, name: name, sortOrder: sortOrder)
              : category,
        )
        .toList();
    _menuItems = _menuItems
        .map(
          (item) => item.categoryId == id ? item.copyWith(category: name) : item,
        )
        .toList();
  }

  void deleteCategory(int id) {
    _categories = _categories.where((category) => category.id != id).toList();
    _menuItems = _menuItems.where((item) => item.categoryId != id).toList();
  }

  List<MenuItemData> fetchMenuItems() => List<MenuItemData>.from(_menuItems);

  void createMenuItem(Map<String, dynamic> data) {
    final categoryId = data['category_id'] as int?;
    final category = _categories.firstWhere(
      (item) => item.id == categoryId,
      orElse: () => const MenuCategory(id: 0, name: 'Boshqa'),
    );
    _menuItems = [
      ..._menuItems,
      MenuItemData(
        id: _nextMenuItemId++,
        name: data['name']?.toString() ?? 'Taom',
        category: category.name,
        description: data['description']?.toString() ?? '',
        price: (data['price'] as num?)?.round() ?? 0,
        icon: RestaurantApiClient._iconForCategory(category.name),
        color: RestaurantApiClient._colorForCategory(category.name),
        categoryId: category.id == 0 ? null : category.id,
      ),
    ];
  }

  void updateMenuItem(int id, Map<String, dynamic> data) {
    _menuItems = _menuItems.map((item) {
      if (item.id != id) return item;
      return item.copyWith(
        name: data['name']?.toString(),
        price: (data['price'] as num?)?.round(),
      );
    }).toList();
  }

  void deleteMenuItem(int id) {
    _menuItems = _menuItems.where((item) => item.id != id).toList();
  }

  List<OrderRecord> fetchOrders(List<MenuItemData> menuItems) {
    final menuById = {for (final item in menuItems) item.id: item};
    final records = <OrderRecord>[];

    for (final order in _orders) {
      final table = _tables.firstWhere(
        (item) => item.id == order.tableId,
        orElse: () => TableInfo(id: order.tableId, seats: 4, location: ''),
      );

      for (final line in order.items) {
        final menuItem = menuById[line.menuItemId];
        records.add(
          OrderRecord(
            id: order.id,
            waiterLogin: order.waiterLogin,
            tableId: order.tableId,
            tableNumber: table.number,
            billNumber: order.billNumber,
            itemName: menuItem?.name ?? 'Taom',
            quantity: line.quantity,
            note: line.note,
            icon: menuItem?.icon ?? Icons.restaurant,
            color: menuItem?.color ?? const Color(0xFFEFE3D6),
            status: order.status,
          ),
        );
      }
    }

    return records.reversed.toList();
  }

  int createOrder({
    required String token,
    required int tableId,
    required List<Map<String, dynamic>> items,
    int? billNumber,
    String note = '',
  }) {
    final user = _requireUserByToken(token);
    final order = _DemoOrder(
      id: _nextOrderId++,
      waiterLogin: user.username,
      tableId: tableId,
      billNumber: billNumber,
      status: OrderStatus.active,
      createdAt: DateTime.now(),
      items: items
          .map(
            (item) => _DemoOrderLine(
              menuItemId: item['menu_item_id'] as int,
              quantity: item['quantity'] as int? ?? 1,
              note: item['note']?.toString() ?? note,
            ),
          )
          .toList(),
    );
    _orders = [..._orders, order];
    _setTableBusy(tableId, true);
    joinTable(token, tableId);
    return order.id;
  }

  void rejectOrder(int orderId) {
    _orders = _orders
        .map(
          (order) => order.id == orderId
              ? order.copyWith(status: OrderStatus.rejected)
              : order,
        )
        .toList();
    _syncTablesBusyState();
  }

  void cancelOrder(int orderId) {
    _orders = _orders
        .map(
          (order) => order.id == orderId
              ? order.copyWith(status: OrderStatus.cancelled)
              : order,
        )
        .toList();
    _syncTablesBusyState();
  }

  DashboardSummary fetchDashboardSummary() {
    final paidOrders = _orders
        .where((order) => order.status == OrderStatus.paid)
        .toList();
    final paidTotal = paidOrders.fold<int>(
      0,
      (sum, order) => sum + _orderTotal(order),
    );
    final activeWaiters = _users.values
        .where((user) => user.role == UserRole.waiter)
        .where(
          (user) => _tables.any(
            (table) => table.assignedWaiters.any(
              (waiter) => waiter['username'] == user.username,
            ),
          ),
        )
        .length;

    return DashboardSummary(
      totalTables: _tables.length,
      freeTables: _tables.where((table) => table.status == 'free').length,
      busyTables: _tables.where((table) => table.status == 'busy').length,
      assignedTables: _tables
          .where((table) => table.assignedWaiters.isNotEmpty)
          .length,
      activeOrders: _orders
          .where((order) => order.status == OrderStatus.active)
          .length,
      rejectedOrders: _orders
          .where((order) => order.status == OrderStatus.rejected)
          .length,
      paidTodayOrders: paidOrders.length,
      cashToday: paidTotal,
      cardToday: 0,
      totalToday: paidTotal,
      activeWaiters: activeWaiters,
    );
  }

  List<WaiterInfo> fetchWaiters() {
    return _users.values
        .where((user) => user.role == UserRole.waiter)
        .map((user) {
          final tableIds = _tables
              .where(
                (table) => table.assignedWaiters.any(
                  (waiter) => waiter['username'] == user.username,
                ),
              )
              .map((table) => table.id)
              .toList();

          return WaiterInfo(
            id: user.id,
            username: user.username,
            fullName: user.fullName,
            phone: user.phone,
            shift: user.shift,
            experience: user.experience,
            tables: tableIds,
            activeOrdersCount: _orders
                .where(
                  (order) =>
                      order.waiterLogin == user.username &&
                      order.status == OrderStatus.active,
                )
                .length,
            rejectedOrdersCount: _orders
                .where(
                  (order) =>
                      order.waiterLogin == user.username &&
                      order.status == OrderStatus.rejected,
                )
                .length,
          );
        })
        .toList();
  }

  void createWaiter(Map<String, dynamic> data) {
    final username = data['username']?.toString().trim();
    final password = data['password']?.toString().trim();
    final fullName = data['full_name']?.toString().trim();

    if (username == null || username.isEmpty || password == null || password.isEmpty) {
      throw const RestaurantApiException(
        "Yangi ofitsant uchun login va parol majburiy.",
      );
    }
    if (_users.containsKey(username)) {
      throw const RestaurantApiException("Bu login allaqachon mavjud.");
    }

    _users[username] = _DemoUser(
      id: ++_nextWaiterId,
      username: username,
      password: password,
      fullName: fullName?.isNotEmpty == true ? fullName! : username,
      role: UserRole.waiter,
      phone: data['phone']?.toString() ?? '',
      shift: data['shift']?.toString() ?? '',
      experience: data['experience']?.toString() ?? '',
    );
  }

  void updateWaiter(int id, Map<String, dynamic> data) {
    final entry = _users.entries.firstWhere(
      (item) => item.value.id == id && item.value.role == UserRole.waiter,
      orElse: () => throw const RestaurantApiException("Ofitsant topilmadi."),
    );
    final current = entry.value;
    _users[entry.key] = _DemoUser(
      id: current.id,
      username: current.username,
      password: data['password']?.toString().isNotEmpty == true
          ? data['password'].toString()
          : current.password,
      fullName: data['full_name']?.toString().isNotEmpty == true
          ? data['full_name'].toString()
          : current.fullName,
      role: current.role,
      phone: data['phone']?.toString() ?? current.phone,
      shift: data['shift']?.toString() ?? current.shift,
      experience: data['experience']?.toString() ?? current.experience,
    );
  }

  void deleteWaiter(int id) {
    final entry = _users.entries.firstWhere(
      (item) => item.value.id == id && item.value.role == UserRole.waiter,
      orElse: () => throw const RestaurantApiException("Ofitsant topilmadi."),
    );

    _users.remove(entry.key);
    _tables = _tables
        .map(
          (table) => TableInfo(
            id: table.id,
            number: table.number,
            seats: table.seats,
            location: table.location,
            status: table.status,
            assignedWaiters: table.assignedWaiters
                .where((waiter) => waiter['username'] != entry.key)
                .toList(),
            isBusy: table.isBusy,
          ),
        )
        .toList();
    _orders = _orders.where((order) => order.waiterLogin != entry.key).toList();
    _syncTablesBusyState();
  }

  RevenueReport fetchRevenueReport({required String period}) {
    final paidOrders = _orders
        .where((order) => order.status == OrderStatus.paid)
        .toList();
    final total = paidOrders.fold<int>(
      0,
      (sum, order) => sum + _orderTotal(order),
    );

    return RevenueReport(
      period: period,
      cashTotal: total,
      cardTotal: 0,
      mixedTotal: 0,
      grandTotal: total,
      dailyBreakdown: [
        DailyBreakdown(
          date: DateTime.now().toIso8601String().split('T').first,
          cash: total,
          card: 0,
          mixed: 0,
          total: total,
        ),
      ],
    );
  }

  List<WaiterReportItem> fetchWaitersReport({required String period}) {
    return _users.values
        .where((user) => user.role == UserRole.waiter)
        .map((user) {
          final waiterOrders = _orders.where(
            (order) => order.waiterLogin == user.username,
          );
          return WaiterReportItem(
            id: user.id,
            fullName: user.fullName,
            soldOrders: waiterOrders
                .where((order) => order.status == OrderStatus.paid)
                .length,
            rejectedOrders: waiterOrders
                .where((order) => order.status == OrderStatus.rejected)
                .length,
            cancelledOrders: waiterOrders
                .where((order) => order.status == OrderStatus.cancelled)
                .length,
            revenue: waiterOrders
                .where((order) => order.status == OrderStatus.paid)
                .fold<int>(0, (sum, order) => sum + _orderTotal(order)),
          );
        })
        .toList();
  }

  WaiterProfile _profileForUser(_DemoUser user) {
    return WaiterProfile(
      name: user.fullName,
      position: user.role == UserRole.director ? 'Direktor' : 'Ofitsant',
      shift: user.shift,
      phone: user.phone,
      experience: user.experience,
    );
  }

  _DemoUser _requireUserByToken(String token) {
    final username = token.replaceFirst('demo:', '');
    final user = _users[username];
    if (user == null) {
      throw const RestaurantApiException("Demo foydalanuvchi topilmadi.");
    }
    return user;
  }

  int _orderTotal(_DemoOrder order) {
    return order.items.fold<int>(0, (sum, line) {
      final menuItem = _menuItems.firstWhere(
        (item) => item.id == line.menuItemId,
        orElse: () => throw const RestaurantApiException("Taom topilmadi."),
      );
      return sum + (menuItem.price * line.quantity);
    });
  }

  void _setTableBusy(int tableId, bool isBusy) {
    _tables = _tables.map((table) {
      if (table.id != tableId) return table;
      return TableInfo(
        id: table.id,
        number: table.number,
        seats: table.seats,
        location: table.location,
        status: isBusy ? 'busy' : table.status,
        assignedWaiters: table.assignedWaiters,
        isBusy: isBusy,
      );
    }).toList();
  }

  void _syncTablesBusyState() {
    _tables = _tables.map((table) {
      final hasActive = _orders.any(
        (order) =>
            order.tableId == table.id && order.status == OrderStatus.active,
      );
      final status = hasActive
          ? 'busy'
          : (table.assignedWaiters.isNotEmpty ? 'assigned' : 'free');
      return TableInfo(
        id: table.id,
        number: table.number,
        seats: table.seats,
        location: table.location,
        status: status,
        assignedWaiters: table.assignedWaiters,
        isBusy: hasActive,
      );
    }).toList();
  }
}
