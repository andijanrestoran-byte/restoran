import 'package:flutter/material.dart';

void main() {
  runApp(const AndijanFlutterApp());
}

class AndijanFlutterApp extends StatelessWidget {
  const AndijanFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Andijan Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A4B2A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F1E8),
      ),
      home: const RestaurantHomePage(),
    );
  }
}

enum UserRole { waiter, director }

enum WaiterSection { orders, profile }

enum DirectorSection { dashboard, waiters, menu, reports, profile }

enum OrderStep { tables, menu }

enum OrderStatus { active, rejected }

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
    this.isBusy = false,
  });

  final int id;
  final int seats;
  final String location;
  final bool isBusy;
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
  });

  final int id;
  final String name;
  final String category;
  final String description;
  final int price;
  final IconData icon;
  final Color color;

  MenuItemData copyWith({
    String? name,
    String? category,
    String? description,
    int? price,
    IconData? icon,
    Color? color,
  }) {
    return MenuItemData(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}

class UserAccount {
  const UserAccount({
    required this.password,
    required this.role,
    required this.profile,
  });

  final String password;
  final UserRole role;
  final WaiterProfile profile;
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

class SalesReport {
  const SalesReport({
    required this.dailyCash,
    required this.dailyCard,
    required this.dailyOrders,
    required this.weeklyRevenue,
    required this.weeklyGrowthPercent,
    required this.monthlyRevenue,
    required this.monthlyGrowthPercent,
    required this.dailyTrend,
    required this.weeklyTrend,
    required this.monthlyTrend,
    required this.topProducts,
  });

  final int dailyCash;
  final int dailyCard;
  final int dailyOrders;
  final int weeklyRevenue;
  final int weeklyGrowthPercent;
  final int monthlyRevenue;
  final int monthlyGrowthPercent;
  final String dailyTrend;
  final String weeklyTrend;
  final String monthlyTrend;
  final List<ProductSales> topProducts;
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.waiterLogin,
    required this.tableId,
    required this.itemName,
    required this.quantity,
    required this.icon,
    required this.color,
    required this.status,
  });

  final int id;
  final String waiterLogin;
  final int tableId;
  final String itemName;
  final int quantity;
  final IconData icon;
  final Color color;
  final OrderStatus status;

  OrderRecord copyWith({OrderStatus? status}) {
    return OrderRecord(
      id: id,
      waiterLogin: waiterLogin,
      tableId: tableId,
      itemName: itemName,
      quantity: quantity,
      icon: icon,
      color: color,
      status: status ?? this.status,
    );
  }
}

const demoWaiter = WaiterProfile(
  name: 'Azizbek Karimov',
  position: 'Ofitsant',
  shift: '10:00 - 22:00',
  phone: '+998 90 123 45 67',
  experience: '4 yil',
);

const waiterAccounts = <String, UserAccount>{
  'azizbek': UserAccount(
    password: '12345',
    role: UserRole.waiter,
    profile: demoWaiter,
  ),
  'javohir': UserAccount(
    password: '11111',
    role: UserRole.waiter,
    profile: WaiterProfile(
      name: 'Javohir Rasulov',
      position: 'Ofitsant',
      shift: '09:00 - 21:00',
      phone: '+998 91 111 22 33',
      experience: '3 yil',
    ),
  ),
  'dilshod': UserAccount(
    password: '22222',
    role: UserRole.waiter,
    profile: WaiterProfile(
      name: 'Dilshod Ergashev',
      position: 'Ofitsant',
      shift: '08:00 - 20:00',
      phone: '+998 93 222 44 55',
      experience: '2 yil',
    ),
  ),
  'sardor': UserAccount(
    password: '33333',
    role: UserRole.waiter,
    profile: WaiterProfile(
      name: 'Sardor Ismoilov',
      position: 'Ofitsant',
      shift: '11:00 - 23:00',
      phone: '+998 94 333 66 77',
      experience: '5 yil',
    ),
  ),
  'direktor': UserAccount(
    password: '99999',
    role: UserRole.director,
    profile: WaiterProfile(
      name: 'Kamoliddin Ahmedov',
      position: 'Direktor',
      shift: '09:00 - 18:00',
      phone: '+998 90 555 77 88',
      experience: '10 yil',
    ),
  ),
};

const demoTables = <TableInfo>[
  TableInfo(id: 1, seats: 2, location: 'Deraza yonida'),
  TableInfo(id: 2, seats: 4, location: 'Asosiy zal'),
  TableInfo(id: 3, seats: 4, location: 'Asosiy zal'),
  TableInfo(id: 4, seats: 6, location: 'Oilaviy zona', isBusy: true),
  TableInfo(id: 5, seats: 2, location: 'Ayvon'),
  TableInfo(id: 6, seats: 8, location: 'VIP xona'),
  TableInfo(id: 7, seats: 4, location: 'Ayvon'),
  TableInfo(id: 8, seats: 6, location: 'Asosiy zal'),
];

