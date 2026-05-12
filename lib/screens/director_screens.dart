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
  final List<MenuCategory> categories;
  final void Function(int itemId, Map<String, dynamic> data) onUpdateItem;
  final ValueChanged<Map<String, dynamic>> onAddItem;
  final ValueChanged<int> onDeleteItem;
  final void Function(String name, int sortOrder) onAddCategory;
  final void Function(int id, String name, int sortOrder) onRenameCategory;
  final ValueChanged<int> onDeleteCategory;

  @override
  State<_DirectorMenuScreen> createState() => _DirectorMenuScreenState();
}

class _DirectorMenuScreenState extends State<_DirectorMenuScreen> {
  final Map<int, _MenuEditorControllers> _controllers =
      <int, _MenuEditorControllers>{};
  final Set<int> _expandedCategories = <int>{};

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

  Future<Map<String, dynamic>?> _promptCategory({
    required String title,
    String? initialName,
    int? initialSortOrder,
  }) async {
    final nameController = TextEditingController(text: initialName ?? '');
    final sortController = TextEditingController(text: (initialSortOrder ?? 0).toString());
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Kategoriya nomi'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sortController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tartib raqami'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Bekor qilish'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final sort = int.tryParse(sortController.text.trim()) ?? 0;
                if (name.isEmpty) return;
                Navigator.of(dialogContext).pop({'name': name, 'sort_order': sort});
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final result = await _promptCategory(title: "Kategoriya qo'shish");
    if (result != null) {
      widget.onAddCategory(result['name'], result['sort_order']);
    }
  }

  Future<void> _showRenameCategoryDialog(MenuCategory category) async {
    final result = await _promptCategory(
      title: 'Kategoriyani tahrirlash',
      initialName: category.name,
      initialSortOrder: category.sortOrder,
    );
    if (result != null) {
      widget.onRenameCategory(category.id, result['name'], result['sort_order']);
    }
  }

