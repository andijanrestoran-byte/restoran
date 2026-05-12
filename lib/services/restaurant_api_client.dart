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
    _client.connectionTimeout = const Duration(milliseconds: 600);
  }

  final String baseUrl;
  final HttpClient _client = HttpClient();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _request(
    String method,
    String path, {
    String? token,
    Object? body,
  }) async {
    final request = await _client.openUrl(method, _uri(path));
    request.headers.contentType = ContentType.json;
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    if (body != null) {
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final responseText = await response.transform(utf8.decoder).join();
    final data = responseText.isEmpty ? null : jsonDecode(responseText);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RestaurantApiException(
        data is Map && data['detail'] != null
            ? data['detail'].toString()
            : 'Backend xatosi: ${response.statusCode}',
      );
    }
    return data;
  }

  Future<ApiSession> login(String username, String password) async {
    final auth =
        await _request(
              'POST',
              '/auth/login/',
              body: {'username': username, 'password': password},
            )
            as Map<String, dynamic>;
    final access = auth['access']?.toString();
    final refresh = auth['refresh']?.toString();
    if (access == null || refresh == null) {
      throw const RestaurantApiException('Backend token qaytarmadi.');
    }

    final me =
        await _request('GET', '/auth/me/', token: access)
            as Map<String, dynamic>;
    final role = _roleFromApi(me['role']?.toString());
    return ApiSession(
      accessToken: access,
      refreshToken: refresh,
      role: role,
      profile: WaiterProfile(
        name: me['full_name']?.toString() ?? username,
        position: role == UserRole.director ? 'Direktor' : 'Ofitsant',
        shift: me['shift']?.toString() ?? '',
        phone: me['phone']?.toString() ?? '',
        experience: me['experience']?.toString() ?? '',
      ),
    );
  }

  Future<List<TableInfo>> fetchTables(String token) async {
    final data = await _request('GET', '/staff/tables/', token: token);
    final rows = _results(data);
    return rows.map((row) {
      final item = row as Map<String, dynamic>;
      return TableInfo(
        id: item['id'] as int,
        seats: item['seats'] as int? ?? 4,
        location: item['location']?.toString() ?? '',
        isBusy: item['is_busy'] as bool? ?? false,
      );
    }).toList();
  }

  Future<List<MenuItemData>> fetchMenuItems(String token) async {
    final data = await _request(
      'GET',
      '/staff/menu/items/?is_active=true',
      token: token,
    );
    final rows = _results(data);
    return rows.map((row) {
      final item = row as Map<String, dynamic>;
      final category = item['category_name']?.toString() ?? 'Menyu';
      return MenuItemData(
        id: item['id'] as int,
        name: item['name']?.toString() ?? '',
        category: category,
        description: item['description']?.toString() ?? '',
        price: double.parse(item['price'].toString()).round(),
        icon: _iconForCategory(category),
        color: _colorForCategory(category),
      );
    }).toList();
  }

  Future<int> createOrder({
    required String token,
    required int tableId,
    required List<Map<String, Object>> orderItems,
  }) async {
    final data =
        await _request(
              'POST',
              '/staff/orders/',
              token: token,
              body: {
                'table_id': tableId,
                'note': '',
                'order_items': orderItems,
              },
            )
            as Map<String, dynamic>;
    return data['id'] as int;
  }

  Future<List<OrderRecord>> fetchOrders(
    String token,
    List<MenuItemData> menuItems,
  ) async {
    final data = await _request('GET', '/staff/orders/', token: token);
    final rows = _results(data);
    final menuById = {for (final item in menuItems) item.id: item};
    final records = <OrderRecord>[];
    for (final row in rows) {
      final order = row as Map<String, dynamic>;
      final orderId = order['id'] as int;
      final table = order['table'] as Map<String, dynamic>?;
      final waiter = order['waiter'] as Map<String, dynamic>?;
      final status = order['status']?.toString() == 'rejected'
          ? OrderStatus.rejected
          : OrderStatus.active;
      final items = order['items'] as List<dynamic>? ?? const <dynamic>[];
      for (final rawItem in items) {
        final item = rawItem as Map<String, dynamic>;
        final menuId = item['menu_item'] as int?;
        final menuItem = menuById[menuId];
        records.add(
          OrderRecord(
            id: orderId,
            waiterLogin: waiter?['username']?.toString() ?? '',
            tableId: table?['id'] as int? ?? 0,
            itemName:
                item['menu_item_name']?.toString() ?? menuItem?.name ?? 'Taom',
            quantity: item['quantity'] as int? ?? 1,
            note: item['note']?.toString() ?? '',
            icon: menuItem?.icon ?? Icons.restaurant,
            color: menuItem?.color ?? const Color(0xFFEFE3D6),
            status: status,
          ),
        );
      }
    }
    return records;
  }

  Future<void> rejectOrder(String token, int orderId) async {
    await _request('POST', '/staff/orders/$orderId/reject/', token: token);
  }

  static UserRole _roleFromApi(String? role) {
    return role == 'director' || role == 'cashier'
        ? UserRole.director
        : UserRole.waiter;
  }

  static List<dynamic> _results(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['results'] is List) {
      return data['results'] as List<dynamic>;
    }
    return const <dynamic>[];
  }
}
