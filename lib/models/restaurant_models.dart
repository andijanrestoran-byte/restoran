part of 'package:andijan_flutter/app.dart';

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
    required this.note,
    required this.icon,
    required this.color,
    required this.status,
  });

  final int id;
  final String waiterLogin;
  final int tableId;
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
      itemName: itemName,
      quantity: quantity,
      note: note,
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
