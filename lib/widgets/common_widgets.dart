part of 'package:andijan_flutter/app.dart';

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
  const _AvatarBadge({required this.name, required this.login, this.radius = 18});

  final String name;
  final String login;
  final double radius;

  @override
  Widget build(BuildContext context) {
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
        initials.isEmpty ? '?' : initials,
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
                      if (order.note.isNotEmpty)
                        Text(
                          'Izoh: ${order.note}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
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

