part of 'package:andijan_flutter/app.dart';

class RestaurantHomePage extends StatefulWidget {
  const RestaurantHomePage({super.key});

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  final RestaurantApiClient _apiClient = RestaurantApiClient();
  
  List<TableInfo> _tables = [];
  List<MenuItemData> _menuItems = [];
  List<MenuCategory> _menuCategories = [];
  List<OrderRecord> _orderRecords = [];
  List<WaiterInfo> _waiters = [];
  DashboardSummary? _summary;

  final Map<int, int> _quantitiesByItemId = <int, int>{};
  final Map<int, String> _notesByItemId = <int, String>{};

  bool _isLoggedIn = false;
  String _currentLogin = '';
  UserRole _currentRole = UserRole.waiter;
  WaiterSection _waiterSection = WaiterSection.orders;
  DirectorSection _directorSection = DirectorSection.dashboard;
  OrderStep _orderStep = OrderStep.tables;
  int? _selectedTableId;
  int _selectedBillNumber = 1;

  String _loginInput = '';
  String _passwordInput = '';
  String _loginError = '';
  String? _accessToken;
  WaiterProfile? _currentProfile;
  bool _isLoading = false;

  Future<void> _login() async {
    final login = _loginInput.trim();
    if (login.isEmpty || _passwordInput.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loginError = '';
    });

    try {
      final session = await _apiClient.login(login, _passwordInput);
      _accessToken = session.accessToken;
      _currentLogin = login;
      _currentRole = session.role;
      _currentProfile = session.profile;
      
      await _loadData();
      
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loginError = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_accessToken == null) return;
    final token = _accessToken!;
    
