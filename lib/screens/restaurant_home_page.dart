part of 'package:andijan_flutter/app.dart';

class RestaurantHomePage extends StatefulWidget {
  const RestaurantHomePage({super.key});

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  final RestaurantApiClient _apiClient = RestaurantApiClient();
  final Map<int, Set<String>> _tableAssignments = <int, Set<String>>{};
  final List<TableInfo> _tables = demoTables.toList(growable: true);
  final List<MenuItemData> _menuItems = demoMenu.toList(growable: true);
  final List<String> _menuCategories = demoMenu
      .map((item) => item.category)
      .toSet()
      .toList();
  final Map<int, int> _quantitiesByItemId = <int, int>{};
  final Map<int, String> _notesByItemId = <int, String>{};
  final List<OrderRecord> _orderRecords = <OrderRecord>[];
  int _nextOrderId = 1;

  bool _isLoggedIn = false;
  String _currentLogin = 'azizbek';
  UserRole _currentRole = UserRole.waiter;
  WaiterSection _waiterSection = WaiterSection.orders;
  DirectorSection _directorSection = DirectorSection.dashboard;
  OrderStep _orderStep = OrderStep.tables;
  int? _selectedTableId;
  int? _pendingJoinTableId;

  String _loginInput = 'azizbek';
  String _passwordInput = '12345';
  String _loginError = '';
  String? _accessToken;
  WaiterProfile? _currentProfileOverride;
  bool _isSyncing = false;

  UserAccount get _currentAccount =>
      waiterAccounts[_currentLogin] ?? waiterAccounts['azizbek']!;

  WaiterProfile get _currentProfile =>
      _currentProfileOverride ?? _currentAccount.profile;

  Future<void> _login() async {
    final login = _loginInput.trim();
    setState(() {
      _isSyncing = true;
      _loginError = '';
    });

    try {
      final session = await _apiClient.login(login, _passwordInput);
      final tables = await _apiClient.fetchTables(session.accessToken);
      final menuItems = await _apiClient.fetchMenuItems(session.accessToken);
      final backendOrders = await _apiClient.fetchOrders(
        session.accessToken,
        menuItems,
      );
      if (!mounted) return;
      setState(() {
        _currentLogin = login;
        _currentRole = session.role;
        _currentProfileOverride = session.profile;
        _accessToken = session.accessToken;
        _isLoggedIn = true;
        _isSyncing = false;
        _loginError = '';
        _orderRecords
          ..clear()
          ..addAll(backendOrders);
        if (tables.isNotEmpty) {
          _tables
            ..clear()
            ..addAll(tables);
        }
        if (menuItems.isNotEmpty) {
          _menuItems
            ..clear()
            ..addAll(menuItems);
          _menuCategories
            ..clear()
            ..addAll(menuItems.map((item) => item.category).toSet());
        }
      });
      return;
    } catch (_) {
      // Keep local demo mode usable when the backend is unavailable.
    }

    final account = waiterAccounts[login];
    if (account == null || account.password != _passwordInput) {
      setState(() {
        _loginError = "Login yoki parol noto'g'ri";
        _isSyncing = false;
      });
      return;
    }

    setState(() {
      _currentLogin = login;
      _currentRole = account.role;
      _accessToken = null;
      _currentProfileOverride = null;
      _isLoggedIn = true;
      _isSyncing = false;
      _loginError = '';
    });
  }

  void _logout() {
    setState(() {
      _currentLogin = 'azizbek';
      _currentRole = UserRole.waiter;
      _waiterSection = WaiterSection.orders;
      _directorSection = DirectorSection.dashboard;
      _orderStep = OrderStep.tables;
      _selectedTableId = null;
      _pendingJoinTableId = null;
      _isLoggedIn = false;
      _accessToken = null;
      _currentProfileOverride = null;
      _loginInput = 'azizbek';
      _passwordInput = '12345';
    });
  }

  void _selectDirectorSection(DirectorSection section) {
    setState(() => _directorSection = section);
  }

  void _selectTable(int tableId) {
    final assigned = _tableAssignments[tableId] ?? <String>{};
    setState(() {
      if (assigned.isEmpty) {
        _tableAssignments[tableId] = <String>{_currentLogin};
        _selectedTableId = tableId;
        _pendingJoinTableId = null;
        _orderStep = OrderStep.menu;
      } else if (assigned.contains(_currentLogin)) {
        _selectedTableId = tableId;
        _pendingJoinTableId = null;
        _orderStep = OrderStep.menu;
      } else {
        _pendingJoinTableId = tableId;
      }
    });
  }

