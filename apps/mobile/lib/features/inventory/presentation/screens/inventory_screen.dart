import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_bottom_nav.dart';
import '../providers/inventory_providers.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final inventoryAsync = ref.watch(inventoryListProvider);
    final stats = ref.watch(inventoryStatsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: AppTheme.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Estoque',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryGreen,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            color: cs.outline,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── OVERVIEW ROW ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Total: ${stats['total']} itens',
                    color: AppTheme.primaryGreen,
                    backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 8),
                  if (stats['lowStock'] > 0)
                    _StatChip(
                      label: 'Baixo: ${stats['lowStock']} itens',
                      color: AppTheme.statusRed,
                      backgroundColor: cs.errorContainer,
                    ),
                ],
              ),
            ),
          ),

          // ── LIST OF INGREDIENTS ──
          inventoryAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                  strokeWidth: 3,
                ),
              ),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Erro: $err')),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Nenhum item no estoque.')),
                );
              }

              // Sort low stock first
              final sortedItems = [...items]
                ..sort((a, b) {
                  if (a.isLowStock && !b.isLowStock) return -1;
                  if (!a.isLowStock && b.isLowStock) return 1;
                  return a.name.compareTo(b.name);
                });

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList.builder(
                  itemCount: sortedItems.length,
                  itemBuilder: (context, index) {
                    final item = sortedItems[index];
                    return _InventoryCard(item: item);
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryDark,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Novo Item',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: const SharedBottomNav(selectedIndex: 4),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _StatChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;

  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLowStock = item.isLowStock;
    final accentColor = isLowStock ? AppTheme.statusRed : AppTheme.primaryGreen;

    IconData getIconForCat() {
      if (item.unit == 'kg') return Icons.scale_rounded;
      if (item.unit == 'L' || item.unit == 'lata') return Icons.water_drop_rounded;
      return Icons.inventory_2_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06042110),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        border: isLowStock
            ? Border.all(color: AppTheme.statusRed.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(getIconForCat(), color: accentColor, size: 24),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estoque mínimo: ${item.minimumStock} ${item.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.outline,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: item.healthPercentage,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.quantity}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isLowStock ? AppTheme.statusRed : cs.onSurface,
                ),
              ),
              Text(
                item.unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.outlineVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
