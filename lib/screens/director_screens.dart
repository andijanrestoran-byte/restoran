part of 'package:andijan_flutter/app.dart';

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