  void _joinTable(int tableId) {
    setState(() {
      final updated = _tableAssignments[tableId] ?? <String>{};
      updated.add(_currentLogin);
      _tableAssignments[tableId] = updated;
      _selectedTableId = tableId;
      _pendingJoinTableId = null;
      _orderStep = OrderStep.menu;
    });
  }

  void _changeMenuQuantity(int itemId, int delta) {
    setState(() {
      final nextValue = (_quantitiesByItemId[itemId] ?? 0) + delta;
      final normalizedValue = nextValue < 0 ? 0 : nextValue;
      _quantitiesByItemId[itemId] = normalizedValue;
      if (normalizedValue == 0) {
        _notesByItemId.remove(itemId);
      }
    });
  }

  void _changeMenuItemNote(int itemId, String note) {
    setState(() {
      final normalized = note.trim();
      if (normalized.isEmpty) {
        _notesByItemId.remove(itemId);
      } else {
        _notesByItemId[itemId] = normalized;
      }
    });
  }

  void _updateMenuItem(int itemId, MenuItemData updatedItem) {
    setState(() {
      final index = _menuItems.indexWhere((item) => item.id == itemId);
      if (index == -1) {
        return;
      }
      if (!_menuCategories.contains(updatedItem.category)) {
        _menuCategories.add(updatedItem.category);
      }
      _menuItems[index] = updatedItem;
    });
  }

  void _addMenuItem(MenuItemData item) {
    setState(() {
      if (!_menuCategories.contains(item.category)) {
        _menuCategories.add(item.category);
      }
      _menuItems.add(item);
    });
  }

  void _deleteMenuItem(int itemId) {
    setState(() {
      _menuItems.removeWhere((item) => item.id == itemId);
      _quantitiesByItemId.remove(itemId);
    });
  }

  void _addMenuCategory(String category) {
    final normalized = category.trim();
    if (normalized.isEmpty) {
      return;
    }
    setState(() {
      if (!_menuCategories.contains(normalized)) {
        _menuCategories.add(normalized);
      }
    });
  }

  void _renameMenuCategory(String oldCategory, String newCategory) {
    final normalized = newCategory.trim();
    if (normalized.isEmpty || normalized == oldCategory) {
      return;
    }

    setState(() {
      final oldIndex = _menuCategories.indexOf(oldCategory);
      if (oldIndex != -1) {
        _menuCategories.removeAt(oldIndex);
        if (!_menuCategories.contains(normalized)) {
          _menuCategories.insert(oldIndex, normalized);
        } else {
          _menuCategories.remove(normalized);
          _menuCategories.insert(oldIndex, normalized);
        }
      } else if (!_menuCategories.contains(normalized)) {
        _menuCategories.add(normalized);
      }

      for (var i = 0; i < _menuItems.length; i++) {
        final item = _menuItems[i];
        if (item.category == oldCategory) {
          _menuItems[i] = item.copyWith(
            category: normalized,
            icon: _iconForCategory(normalized),
            color: _colorForCategory(normalized),
          );
        }
      }
    });
  }

  void _deleteMenuCategory(String category) {
    setState(() {
      _menuCategories.remove(category);
      final removedIds = _menuItems
          .where((item) => item.category == category)
          .map((item) => item.id)
          .toList();
      _menuItems.removeWhere((item) => item.category == category);
      for (final id in removedIds) {
        _quantitiesByItemId.remove(id);
      }
    });
  }

  Future<void> _submitOrder() async {
    final tableId = _selectedTableId;
    if (tableId == null) {
      return;
    }
    final selectedItems = _menuItems
        .where((item) => (_quantitiesByItemId[item.id] ?? 0) > 0)
        .toList();
    if (selectedItems.isEmpty) {
      return;
    }

    setState(() => _isSyncing = true);

    var backendOrderId = _nextOrderId;
    final token = _accessToken;
    if (token != null) {
      try {
        backendOrderId = await _apiClient.createOrder(
          token: token,
          tableId: tableId,
          orderItems: selectedItems
              .map(
                (item) => {
                  'menu_item': item.id,
                  'quantity': _quantitiesByItemId[item.id] ?? 0,
                  'note': _notesByItemId[item.id] ?? '',
                },
              )
              .toList(),
        );
      } catch (error) {
        if (!mounted) return;
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backendga yuborilmadi: $error')),
        );
        return;
      }
    }