  Future<void> _showAddItemDialog({int? categoryId}) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    int? selectedCatId = categoryId ?? (widget.categories.isNotEmpty ? widget.categories.first.id : null);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Yangi taom qo'shish"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Taom nomi'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedCatId,
                    decoration: const InputDecoration(labelText: 'Kategoriya'),
                    items: widget.categories.map((cat) {
                      return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedCatId = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
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
                onPressed: () {
                  final name = nameController.text.trim();
                  final price = int.tryParse(priceController.text.trim());
                  if (name.isEmpty || price == null || selectedCatId == null) return;
                  Navigator.of(dialogContext).pop({
                    'name': name,
                    'category_id': selectedCatId,
                    'price': price,
                    'description': name,
                  });
                },
                child: const Text('Saqlash'),
              ),
            ],
          );
        });
      },
    );

    if (result != null) {
      widget.onAddItem(result);
    }
  }

  void _saveItem(MenuItemData item) {
    final controller = _controllers[item.id];
    if (controller == null) return;
    
    final name = controller.name.text.trim();
    final price = int.tryParse(controller.price.text.trim());
    
    if (name.isEmpty || price == null) return;

    widget.onUpdateItem(item.id, {
      'name': name,
      'price': price,
    });
  }

  Widget _buildItemCard(MenuItemData item) {
    final controller = _controllers[item.id];
    if (controller == null) return const SizedBox.shrink();

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
                        Text('ID: ${item.id}', style: Theme.of(context).textTheme.bodySmall),
                        Text('${item.price} so\'m', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.onDeleteItem(item.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.name,
                decoration: const InputDecoration(labelText: 'Taom nomi'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Narx'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _HeroCard(
          title: 'Menyu boshqaruvi',
          subtitle: 'Direktor uchun tahrir',
          description: "Kategoriya va taomlar bu yerda boshqariladi.",
          color: Color(0xFF5B3A29),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'Kategoriyalar: ${widget.categories.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            FilledButton.icon(
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
            onPressed: () => _showAddItemDialog(),
            icon: const Icon(Icons.add),
            label: const Text("Taom qo'shish"),
          ),
        ),
        const SizedBox(height: 16),
        ...widget.categories.map((category) {
          final itemsInCategory = widget.menu
              .where((item) => item.categoryId == category.id)
              .toList();
          final expanded = _expandedCategories.contains(category.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (expanded) {
                            _expandedCategories.remove(category.id);
                          } else {
                            _expandedCategories.add(category.id);
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(category.name, style: Theme.of(context).textTheme.titleLarge),
                                Text('${itemsInCategory.length} taom'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showRenameCategoryDialog(category),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            onPressed: () => widget.onDeleteCategory(category.id),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    if (expanded) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _showAddItemDialog(categoryId: category.id),
                          icon: const Icon(Icons.add),
                          label: const Text("Ushbu kategoriya uchun taom qo'shish"),
                        ),
                      ),
                      if (itemsInCategory.isEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Hozircha bu kategoriyada taom yo‘q'),
                      ] else ...[
                        for (final item in itemsInCategory) _buildItemCard(item),
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
    required this.summary,
    required this.tables,
  });

  final WaiterProfile director;
  final DashboardSummary summary;
  final List<TableInfo> tables;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeroCard(
          title: 'Direktor paneli',
          subtitle: '${director.name} | ${director.position}',
          description: "Restorandagi joriy holat va statistika.",
          color: const Color(0xFF263238),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Faol buyurtmalar',
                value: '${summary.activeOrders}',
                accent: const Color(0xFFB26A3C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Faol ofitsantlar',
                value: '${summary.activeWaiters}',
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
                title: 'Naqd (bugun)',
                value: '${summary.cashToday ~/ 1000}k',
                accent: const Color(0xFF1E88A8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Karta (bugun)',
                value: '${summary.cardToday ~/ 1000}k',
                accent: const Color(0xFF7A4E9C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text("Stollar holati", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                final isBusy = table.status != 'free';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stol #${table.number ?? table.id}', style: Theme.of(context).textTheme.titleMedium),
                        Text('${table.seats} kishi | ${table.location}'),
                        const Spacer(),
                        Text(
                          isBusy ? 'Band' : 'Bo\'sh',
                          style: TextStyle(
                            color: isBusy ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _DirectorWaitersScreen extends StatelessWidget {
  const _DirectorWaitersScreen({
    required this.waiters,
    required this.onRejectOrder,
    required this.onCreateWaiter,
    required this.onUpdateWaiter,
    required this.onDeleteWaiter,
    required this.orders,
  });

  final List<WaiterInfo> waiters;
  final ValueChanged<int> onRejectOrder;
  final ValueChanged<Map<String, dynamic>> onCreateWaiter;
  final void Function(int id, Map<String, dynamic> data) onUpdateWaiter;
  final ValueChanged<int> onDeleteWaiter;
  final List<OrderRecord> orders;

  Future<void> _showWaiterDialog(BuildContext context, {WaiterInfo? waiter}) async {
    final nameController = TextEditingController(text: waiter?.fullName ?? '');
    final userController = TextEditingController(text: waiter?.username ?? '');
    final passController = TextEditingController();
    final phoneController = TextEditingController(text: waiter?.phone ?? '');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(waiter == null ? "Yangi ofitsant" : "Ofitsantni tahrirlash"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'F.I.SH')),
            if (waiter == null) TextField(controller: userController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: passController, decoration: const InputDecoration(labelText: 'Parol'), obscureText: true),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefon')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor qilish')),
          FilledButton(
            onPressed: () {
              final data = {
                'full_name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
              };
              if (passController.text.isNotEmpty) data['password'] = passController.text;
              if (waiter == null) data['username'] = userController.text.trim();
              Navigator.pop(ctx, data);
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (waiter == null) {
        onCreateWaiter(result);
      } else {
        onUpdateWaiter(waiter.id, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Expanded(
              child: _HeroCard(
                title: "Ofitsantlar",
                subtitle: 'Xodimlar boshqaruvi',
                description: "Ofitsantlarni qo'shish va tahrirlash.",
                color: Color(0xFF234A57),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _showWaiterDialog(context),
          icon: const Icon(Icons.person_add_alt),
          label: const Text("Yangi ofitsant qo'shish"),
        ),
        const SizedBox(height: 16),
        ...waiters.map((waiter) {
          return Card(
            child: ListTile(
              leading: _AvatarBadge(name: waiter.fullName, login: waiter.username),
              title: Text(waiter.fullName),
              subtitle: Text('${waiter.username} | ${waiter.phone}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => _showWaiterDialog(context, waiter: waiter), icon: const Icon(Icons.edit_outlined)),
                  IconButton(onPressed: () => onDeleteWaiter(waiter.id), icon: const Icon(Icons.delete_outline, color: Colors.red)),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => _WaiterOrdersDialog(
                    waiter: waiter,
                    orders: orders.where((o) => o.waiterLogin == waiter.username).toList(),
                    onRejectOrder: onRejectOrder,
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class _WaiterOrdersDialog extends StatelessWidget {
  const _WaiterOrdersDialog({
    required this.waiter,
    required this.orders,
    required this.onRejectOrder,
  });

  final WaiterInfo waiter;
  final List<OrderRecord> orders;
  final ValueChanged<int> onRejectOrder;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          _AvatarBadge(name: waiter.fullName, login: waiter.username, radius: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(waiter.fullName)),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (orders.isEmpty) const Text("Buyurtmalar yo'q")
              else ...orders.map((o) => _OrderHistoryCard(order: o, onReject: () => onRejectOrder(o.id))),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Yopish'))],
    );
  }
}

class _DirectorReportsScreen extends StatefulWidget {
  const _DirectorReportsScreen({required this.onFetchRevenue, required this.onFetchWaiters});

  final Future<RevenueReport> Function(String period) onFetchRevenue;
  final Future<List<WaiterReportItem>> Function(String period) onFetchWaiters;

  @override
  State<_DirectorReportsScreen> createState() => _DirectorReportsScreenState();
}

class _DirectorReportsScreenState extends State<_DirectorReportsScreen> {
  String _period = 'daily';
  RevenueReport? _revenue;
  List<WaiterReportItem>? _waiters;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rev = await widget.onFetchRevenue(_period);
      final wai = await widget.onFetchWaiters(_period);
      setState(() {
        _revenue = rev;
        _waiters = wai;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_revenue == null) return const Center(child: Text("Ma'lumot yuklanmadi"));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _period,
          decoration: const InputDecoration(labelText: 'Davr'),
          items: const [
            DropdownMenuItem(value: 'daily', child: Text('Bugun')),
            DropdownMenuItem(value: 'weekly', child: Text('Shu hafta')),
            DropdownMenuItem(value: 'monthly', child: Text('Shu oy')),
          ],
          onChanged: (val) {
            if (val != null) {
              _period = val;
              _load();
            }
          },
        ),
        const SizedBox(height: 16),
        _MetricCard(title: 'Jami tushum', value: '${_revenue!.grandTotal ~/ 1000}k', accent: Colors.green),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MetricCard(title: 'Naqd', value: '${_revenue!.cashTotal ~/ 1000}k', accent: Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(title: 'Karta', value: '${_revenue!.cardTotal ~/ 1000}k', accent: Colors.orange)),
          ],
        ),
        const SizedBox(height: 24),
        Text("Xodimlar bo'yicha", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (_waiters != null)
          ..._waiters!.map((w) => Card(
            child: ListTile(
              title: Text(w.fullName),
              subtitle: Text('Sotildi: ${w.soldOrders} | Rad: ${w.rejectedOrders}'),
              trailing: Text('${w.revenue ~/ 1000}k'),
            ),
          )),
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
                _AvatarBadge(name: profile.name, login: login, radius: 56),
                const SizedBox(height: 12),
                Text(profile.name, style: Theme.of(context).textTheme.headlineSmall),
                Text(login, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Text(profile.position, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
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
      ],
    );
  }
}
