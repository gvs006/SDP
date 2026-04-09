import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_bottom_nav.dart';
import '../providers/catalog_providers.dart';

class CatalogListScreen extends ConsumerWidget {
  const CatalogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogListProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverAppBar.large(
            backgroundColor: cs.surface,
            foregroundColor: AppTheme.primaryGreen,
            title: Text(
              'Cardápio',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: cs.outline,
                onPressed: () => ref.invalidate(catalogListProvider),
              ),
            ],
          ),

          // ── Content ──
          catalogAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                  strokeWidth: 3,
                ),
              ),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 56, color: cs.error),
                    const SizedBox(height: 16),
                    Text('Erro ao carregar cardápio',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(err.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.outline,
                        )),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(catalogListProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
            data: (flavors) {
              final gourmet =
                  flavors.where((f) => f.linha == 'Gourmet').toList();
              final refrescante =
                  flavors.where((f) => f.linha == 'Refrescante').toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList.list(
                  children: [
                    // ── Linha Gourmet ──
                    _SectionHeader(
                      title: 'Linha Gourmet',
                      count: gourmet.length,
                      color: AppTheme.accentGoldDark,
                    ),
                    const SizedBox(height: 10),
                    ...gourmet.asMap().entries.map((e) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + e.key * 60),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: _FlavorTile(flavor: e.value, isGourmet: true),
                    )),

                    const SizedBox(height: 28),

                    // ── Linha Refrescante ──
                    _SectionHeader(
                      title: 'Linha Refrescante',
                      count: refrescante.length,
                      color: AppTheme.statusGreen,
                    ),
                    const SizedBox(height: 10),
                    ...refrescante.asMap().entries.map((e) => TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + e.key * 60),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: _FlavorTile(flavor: e.value, isGourmet: false),
                    )),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const SharedBottomNav(selectedIndex: 1),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header — gold bar accent
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 10),
        // Chip badge (Stitch pill style)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flavor Tile — Tonal layering, no borders (Forest & Gilded)
// ─────────────────────────────────────────────────────────────────────────────
class _FlavorTile extends StatelessWidget {
  final dynamic flavor;
  final bool isGourmet;

  const _FlavorTile({required this.flavor, required this.isGourmet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accentColor =
        isGourmet ? AppTheme.accentGoldDark : AppTheme.statusGreen;
    final margemColor =
        flavor.margem >= 50 ? AppTheme.statusGreen : AppTheme.statusRed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08042110),
              blurRadius: 24,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/flavors/${flavor.externalId}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  isGourmet ? Icons.icecream_rounded : Icons.local_drink_rounded,
                  color: accentColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + Cost + Margin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flavor.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Custo: R\$ ${flavor.custoUnit.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: margemColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${flavor.margem.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: margemColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price + Stock
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${flavor.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      flavor.estoque < flavor.minStock
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 14,
                      color: flavor.estoque < flavor.minStock
                          ? AppTheme.statusRed
                          : AppTheme.statusGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${flavor.estoque} und',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: flavor.estoque < flavor.minStock
                            ? AppTheme.statusRed
                            : cs.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