    setState(() {
      for (final item in selectedItems) {
        final quantity = _quantitiesByItemId[item.id] ?? 0;
        if (quantity > 0) {
          _orderRecords.add(
            OrderRecord(
              id: token == null ? _nextOrderId++ : backendOrderId,
              waiterLogin: _currentLogin,
              tableId: tableId,
              itemName: item.name,
              quantity: quantity,
              note: _notesByItemId[item.id] ?? '',
              icon: item.icon,
              color: item.color,
              status: OrderStatus.active,
            ),
          );
        }
      }
      for (final item in _menuItems) {
        _quantitiesByItemId[item.id] = 0;
        _notesByItemId.remove(item.id);
      }
      if (token != null && backendOrderId >= _nextOrderId) {
        _nextOrderId = backendOrderId + 1;
      }
      _selectedTableId = null;
      _pendingJoinTableId = null;
      _orderStep = OrderStep.tables;
      _isSyncing = false;
    });

    if (token != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buyurtma kassaga yuborildi')),
      );
    }
  }

  Future<void> _rejectOrder(int orderId) async {
    final token = _accessToken;
    if (token != null) {
      try {
        await _apiClient.rejectOrder(token, orderId);
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backendda rad etilmadi: $error')),
        );
        return;
      }
    }
    setState(() {
      for (var i = 0; i < _orderRecords.length; i++) {
        if (_orderRecords[i].id == orderId) {
          _orderRecords[i] = _orderRecords[i].copyWith(
            status: OrderStatus.rejected,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _LoginScreen(
        loginInput: _loginInput,
        passwordInput: _passwordInput,
        errorText: _loginError,
        isLoading: _isSyncing,
        onLoginChanged: (value) => setState(() {
          _loginInput = value;
          _loginError = '';
        }),
        onPasswordChanged: (value) => setState(() {
          _passwordInput = value;
          _loginError = '';
        }),
        onSubmit: _login,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: _currentRole == UserRole.director
            ? _buildDirectorBody()
            : _buildWaiterBody(),
      ),
      bottomNavigationBar: _currentRole == UserRole.director
          ? _DirectorBottomBar(
              currentSection: _directorSection,
              onSelect: _selectDirectorSection,
            )
          : _WaiterBottomBar(
              currentSection: _waiterSection,
              onSelect: (section) => setState(() {
                _waiterSection = section;
                if (section == WaiterSection.orders) {
                  _selectedTableId = null;
                  _pendingJoinTableId = null;
                  _orderStep = OrderStep.tables;
                }
              }),
            ),
    );
  }

  Widget _buildWaiterBody() {
    switch (_waiterSection) {
      case WaiterSection.orders:
        return _orderStep == OrderStep.tables
            ? _TableSelectionScreen(
                waiter: _currentProfile,
                currentLogin: _currentLogin,
                tables: _tables,
                tableAssignments: _tableAssignments,
                pendingJoinTableId: _pendingJoinTableId,
                onSelectTable: _selectTable,
                onJoinTable: _joinTable,
                onDismissJoin: () => setState(() => _pendingJoinTableId = null),
              )
            : _MenuOrderScreen(
                tableId: _selectedTableId ?? 1,
                menu: _menuItems,
                categories: _menuCategories,
                quantitiesByItemId: _quantitiesByItemId,
                notesByItemId: _notesByItemId,
                isSubmitting: _isSyncing,
                onBack: () => setState(() {
                  _orderStep = OrderStep.tables;
                  _pendingJoinTableId = null;
                }),
                onQuantityChanged: _changeMenuQuantity,
                onNoteChanged: _changeMenuItemNote,
                onSubmit: _submitOrder,
              );
      case WaiterSection.profile:
        return _ProfileScreen(
          login: _currentLogin,
          profile: _currentProfile,
          onLogout: _logout,
        );
    }
  }

  Widget _buildDirectorBody() {
    switch (_directorSection) {
      case DirectorSection.dashboard:
        return _DirectorDashboardScreen(
          director: _currentProfile,
          tables: _tables,
          tableAssignments: _tableAssignments,
        );
      case DirectorSection.waiters:
        return _DirectorWaitersScreen(
          tableAssignments: _tableAssignments,
          orders: _orderRecords,
          onRejectOrder: _rejectOrder,
        );
      case DirectorSection.menu:
        return _DirectorMenuScreen(
          menu: _menuItems,
          categories: _menuCategories,
          onUpdateItem: _updateMenuItem,
          onAddItem: _addMenuItem,
          onDeleteItem: _deleteMenuItem,
          onAddCategory: _addMenuCategory,
          onRenameCategory: _renameMenuCategory,
          onDeleteCategory: _deleteMenuCategory,
        );
      case DirectorSection.reports:
        return _DirectorReportsScreen(
          director: _currentProfile,
          report: demoSalesReport,
        );
      case DirectorSection.profile:
        return _ProfileScreen(
          login: _currentLogin,
          profile: _currentProfile,
          onLogout: _logout,
        );
    }
  }
}
