part of 'package:andijan_flutter/app.dart';

class _TableSelectionScreen extends StatelessWidget {
  const _TableSelectionScreen({
    required this.waiter,
    required this.currentLogin,
    required this.tables,
    required this.onSelectTable,
    required this.onJoinTable,
  });

  final WaiterProfile waiter;
  final String currentLogin;
  final List<TableInfo> tables;
  final ValueChanged<int> onSelectTable;
  final ValueChanged<int> onJoinTable;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeroCard(
          title: 'Buyurtma berish',
          subtitle: '${waiter.name} | ${waiter.position}',
          description: "Avval stol raqamini tanlang. Stol tanlangandan keyin menyu ochiladi.",
          color: const Color(0xFF8A4B2A),
        ),
        const SizedBox(height: 16),
        Text('Stol raqamini tanlang', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 1.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                final assigned = table.assignedWaiters;
                final statusColor = assigned.isNotEmpty
                    ? const Color(0xFF9C3C24)
                    : (table.status != 'free' ? const Color(0xFFB26A3C) : const Color(0xFF2B7A4B));

                return InkWell(
                  key: Key('table_card_${table.id}'),
                  onTap: () => onSelectTable(table.id),
                  child: Card(
                    color: table.status != 'free' ? const Color(0xFFE7D9D2) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stol #${table.number ?? table.id}', style: Theme.of(context).textTheme.titleLarge),
                          Text('${table.seats} kishilik | ${table.location}', style: Theme.of(context).textTheme.bodySmall),
                          const Spacer(),
                          Text(
                            assigned.isNotEmpty ? "Xizmat ko'rsatilmoqda" : (table.status != 'free' ? 'Band' : "Bo'sh"),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                          ),
                          if (assigned.isNotEmpty)
                            Text(
                              assigned.map((w) => w['full_name']).join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
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

class _MenuOrderScreen extends StatefulWidget {
  const _MenuOrderScreen({
    required this.tableId,
    required this.menu,
    required this.categories,
    required this.quantitiesByItemId,
    required this.notesByItemId,
    required this.isSubmitting,
    required this.selectedBillNumber,
    required this.onBillNumberChanged,
    required this.onBack,
    required this.onQuantityChanged,
    required this.onNoteChanged,
    required this.onSubmit,
  });

  final int tableId;
  final List<MenuItemData> menu;
  final List<MenuCategory> categories;
  final Map<int, int> quantitiesByItemId;
  final Map<int, String> notesByItemId;
  final bool isSubmitting;
  final int selectedBillNumber;
  final ValueChanged<int> onBillNumberChanged;
  final VoidCallback onBack;
  final void Function(int itemId, int delta) onQuantityChanged;
  final void Function(int itemId, String note) onNoteChanged;
  final VoidCallback onSubmit;

  @override
  State<_MenuOrderScreen> createState() => _MenuOrderScreenState();
}

class _MenuOrderScreenState extends State<_MenuOrderScreen> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final grouped = <int, List<MenuItemData>>{};
    for (final item in widget.menu) {
      if (item.categoryId != null) {
        grouped.putIfAbsent(item.categoryId!, () => []).add(item);
      }
    }

    final totalItems = widget.menu.fold<int>(0, (sum, item) => sum + (widget.quantitiesByItemId[item.id] ?? 0));
    final totalPrice = widget.menu.fold<int>(0, (sum, item) => sum + (item.price * (widget.quantitiesByItemId[item.id] ?? 0)));

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
                    Text('Stol #${widget.tableId} buyurtmasi', style: Theme.of(context).textTheme.headlineSmall),
                    Text("Taomlarni tanlang | Shot #${widget.selectedBillNumber}"),
                  ],
                ),
              ),
              TextButton(onPressed: widget.onBack, child: const Text('Stollar')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Shotni tanlang (1-10):", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final billNum = index + 1;
                    final isSelected = widget.selectedBillNumber == billNum;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$billNum-shot'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) widget.onBillNumberChanged(billNum);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: widget.categories.map((cat) {
              final selected = _selectedCategoryId == cat.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat.name),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategoryId = selected ? null : cat.id),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: widget.categories
                .where((cat) => _selectedCategoryId == null || _selectedCategoryId == cat.id)
                .expand((cat) {
              final items = grouped[cat.id] ?? [];
              return [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(cat.name, style: Theme.of(context).textTheme.titleLarge),
                ),
                if (items.isEmpty) const Text("Bu kategoriyada taom yo'q")
                else ...items.map((item) {
                  final int qty = widget.quantitiesByItemId[item.id] ?? 0;
                  final int? remaining = item.remainingToday;
                  // remaining == null => cheksiz (sig'im belgilanmagan)
                  final bool soldOut =
                      !item.isAvailable || (remaining != null && remaining <= 0);
                  final bool atLimit =
                      remaining != null && remaining > 0 && qty >= remaining;
                  return Card(
                  child: Opacity(
                    opacity: soldOut ? 0.55 : 1,
                    child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _FoodIconCard(icon: item.icon, color: item.color),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                                  Text("${item.price} so'm", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                                  if (remaining != null) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: soldOut
                                            ? Colors.red.withValues(alpha: 0.15)
                                            : Colors.green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        soldOut ? 'Tugadi' : 'Bugun: $remaining porsiya',
                                        style: TextStyle(
                                          color: soldOut ? Colors.red : Colors.green.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(onPressed: soldOut ? null : () => widget.onQuantityChanged(item.id, -1), icon: const Icon(Icons.remove_circle_outline)),
                            Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              key: Key('increase_item_${item.id}'),
                              onPressed: (soldOut || atLimit) ? null : () => widget.onQuantityChanged(item.id, 1),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            const Spacer(),
                            if (qty > 0)
                              Expanded(
                                child: TextField(
                                  key: Key('note_item_${item.id}'),
                                  decoration: const InputDecoration(hintText: 'Izoh...', isDense: true),
                                  onChanged: (val) => widget.onNoteChanged(item.id, val),
                                ),
                              ),
                          ],
                        ),
                        if (atLimit)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                'Bugungi limit tugadi',
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ),
                );
                }),
              ];
            }).toList(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Color(0xFF2E221C), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jami:', style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('$totalPrice so\'m', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('submit_order'),
                  onPressed: totalItems > 0 && !widget.isSubmitting ? widget.onSubmit : null,
                  child: Text(widget.isSubmitting ? 'Yuborilmoqda...' : 'Buyurtmani yuborish'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveOrdersScreen extends StatelessWidget {
  const _ActiveOrdersScreen({
    required this.orders,
    required this.currentLogin,
  });

  final List<OrderRecord> orders;
  final String currentLogin;

  @override
  Widget build(BuildContext context) {
    final myOrders = orders.where((o) => o.waiterLogin == currentLogin).toList();
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeroCard(
          title: 'Faol buyurtmalar',
          subtitle: 'Sizning joriy buyurtmalaringiz',
          description: "Bu yerda siz o'zingizga biriktirilgan stollardagi buyurtmalar holatini ko'rishingiz mumkin.",
          color: const Color(0xFF2B7A4B),
        ),
        const SizedBox(height: 16),
        if (myOrders.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text("Hozircha faol buyurtmalar yo'q"),
          ))
        else
          ...myOrders.map((order) => _OrderHistoryCard(order: order)),
      ],
    );
  }
}