    try {
      final tables = await _apiClient.fetchTables(token);
      final categories = await _apiClient.fetchCategories(token);
      final items = await _apiClient.fetchMenuItems(token);
      
      List<OrderRecord> orders = [];
      if (_currentRole == UserRole.waiter || _currentRole == UserRole.director) {
        orders = await _apiClient.fetchOrders(token, items);
      }

      DashboardSummary? summary;
      List<WaiterInfo> waiters = [];
      if (_currentRole == UserRole.director) {
        summary = await _apiClient.fetchDashboardSummary(token);
        waiters = await _apiClient.fetchWaiters(token);
      }

      setState(() {
        _tables = tables;
        _menuCategories = categories;
        _menuItems = items;
        _orderRecords = orders;
        _summary = summary;
        _waiters = waiters;
      });
    } catch (e) {
      debugPrint('Data load error: $e');
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _accessToken = null;
      _currentProfile = null;
      _tables = [];
      _menuItems = [];
      _menuCategories = [];
      _orderRecords = [];
    });
  }

  // ---- Waiter Actions ----

  void _selectTable(int tableId) {
    final table = _tables.firstWhere((t) => t.id == tableId);
    final assigned = table.assignedWaiters;
    
    if (assigned.isEmpty || assigned.any((w) => w['username'] == _currentLogin)) {
      setState(() {
        _selectedTableId = tableId;
        _selectedBillNumber = 1;
        _orderStep = OrderStep.menu;
      });
      if (assigned.isEmpty) {
        _joinTable(tableId);
      }
    } else {
      _showJoinDialog(tableId, assigned);
    }
  }

  void _showJoinDialog(int tableId, List<dynamic> assigned) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Stol #$tableId band"),
        content: Text("Bu stolda ${assigned.map((w) => w['full_name']).join(', ')} ishlayapti. Siz ham qo'shilmoqchimisiz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Yo\'q')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _joinTable(tableId);
            },
            child: const Text('Ha, qo\'shilish'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinTable(int tableId) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.joinTable(_accessToken!, tableId);
      await _loadData();
      setState(() {
        _selectedTableId = tableId;
        _selectedBillNumber = 1;
        _orderStep = OrderStep.menu;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  void _changeMenuQuantity(int itemId, int delta) {
    setState(() {
      final q = (_quantitiesByItemId[itemId] ?? 0) + delta;
      _quantitiesByItemId[itemId] = q < 0 ? 0 : q;
    });
  }

  void _changeMenuItemNote(int itemId, String note) {
    _notesByItemId[itemId] = note;
  }

  Future<void> _submitOrder() async {
    if (_accessToken == null || _selectedTableId == null) return;
    
    final items = <Map<String, dynamic>>[];
    _quantitiesByItemId.forEach((id, q) {
      if (q > 0) {
        items.add({
          'menu_item_id': id,
          'quantity': q,
          'note': _notesByItemId[id] ?? '',
        });
      }
    });

    if (items.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _apiClient.createOrder(
        token: _accessToken!,
        tableId: _selectedTableId!,
        billNumber: _selectedBillNumber,
        items: items,
      );
      _quantitiesByItemId.clear();
      _notesByItemId.clear();
      _selectedTableId = null;
      _orderStep = OrderStep.tables;
      await _loadData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Buyurtma yuborildi')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---- Director Actions ----

  Future<void> _addCategory(String name, int sortOrder) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.createCategory(_accessToken!, name, sortOrder);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _updateCategory(int id, String name, int sortOrder) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.updateCategory(_accessToken!, id, name, sortOrder);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _deleteCategory(int id) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.deleteCategory(_accessToken!, id);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _addMenuItem(Map<String, dynamic> data) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.createMenuItem(_accessToken!, data);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _updateMenuItem(int id, Map<String, dynamic> data) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.updateMenuItem(_accessToken!, id, data);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _deleteMenuItem(int id) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.deleteMenuItem(_accessToken!, id);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _rejectOrder(int orderId) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.rejectOrder(_accessToken!, orderId);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _addWaiter(Map<String, dynamic> data) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.createWaiter(_accessToken!, data);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _updateWaiter(int id, Map<String, dynamic> data) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.updateWaiter(_accessToken!, id, data);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  Future<void> _deleteWaiter(int id) async {
    if (_accessToken == null) return;
    try {
      await _apiClient.deleteWaiter(_accessToken!, id);
      await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _LoginScreen(
        loginInput: _loginInput,
        passwordInput: _passwordInput,
        errorText: _loginError,
        isLoading: _isLoading,
        onLoginChanged: (val) => setState(() => _loginInput = val),
        onPasswordChanged: (val) => setState(() => _passwordInput = val),
        onSubmit: _login,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _currentRole == UserRole.director ? _buildDirectorBody() : _buildWaiterBody(),
        ),
      ),
      bottomNavigationBar: _currentRole == UserRole.director
          ? _DirectorBottomBar(currentSection: _directorSection, onSelect: (s) => setState(() => _directorSection = s))
          : _WaiterBottomBar(
              currentSection: _waiterSection,
              onSelect: (s) => setState(() {
                _waiterSection = s;
                if (s == WaiterSection.orders) _orderStep = OrderStep.tables;
              }),
            ),
    );
  }

  Widget _buildWaiterBody() {
    if (_waiterSection == WaiterSection.profile) {
      return _ProfileScreen(login: _currentLogin, profile: _currentProfile!, onLogout: _logout);
    }
    
    if (_waiterSection == WaiterSection.activeOrders) {
      return _ActiveOrdersScreen(orders: _orderRecords, currentLogin: _currentLogin);
    }
    
    if (_orderStep == OrderStep.tables) {
      return _TableSelectionScreen(
        waiter: _currentProfile!,
        currentLogin: _currentLogin,
        tables: _tables,
        onSelectTable: _selectTable,
        onJoinTable: _joinTable,
      );
    }

    return _MenuOrderScreen(
      tableId: _selectedTableId!,
      menu: _menuItems,
      categories: _menuCategories,
      quantitiesByItemId: _quantitiesByItemId,
      notesByItemId: _notesByItemId,
      isSubmitting: _isLoading,
      selectedBillNumber: _selectedBillNumber,
      onBillNumberChanged: (val) => setState(() => _selectedBillNumber = val),
      onBack: () => setState(() => _orderStep = OrderStep.tables),
      onQuantityChanged: _changeMenuQuantity,
      onNoteChanged: _changeMenuItemNote,
      onSubmit: _submitOrder,
    );
  }

  Widget _buildDirectorBody() {
    switch (_directorSection) {
      case DirectorSection.dashboard:
        return _DirectorDashboardScreen(director: _currentProfile!, summary: _summary!, tables: _tables);
      case DirectorSection.waiters:
        return _DirectorWaitersScreen(
          waiters: _waiters,
          onRejectOrder: _rejectOrder,
          onCreateWaiter: _addWaiter,
          onUpdateWaiter: _updateWaiter,
          onDeleteWaiter: _deleteWaiter,
          orders: _orderRecords,
        );
      case DirectorSection.menu:
        return _DirectorMenuScreen(
          menu: _menuItems,
          categories: _menuCategories,
          onUpdateItem: _updateMenuItem,
          onAddItem: _addMenuItem,
          onDeleteItem: _deleteMenuItem,
          onAddCategory: _addCategory,
          onRenameCategory: _updateCategory,
          onDeleteCategory: _deleteCategory,
        );
      case DirectorSection.reports:
        return _DirectorReportsScreen(
          onFetchRevenue: (p) => _apiClient.fetchRevenueReport(_accessToken!, period: p),
          onFetchWaiters: (p) => _apiClient.fetchWaitersReport(_accessToken!, period: p),
        );
      case DirectorSection.profile:
        return _ProfileScreen(login: _currentLogin, profile: _currentProfile!, onLogout: _logout);
    }
  }
}