const demoMenu = <MenuItemData>[
  MenuItemData(
    id: 1,
    name: "To'y oshi",
    category: 'Milliy taomlar',
    description: "Mol go'shtli, sabzili va bedanali",
    price: 42000,
    icon: Icons.rice_bowl,
    color: Color(0xFFF2D7B5),
  ),
  MenuItemData(
    id: 2,
    name: 'Manti',
    category: 'Milliy taomlar',
    description: '8 dona, qatiq va maxsus qayla bilan',
    price: 32000,
    icon: Icons.lunch_dining,
    color: Color(0xFFF2D7B5),
  ),
  MenuItemData(
    id: 3,
    name: "Lag'mon",
    category: 'Milliy taomlar',
    description: "Qo'lda cho'zilgan xamir va mol go'shti",
    price: 36000,
    icon: Icons.ramen_dining,
    color: Color(0xFFF2D7B5),
  ),
  MenuItemData(
    id: 4,
    name: 'Norin',
    category: 'Milliy taomlar',
    description: "Ot go'shti va xamir bilan sovuq taom",
    price: 34000,
    icon: Icons.lunch_dining,
    color: Color(0xFFF2D7B5),
  ),
  MenuItemData(
    id: 5,
    name: 'Iskandar kabob',
    category: 'Turk taomlari',
    description: "Mol go'shti, yogurt va pomidor sous bilan",
    price: 54000,
    icon: Icons.kebab_dining,
    color: Color(0xFFF3D0C7),
  ),
  MenuItemData(
    id: 6,
    name: 'Adana kabob',
    category: 'Turk taomlari',
    description: 'Achchiq qiymali kabob va guruch bilan',
    price: 49000,
    icon: Icons.kebab_dining,
    color: Color(0xFFF3D0C7),
  ),
  MenuItemData(
    id: 7,
    name: 'Tovuq doner',
    category: 'Turk taomlari',
    description: "Lavash ichida tovuq go'shti va kartoshka",
    price: 31000,
    icon: Icons.wrap_text,
    color: Color(0xFFF3D0C7),
  ),
  MenuItemData(
    id: 8,
    name: "Mercimek sho'rva",
    category: 'Turk taomlari',
    description: 'Qizil yasmiqli yengil sho‘rva',
    price: 26000,
    icon: Icons.soup_kitchen,
    color: Color(0xFFF3D0C7),
  ),
  MenuItemData(
    id: 9,
    name: 'Cheeseburger',
    category: 'Fastfoodlar',
    description: "Mol go'shti kotleti va cheddar pishlog'i bilan",
    price: 28000,
    icon: Icons.lunch_dining,
    color: Color(0xFFE6D8F8),
  ),
  MenuItemData(
    id: 10,
    name: 'Chicken burger',
    category: 'Fastfoodlar',
    description: 'Qarsildoq tovuq filesi bilan',
    price: 26000,
    icon: Icons.fastfood,
    color: Color(0xFFE6D8F8),
  ),
  MenuItemData(
    id: 11,
    name: 'Hot-dog',
    category: 'Fastfoodlar',
    description: 'Sosiska, sous va karam bilan',
    price: 21000,
    icon: Icons.lunch_dining,
    color: Color(0xFFE6D8F8),
  ),
  MenuItemData(
    id: 12,
    name: 'Fri kartoshka',
    category: 'Fastfoodlar',
    description: 'Katta porsiya, sous bilan',
    price: 18000,
    icon: Icons.fastfood,
    color: Color(0xFFE6D8F8),
  ),
  MenuItemData(
    id: 13,
    name: 'Sezar salat',
    category: 'Salatlar',
    description: 'Tovuq, parmesan va maxsus sous',
    price: 29000,
    icon: Icons.eco,
    color: Color(0xFFD7EEDC),
  ),
  MenuItemData(
    id: 14,
    name: 'Achchiq chuchuk',
    category: 'Salatlar',
    description: 'Yangi pomidor va piyoz',
    price: 18000,
    icon: Icons.eco,
    color: Color(0xFFD7EEDC),
  ),
  MenuItemData(
    id: 15,
    name: 'Grekcha salat',
    category: 'Salatlar',
    description: 'Brynza, zaytun va yangi sabzavotlar',
    price: 27000,
    icon: Icons.eco,
    color: Color(0xFFD7EEDC),
  ),
  MenuItemData(
    id: 16,
    name: 'Yaponcha salat',
    category: 'Salatlar',
    description: 'Tovuq, bodring va kunjutli sous',
    price: 25000,
    icon: Icons.eco,
    color: Color(0xFFD7EEDC),
  ),
  MenuItemData(
    id: 17,
    name: 'Moxito',
    category: 'Ichimliklar',
    description: 'Limon, yalpiz va gazli suv',
    price: 22000,
    icon: Icons.local_drink,
    color: Color(0xFFD7EBF3),
  ),
  MenuItemData(
    id: 18,
    name: 'Limonad',
    category: 'Ichimliklar',
    description: 'Uy usulida tayyorlangan 1 litr',
    price: 24000,
    icon: Icons.emoji_food_beverage,
    color: Color(0xFFD7EBF3),
  ),
  MenuItemData(
    id: 19,
    name: "Ko'k choy",
    category: 'Ichimliklar',
    description: 'Choynak',
    price: 12000,
    icon: Icons.emoji_food_beverage,
    color: Color(0xFFD7EBF3),
  ),
  MenuItemData(
    id: 20,
    name: 'Amerikano',
    category: 'Ichimliklar',
    description: 'Yangi damlangan qahva',
    price: 18000,
    icon: Icons.coffee,
    color: Color(0xFFD7EBF3),
  ),
  MenuItemData(
    id: 21,
    name: 'Medovik',
    category: 'Desertlar',
    description: 'Asalli yumshoq tort',
    price: 21000,
    icon: Icons.cake,
    color: Color(0xFFF5DDED),
  ),
  MenuItemData(
    id: 22,
    name: 'Sansebastyan',
    category: 'Desertlar',
    description: 'Kremli pishloqli desert',
    price: 26000,
    icon: Icons.bakery_dining,
    color: Color(0xFFF5DDED),
  ),
  MenuItemData(
    id: 23,
    name: 'Napoleon',
    category: 'Desertlar',
    description: 'Yupqa qatlamli kremli tort',
    price: 23000,
    icon: Icons.cake,
    color: Color(0xFFF5DDED),
  ),
  MenuItemData(
    id: 24,
    name: 'Muzqaymoq assorti',
    category: 'Desertlar',
    description: "3 xil ta'mdagi muzqaymoq",
    price: 19000,
    icon: Icons.icecream,
    color: Color(0xFFF5DDED),
  ),
];

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

