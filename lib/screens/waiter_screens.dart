part of 'package:andijan_flutter/app.dart';

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
    required this.notesByItemId,
    required this.isSubmitting,
    required this.onBack,
    required this.onQuantityChanged,
    required this.onNoteChanged,
    required this.onSubmit,
  });

  final int tableId;
  final List<MenuItemData> menu;
  final List<String> categories;
  final Map<int, int> quantitiesByItemId;
  final Map<int, String> notesByItemId;
  final bool isSubmitting;
  final VoidCallback onBack;
  final void Function(int itemId, int delta) onQuantityChanged;
  final void Function(int itemId, String note) onNoteChanged;
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
                                      if ((widget.quantitiesByItemId[item.id] ??
                                              0) >
                                          0) ...[
                                        const SizedBox(height: 12),
                                        TextField(
                                          key: Key('note_item_${item.id}'),
                                          controller:
                                              TextEditingController(
                                                  text:
                                                      widget.notesByItemId[item
                                                          .id] ??
                                                      '',
                                                )
                                                ..selection =
                                                    TextSelection.collapsed(
                                                      offset:
                                                          (widget.notesByItemId[item
                                                                      .id] ??
                                                                  '')
                                                              .length,
                                                    ),
                                          onChanged: (value) => widget
                                              .onNoteChanged(item.id, value),
                                          maxLines: 2,
                                          decoration: const InputDecoration(
                                            labelText: 'Izoh (ixtiyoriy)',
                                            hintText:
                                                "Masalan: piyozsiz, achchiqroq",
                                          ),
                                        ),
                                      ],
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
                  onPressed: totalItems > 0 && !widget.isSubmitting
                      ? widget.onSubmit
                      : null,
                  child: Text(
                    widget.isSubmitting
                        ? 'Yuborilmoqda...'
                        : 'Buyurtmani yuborish',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