const demoSalesReport = SalesReport(
  dailyCash: 2450000,
  dailyCard: 3180000,
  dailyOrders: 47,
  weeklyRevenue: 32400000,
  weeklyGrowthPercent: 14,
  monthlyRevenue: 128600000,
  monthlyGrowthPercent: 11,
  dailyTrend:
      "Bugun tushlikdan keyin savdo faolligi oshgan, naqd tushum 43% ulushni olgan.",
  weeklyTrend:
      "Haftalik savdo o'tgan haftaga nisbatan 14% ko'tarilgan, eng katta o'sish fastfood va ichimliklarda.",
  monthlyTrend:
      "Oylik tushum barqaror o'smoqda, milliy taomlar va desertlar asosiy drayver bo'lib turibdi.",
  topProducts: [
    ProductSales(productName: "To'y oshi", quantity: 38, revenue: 15960000),
    ProductSales(productName: 'Moxito', quantity: 34, revenue: 748000),
    ProductSales(productName: 'Adana kabob', quantity: 21, revenue: 1029000),
    ProductSales(productName: 'Sezar salat', quantity: 19, revenue: 551000),
    ProductSales(productName: 'Cheeseburger', quantity: 18, revenue: 504000),
  ],
);

class RestaurantHomePage extends StatefulWidget {
  const RestaurantHomePage({super.key});

  @override
  State<RestaurantHomePage> createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage> {
  final Map<int, Set<String>> _tableAssignments = <int, Set<String>>{};
  final List<MenuItemData> _menuItems = demoMenu.toList(growable: true);
  final List<String> _menuCategories = demoMenu
      .map((item) => item.category)
      .toSet()
      .toList();
  final Map<int, int> _quantitiesByItemId = <int, int>{};
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

  UserAccount get _currentAccount => waiterAccounts[_currentLogin]!;

  WaiterProfile get _currentProfile => _currentAccount.profile;

  void _login() {
    final account = waiterAccounts[_loginInput.trim()];
    if (account == null || account.password != _passwordInput) {
      setState(() {
        _loginError = "Login yoki parol noto'g'ri";
      });
      return;
    }

    setState(() {
      _currentLogin = _loginInput.trim();
      _currentRole = account.role;
      _isLoggedIn = true;
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
      _quantitiesByItemId[itemId] = nextValue < 0 ? 0 : nextValue;
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

  void _submitOrder() {
    final tableId = _selectedTableId;
    if (tableId == null) {
      return;
    }

    setState(() {
      for (final item in _menuItems) {
        final quantity = _quantitiesByItemId[item.id] ?? 0;
        if (quantity > 0) {
          _orderRecords.add(
            OrderRecord(
              id: _nextOrderId++,
              waiterLogin: _currentLogin,
              tableId: tableId,
              itemName: item.name,
              quantity: quantity,
              icon: item.icon,
              color: item.color,
              status: OrderStatus.active,
            ),
          );
        }
        _quantitiesByItemId[item.id] = 0;
      }
      _selectedTableId = null;
      _pendingJoinTableId = null;
      _orderStep = OrderStep.tables;
    });
  }

  void _rejectOrder(int orderId) {
    final index = _orderRecords.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return;
    }
    setState(() {
      _orderRecords[index] = _orderRecords[index].copyWith(
        status: OrderStatus.rejected,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _LoginScreen(
        loginInput: _loginInput,
        passwordInput: _passwordInput,
        errorText: _loginError,
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
                tables: demoTables,
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
                onBack: () => setState(() {
                  _orderStep = OrderStep.tables;
                  _pendingJoinTableId = null;
                }),
                onQuantityChanged: _changeMenuQuantity,
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
          tables: demoTables,
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

class _LoginScreen extends StatelessWidget {
  const _LoginScreen({
    required this.loginInput,
    required this.passwordInput,
    required this.errorText,
    required this.onLoginChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
  });

  final String loginInput;
  final String passwordInput;
  final String errorText;
  final ValueChanged<String> onLoginChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Andijan Restoran',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ofitsant va direktor paneliga kirish',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('login_username'),
                    controller: TextEditingController(text: loginInput)
                      ..selection = TextSelection.collapsed(
                        offset: loginInput.length,
                      ),
                    onChanged: onLoginChanged,
                    decoration: const InputDecoration(labelText: 'Login'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('login_password'),
                    controller: TextEditingController(text: passwordInput)
                      ..selection = TextSelection.collapsed(
                        offset: passwordInput.length,
                      ),
                    onChanged: onPasswordChanged,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Parol'),
                  ),
                  if (errorText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('login_submit'),
                      onPressed: onSubmit,
                      child: const Text('Kirish'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Hisoblar: azizbek/12345, javohir/11111, dilshod/22222, sardor/33333, direktor/99999",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableSelectionScreen extends StatelessWidget {
  const _TableSelectionScreen({
    required this.waiter,
    required this.currentLogin,
    required this.tables,
    required this.tableAssignments,
    required this.pendingJoinTableId,
    required this.onSelectTable,
    required this.onJoinTable,
    required this.onDismissJoin,
  });

  final WaiterProfile waiter;
  final String currentLogin;
  final List<TableInfo> tables;
  final Map<int, Set<String>> tableAssignments;
  final int? pendingJoinTableId;
  final ValueChanged<int> onSelectTable;
  final ValueChanged<int> onJoinTable;
  final VoidCallback onDismissJoin;

  @override
  Widget build(BuildContext context) {
    final assignedWaiters = pendingJoinTableId == null
        ? const <String>{}
        : tableAssignments[pendingJoinTableId] ?? <String>{};

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeroCard(
          title: 'Buyurtma berish',
          subtitle: '${waiter.name} | ${waiter.position}',
          description:
              "Avval stol raqamini tanlang. Stol tanlangandan keyin menyu ochiladi.",
          color: const Color(0xFF8A4B2A),
        ),
        if (pendingJoinTableId != null && assignedWaiters.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFFF7E8DA),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stol #$pendingJoinTableId da xizmat ko'rsatilmoqda",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignedWaiters.map(waiterNameByLogin).join(', '),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => onJoinTable(pendingJoinTableId!),
                        child: const Text("Meni ham qo'shish"),
                      ),
                      OutlinedButton(
                        onPressed: onDismissJoin,
                        child: const Text('Bekor qilish'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Stol raqamini tanlang',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final columns = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 620
                ? 2
                : 1;
            final cardWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: tables.map((table) {
                final assigned = tableAssignments[table.id] ?? <String>{};
                final currentWaiterAttached = assigned.contains(currentLogin);
                final statusColor = assigned.isNotEmpty
                    ? const Color(0xFF9C3C24)
                    : table.isBusy
                    ? const Color(0xFFB26A3C)
                    : const Color(0xFF2B7A4B);

                return SizedBox(
                  width: cardWidth,
                  child: InkWell(
                    key: Key('table_card_${table.id}'),
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => onSelectTable(table.id),
                    child: Card(
                      color: table.isBusy
                          ? const Color(0xFFE7D9D2)
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stol ${table.id}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text('${table.seats} kishilik'),
                            Text(
                              table.location,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              assigned.isNotEmpty
                                  ? "Xizmat ko'rsatilmoqda"
                                  : table.isBusy
                                  ? 'Band'
                                  : "Bo'sh",
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (assigned.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                assigned.map(waiterNameByLogin).join(', '),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (currentWaiterAttached) ...[
                              const SizedBox(height: 4),
                              const Text(
                                "Siz ham xizmat ko'rsatyapsiz",
                                style: TextStyle(
                                  color: Color(0xFF2B7A4B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MenuOrderScreen extends StatefulWidget {
  const _MenuOrderScreen({
    required this.tableId,
    required this.menu,
    required this.categories,
    required this.quantitiesByItemId,
    required this.onBack,
    required this.onQuantityChanged,
    required this.onSubmit,
  });

  final int tableId;
  final List<MenuItemData> menu;
  final List<String> categories;
  final Map<int, int> quantitiesByItemId;
  final VoidCallback onBack;
  final void Function(int itemId, int delta) onQuantityChanged;
  final VoidCallback onSubmit;

  @override
  State<_MenuOrderScreen> createState() => _MenuOrderScreenState();
}

class _MenuOrderScreenState extends State<_MenuOrderScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<(int, MenuItemData)>>{};
    for (var i = 0; i < widget.menu.length; i++) {
      final item = widget.menu[i];
      grouped.putIfAbsent(item.category, () => <(int, MenuItemData)>[]).add((
        i,
        item,
      ));
    }
    final orderedCategories = widget.categories.toList();
    for (final category in grouped.keys) {
      if (!orderedCategories.contains(category)) {
        orderedCategories.add(category);
      }
    }

    final totalItems = widget.menu.fold<int>(
      0,
      (sum, item) => sum + (widget.quantitiesByItemId[item.id] ?? 0),
    );
    final totalPrice = widget.menu.fold<int>(
      0,
      (sum, item) =>
          sum + (item.price * (widget.quantitiesByItemId[item.id] ?? 0)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stol #${widget.tableId} buyurtmasi',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "Kategoriyalar bo'yicha taomlarni tanlang",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: widget.onBack,
                child: const Text('Stollar'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: orderedCategories.map((category) {
              final selected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = selected ? null : category;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: orderedCategories
                .where(
                  (category) =>
                      _selectedCategory == null ||
                      _selectedCategory == category,
                )
                .expand((category) {
                  final items =
                      grouped[category] ?? const <(int, MenuItemData)>[];
                  return [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (items.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Bu kategoriyada taom yo‘q',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ...items.map((pair) {
                        final item = pair.$2;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FoodIconCard(
                                  icon: item.icon,
                                  color: item.color,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      Text(
                                        "${item.price} so'm",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.description,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          OutlinedButton(
                                            onPressed: () => widget
                                                .onQuantityChanged(item.id, -1),
                                            child: const Text('-'),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5E7D6),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              (widget.quantitiesByItemId[item
                                                          .id] ??
                                                      0)
                                                  .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          FilledButton(
                                            key: Key(
                                              'increase_item_${item.id}',
                                            ),
                                            onPressed: () => widget
                                                .onQuantityChanged(item.id, 1),
                                            child: const Text('+'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ];
                })
                .toList(),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E221C),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jami pozitsiya',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '$totalItems ta',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Jami summa: $totalPrice so\'m',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('submit_order'),
                  onPressed: totalItems > 0 ? widget.onSubmit : null,
                  child: const Text('Buyurtmani yuborish'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuEditorControllers {
  _MenuEditorControllers(MenuItemData item)
    : name = TextEditingController(text: item.name),
      category = TextEditingController(text: item.category),
      price = TextEditingController(text: item.price.toString());

  final TextEditingController name;
  final TextEditingController category;
  final TextEditingController price;

  void sync(MenuItemData item) {
    if (name.text != item.name) {
      name.text = item.name;
    }
    if (category.text != item.category) {
      category.text = item.category;
    }
    final priceText = item.price.toString();
    if (price.text != priceText) {
      price.text = priceText;
    }
  }

  void dispose() {
    name.dispose();
    category.dispose();
    price.dispose();
  }
}

class _DirectorMenuScreen extends StatefulWidget {
  const _DirectorMenuScreen({
    required this.menu,
    required this.categories,
    required this.onUpdateItem,
    required this.onAddItem,
    required this.onDeleteItem,
    required this.onAddCategory,
    required this.onRenameCategory,
    required this.onDeleteCategory,
  });

  final List<MenuItemData> menu;
  final List<String> categories;
  final void Function(int itemId, MenuItemData updatedItem) onUpdateItem;
  final ValueChanged<MenuItemData> onAddItem;
  final ValueChanged<int> onDeleteItem;
  final ValueChanged<String> onAddCategory;
  final void Function(String oldCategory, String newCategory) onRenameCategory;
  final ValueChanged<String> onDeleteCategory;

  @override
  State<_DirectorMenuScreen> createState() => _DirectorMenuScreenState();
}

class _DirectorMenuScreenState extends State<_DirectorMenuScreen> {
  final Map<int, _MenuEditorControllers> _controllers =
      <int, _MenuEditorControllers>{};
  final Set<String> _expandedCategories = <String>{};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant _DirectorMenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers() {
    final existingIds = widget.menu.map((item) => item.id).toSet();
    final removedIds = _controllers.keys
        .where((id) => !existingIds.contains(id))
        .toList();
    for (final id in removedIds) {
      _controllers.remove(id)?.dispose();
    }
    for (final item in widget.menu) {
      _controllers.putIfAbsent(item.id, () => _MenuEditorControllers(item));
      _controllers[item.id]!.sync(item);
    }
  }

  int _nextMenuId() {
    var nextId = 1;
    for (final item in widget.menu) {
      if (item.id >= nextId) {
        nextId = item.id + 1;
      }
    }
    return nextId;
  }

  List<String> _orderedCategories() {
    final categories = widget.categories.toList();
    for (final item in widget.menu) {
      if (!categories.contains(item.category)) {
        categories.add(item.category);
      }
    }
    return categories;
  }

  Future<String?> _promptText({
    required String title,
    required String label,
    String? initialValue,
    String confirmText = 'Saqlash',
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            key: const Key('menu_prompt_input'),
            controller: controller,
            decoration: InputDecoration(labelText: label),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              key: const Key('menu_prompt_save'),
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maydon bo\'sh bo\'lishi mumkin emas'),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(value);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final value = await _promptText(
      title: "Kategoriya qo'shish",
      label: 'Yangi kategoriya nomi',
      confirmText: 'Qo‘shish',
    );
    if (value != null) {
      widget.onAddCategory(value);
    }
  }

  Future<void> _showRenameCategoryDialog(String category) async {
    final value = await _promptText(
      title: 'Kategoriyani tahrirlash',
      label: 'Kategoriya nomi',
      initialValue: category,
    );
    if (value != null) {
      widget.onRenameCategory(category, value);
      setState(() {
        if (_expandedCategories.remove(category)) {
          _expandedCategories.add(value);
        }
      });
    }
  }

  Future<void> _showAddItemDialog({String? category}) async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: category ?? '');
    final priceController = TextEditingController();

    final createdItem = await showDialog<MenuItemData>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Yangi taom qo'shish"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('menu_add_name'),
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Taom nomi'),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('menu_add_category'),
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Kategoriya'),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('menu_add_price'),
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Narx'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              key: const Key('menu_add_save'),
              onPressed: () {
                final name = nameController.text.trim();
                final categoryValue = categoryController.text.trim();
                final price = int.tryParse(priceController.text.trim());
                if (name.isEmpty || categoryValue.isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Nomi, kategoriya va narxni to'g'ri kiriting",
                      ),
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(
                  MenuItemData(
                    id: _nextMenuId(),
                    name: name,
                    category: categoryValue,
                    description: "$name haqida qisqacha ta'rif",
                    price: price,
                    icon: _iconForCategory(categoryValue),
                    color: _colorForCategory(categoryValue),
                  ),
                );
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );

    if (createdItem != null) {
      widget.onAddItem(createdItem);
    }
  }

  void _saveItem(MenuItemData item) {
    final controller = _controllers[item.id];
    if (controller == null) {
      return;
    }
    final name = controller.name.text.trim();
    final category = controller.category.text.trim();
    final price = int.tryParse(controller.price.text.trim());
    if (name.isEmpty || category.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nomi, kategoriya va narxni to'g'ri kiriting"),
        ),
      );
      return;
    }

    widget.onUpdateItem(
      item.id,
      item.copyWith(
        name: name,
        category: category,
        price: price,
        icon: _iconForCategory(category),
        color: _colorForCategory(category),
      ),
    );
  }

  Widget _buildItemCard(MenuItemData item) {
    final controller = _controllers[item.id];
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _FoodIconCard(icon: item.icon, color: item.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${item.id}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Hozirgi narx: ${item.price} so\'m',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onDeleteItem(item.id),
                    child: const Text("O'chirish"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: Key('menu_name_${item.id}'),
                controller: controller.name,
                decoration: const InputDecoration(labelText: 'Taom nomi'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: Key('menu_category_${item.id}'),
                controller: controller.category,
                decoration: const InputDecoration(labelText: 'Kategoriya'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: Key('menu_price_${item.id}'),
                controller: controller.price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Narx'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: Key('menu_save_${item.id}'),
                  onPressed: () => _saveItem(item),
                  child: const Text('Saqlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _orderedCategories();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _HeroCard(
          title: 'Menyu boshqaruvi',
          subtitle: 'Direktor uchun tahrir',
          description:
              "Kategoriya va taomlar bu yerda boshqariladi. Kategoriya ustiga bosilganda ichidagi taomlar ochiladi.",
          color: Color(0xFF5B3A29),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Kategoriyalar: ${categories.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            FilledButton.icon(
              key: const Key('menu_add_category_button'),
              onPressed: _showAddCategoryDialog,
              icon: const Icon(Icons.playlist_add),
              label: const Text("Kategoriya qo'shish"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const Key('menu_add_button'),
            onPressed: () => _showAddItemDialog(),
            icon: const Icon(Icons.add),
            label: const Text("Taom qo'shish"),
          ),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) {
          final itemsInCategory = widget.menu
              .where((item) => item.category == category)
              .toList();
          final expanded = _expandedCategories.contains(category);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      key: Key('menu_category_$category'),
                      onTap: () {
                        setState(() {
                          if (expanded) {
                            _expandedCategories.remove(category);
                          } else {
                            _expandedCategories.add(category);
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  '${itemsInCategory.length} taom',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                _showRenameCategoryDialog(category),
                            child: const Text('Tahrirlash'),
                          ),
                          TextButton(
                            onPressed: () => widget.onDeleteCategory(category),
                            child: const Text("O'chirish"),
                          ),
                        ],
                      ),
                    ),
                    if (expanded) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              _showAddItemDialog(category: category),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            "Ushbu kategoriya uchun taom qo'shish",
                          ),
                        ),
                      ),
                      if (itemsInCategory.isEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Hozircha bu kategoriyada taom yo‘q',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else ...[
                        for (final item in itemsInCategory)
                          _buildItemCard(item),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _DirectorDashboardScreen extends StatelessWidget {
  const _DirectorDashboardScreen({
    required this.director,
    required this.tables,
    required this.tableAssignments,
  });

  final WaiterProfile director;
  final List<TableInfo> tables;
  final Map<int, Set<String>> tableAssignments;

  @override
  Widget build(BuildContext context) {
    final activeTables = tableAssignments.entries
        .where((entry) => entry.value.isNotEmpty)
        .length;
    final activeWaiters = tableAssignments.values
        .expand((set) => set)
        .toSet()
        .length;
    final freeTables = tables.where((table) {
      final assigned = tableAssignments[table.id];
      return (assigned == null || assigned.isEmpty) && !table.isBusy;
    }).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeroCard(
          title: 'Direktor paneli',
          subtitle: '${director.name} | ${director.position}',
          description:
              "Restorandagi joriy stol holati va xizmat ko'rsatayotgan ofitsantlar nazorati.",
          color: const Color(0xFF263238),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Faol stollar',
                value: '$activeTables',
                accent: const Color(0xFFB26A3C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Faol ofitsantlar',
                value: '$activeWaiters',
                accent: const Color(0xFF2B7A4B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: "Bo'sh stollar",
                value: '$freeTables',
                accent: const Color(0xFF1E88A8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Jami stol',
                value: '${tables.length}',
                accent: const Color(0xFF7A4E9C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Stollar bo'yicha nazorat",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final columns = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 620
                ? 2
                : 1;
            final cardWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: tables.map((table) {
                final assigned = tableAssignments[table.id] ?? <String>{};
                return SizedBox(
                  width: cardWidth,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stol ${table.id}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text('${table.seats} kishilik | ${table.location}'),
                          const SizedBox(height: 8),
                          Text(
                            assigned.isNotEmpty
                                ? "Xizmat ko'rsatilmoqda"
                                : table.isBusy
                                ? 'Band'
                                : "Bo'sh",
                            style: TextStyle(
                              color: assigned.isNotEmpty
                                  ? const Color(0xFF9C3C24)
                                  : table.isBusy
                                  ? const Color(0xFFB26A3C)
                                  : const Color(0xFF2B7A4B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (assigned.isEmpty)
                            Text(
                              "Hozircha xizmat ko'rsatayotgan ofitsant yo'q",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: assigned.map((login) {
                                final profile = waiterAccounts[login]!.profile;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _AvatarBadge(login: login),
                                    const SizedBox(width: 8),
                                    Text(profile.name),
                                  ],
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _DirectorWaitersScreen extends StatelessWidget {
  const _DirectorWaitersScreen({
    required this.tableAssignments,
    required this.orders,
    required this.onRejectOrder,
  });

  final Map<int, Set<String>> tableAssignments;
  final List<OrderRecord> orders;
  final ValueChanged<int> onRejectOrder;

  @override
  Widget build(BuildContext context) {
    final waiterLogins = waiterAccounts.entries
        .where((entry) => entry.value.role == UserRole.waiter)
        .map((entry) => entry.key)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _HeroCard(
          title: "Ofitsantlar bo'limi",
          subtitle: 'Barcha ofitsantlar',
          description:
              "Har bir ofitsantga biriktirilgan stollar, bugungi buyurtmalar va rad etilgan buyurtmalar shu yerda ko'rinadi.",
          color: Color(0xFF234A57),
        ),
        const SizedBox(height: 16),
        ...waiterLogins.map((login) {
          final profile = waiterAccounts[login]!.profile;
          final tables =
              tableAssignments.entries
                  .where((entry) => entry.value.contains(login))
                  .map((entry) => entry.key)
                  .toList()
                ..sort();
          final waiterOrders = orders
              .where((order) => order.waiterLogin == login)
              .toList();
          final activeCount = waiterOrders
              .where((order) => order.status == OrderStatus.active)
              .length;
          final rejectedCount = waiterOrders
              .where((order) => order.status == OrderStatus.rejected)
              .length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              key: Key('waiter_card_$login'),
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => _WaiterOrdersDialog(
                    login: login,
                    profile: profile,
                    tables: tables,
                    ordersProvider: () => orders
                        .where((order) => order.waiterLogin == login)
                        .toList(),
                    onRejectOrder: onRejectOrder,
                  ),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AvatarBadge(login: login, radius: 34),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              login,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              tables.isEmpty
                                  ? "Hozir stol biriktirilmagan"
                                  : "Qarayotgan stollar: ${tables.map((e) => '#$e').join(', ')}",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Bugungi buyurtmalar: $activeCount',
                              style: const TextStyle(
                                color: Color(0xFF2B7A4B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rad etilganlar: $rejectedCount',
                              style: const TextStyle(
                                color: Color(0xFF9C3C24),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _WaiterOrdersDialog extends StatelessWidget {
  const _WaiterOrdersDialog({
    required this.login,
    required this.profile,
    required this.tables,
    required this.ordersProvider,
    required this.onRejectOrder,
  });

  final String login;
  final WaiterProfile profile;
  final List<int> tables;
  final List<OrderRecord> Function() ordersProvider;
  final ValueChanged<int> onRejectOrder;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          _AvatarBadge(login: login, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(profile.name),
                Text(login, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            final orders = ordersProvider();
            final activeOrders = orders
                .where((order) => order.status == OrderStatus.active)
                .toList();
            final rejectedOrders = orders
                .where((order) => order.status == OrderStatus.rejected)
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tables.isEmpty
                        ? "Biriktirilgan stol yo'q"
                        : "Qarayotgan stollari: ${tables.map((e) => '#$e').join(', ')}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bugungi olingan buyurtmalar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (activeOrders.isEmpty)
                    Text(
                      "Bugun faol buyurtma yo'q",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...activeOrders.map(
                      (order) => _OrderHistoryCard(
                        order: order,
                        onReject: () {
                          onRejectOrder(order.id);
                          setDialogState(() {});
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Rad etilgan buyurtmalar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (rejectedOrders.isEmpty)
                    Text(
                      "Rad etilgan buyurtma yo'q",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...rejectedOrders.map(
                      (order) => _OrderHistoryCard(order: order),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Yopish'),
        ),
      ],
    );
  }
}

class _DirectorReportsScreen extends StatelessWidget {
  const _DirectorReportsScreen({required this.director, required this.report});

  final WaiterProfile director;
  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final dailyTotal = report.dailyCash + report.dailyCard;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeroCard(
          title: "Hisobotlar bo'limi",
          subtitle: '${director.name} | ${director.position}',
          description:
              "Kunlik, haftalik va oylik savdo ko'rsatkichlari shu yerda jamlangan.",
          color: const Color(0xFF1F3A5F),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Kunlik jami',
                value: '${dailyTotal ~/ 1000}k so\'m',
                accent: const Color(0xFF2B7A4B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Buyurtmalar',
                value: '${report.dailyOrders}',
                accent: const Color(0xFFB26A3C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Naqd',
                value: '${report.dailyCash ~/ 1000}k',
                accent: const Color(0xFF1E88A8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Karta',
                value: '${report.dailyCard ~/ 1000}k',
                accent: const Color(0xFF7A4E9C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "Eng ko'p sotilgan mahsulotlar",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...report.topProducts.map(
          (product) => Card(
            child: ListTile(
              title: Text(product.productName),
              subtitle: Text('${product.quantity} dona sotilgan'),
              trailing: Text('${product.revenue ~/ 1000}k so\'m'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _InsightCard(
          title: 'Kunlik analiz',
          value: '${dailyTotal ~/ 1000}k so\'m',
          subtitle: report.dailyTrend,
        ),
        const SizedBox(height: 12),
        _InsightCard(
          title: 'Haftalik analiz',
          value:
              '${report.weeklyRevenue ~/ 1000}k so\'m | +${report.weeklyGrowthPercent}%',
          subtitle: report.weeklyTrend,
        ),
        const SizedBox(height: 12),
        _InsightCard(
          title: 'Oylik analiz',
          value:
              '${report.monthlyRevenue ~/ 1000}k so\'m | +${report.monthlyGrowthPercent}%',
          subtitle: report.monthlyTrend,
        ),
      ],
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen({
    required this.login,
    required this.profile,
    required this.onLogout,
  });

  final String login;
  final WaiterProfile profile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _AvatarBadge(login: login, radius: 56),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  login,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.position,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('logout_button'),
                    onPressed: onLogout,
                    child: const Text("Akkauntdan chiqish"),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _ProfileInfoCard(label: 'Telefon', value: profile.phone),
        _ProfileInfoCard(label: 'Smena', value: profile.shift),
        _ProfileInfoCard(label: 'Tajriba', value: profile.experience),
        const _ProfileInfoCard(
          label: 'Filial',
          value: "Andijan Restoran, Bobur shoh ko'chasi",
        ),
      ],
    );
  }
}

class _WaiterBottomBar extends StatelessWidget {
  const _WaiterBottomBar({
    required this.currentSection,
    required this.onSelect,
  });

  final WaiterSection currentSection;
  final ValueChanged<WaiterSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return _BottomBar(
      items: [
        _BottomBarItem(
          label: 'Buyurtmalar',
          selected: currentSection == WaiterSection.orders,
          onTap: () => onSelect(WaiterSection.orders),
        ),
        _BottomBarItem(
          label: 'Profil',
          selected: currentSection == WaiterSection.profile,
          onTap: () => onSelect(WaiterSection.profile),
        ),
      ],
    );
  }
}

class _DirectorBottomBar extends StatelessWidget {
  const _DirectorBottomBar({
    required this.currentSection,
    required this.onSelect,
  });

  final DirectorSection currentSection;
  final ValueChanged<DirectorSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return _BottomBar(
      items: [
        _BottomBarItem(
          label: 'Nazorat',
          selected: currentSection == DirectorSection.dashboard,
          onTap: () => onSelect(DirectorSection.dashboard),
        ),
        _BottomBarItem(
          label: 'Ofitsantlar',
          selected: currentSection == DirectorSection.waiters,
          onTap: () => onSelect(DirectorSection.waiters),
        ),
        _BottomBarItem(
          label: 'Menyu',
          selected: currentSection == DirectorSection.menu,
          onTap: () => onSelect(DirectorSection.menu),
        ),
        _BottomBarItem(
          label: 'Hisobotlar',
          selected: currentSection == DirectorSection.reports,
          onTap: () => onSelect(DirectorSection.reports),
        ),
        _BottomBarItem(
          label: 'Profil',
          selected: currentSection == DirectorSection.profile,
          onTap: () => onSelect(DirectorSection.profile),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.items});

  final List<_BottomBarItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: item.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: item.selected
                              ? const Color(0xFF8A4B2A)
                              : const Color(0xFFF2E7DC),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: item.selected
                                ? Colors.white
                                : const Color(0xFF4B2D1F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _BottomBarItem {
  const _BottomBarItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Color(0xFFD8EDF2))),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Color(0xFFD8EDF2))),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: SizedBox(
          width: 180,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.login, this.radius = 18});

  final String login;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final profile = waiterAccounts[login]?.profile;
    final name = profile?.name ?? login;
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: _avatarColor(login),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.65,
        ),
      ),
    );
  }
}

class _FoodIconCard extends StatelessWidget {
  const _FoodIconCard({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, size: 34, color: const Color(0xFF5A3826)),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order, this.onReject});

  final OrderRecord order;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final isActive = order.status == OrderStatus.active;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _FoodIconCard(icon: order.icon, color: order.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.itemName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('Miqdor: ${order.quantity} dona'),
                      Text(
                        'Stol #${order.tableId}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive ? 'Faol buyurtma' : 'Rad etilgan',
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF2B7A4B)
                              : const Color(0xFF9C3C24),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isActive && onReject != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onReject,
                  child: const Text('Rad etish'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Color _avatarColor(String login) {
  const palette = <Color>[
    Color(0xFF8A4B2A),
    Color(0xFF42634C),
    Color(0xFF1F3A5F),
    Color(0xFF7A4E9C),
    Color(0xFF1E88A8),
  ];
  return palette[login.codeUnits.fold<int>(0, (sum, value) => sum + value) %
      palette.length];
}

String waiterNameByLogin(String login) {
  return waiterAccounts[login]?.profile.name ?? login;
}
