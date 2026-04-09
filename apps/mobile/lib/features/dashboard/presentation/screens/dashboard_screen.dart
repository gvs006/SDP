import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_bottom_nav.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final dateStr =
        '${_weekday(now.weekday)}, ${now.day} de ${_month(now.month)} de ${now.year}';

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header with gradient ──
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/brand/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Text('🍦', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Sabor do Parque',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F1F15),
                      AppTheme.primaryGreen,
                      Color(0xFF2A5A3B),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Gold glow orb (top-right)
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.accentGold.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh_rounded,
                    color: AppTheme.accentGold.withValues(alpha: 0.8)),
                onPressed: () => ref.invalidate(dashboardStatsProvider),
              ),
            ],
          ),

          // ── Content ──
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(
              children: [
                // KPI Cards
                statsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  error: (err, _) => _ErrorCard(
                    message: 'Erro ao carregar dashboard',
                    detail: err.toString(),
                    onRetry: () => ref.invalidate(dashboardStatsProvider),
                  ),
                  data: (stats) => Column(
                    children: [
                      // Row 1
                      Row(
                        children: [
                          Expanded(
                            child: _KpiCard(
                              icon: Icons.attach_money_rounded,
                              label: 'FATURAMENTO HOJE',
                              value: _brl(stats.faturamentoHoje),
                              subtitle: '${stats.vendasHoje} vendas',
                              accentColor: AppTheme.statusBlue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _KpiCard(
                              icon: Icons.trending_up_rounded,
                              label: 'LUCRO HOJE',
                              value: _brl(stats.lucroHoje),
                              subtitle: 'margem líquida',
                              accentColor: AppTheme.statusGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Row 2
                      Row(
                        children: [
                          Expanded(
                            child: _KpiCard(
                              icon: Icons.inventory_2_rounded,
                              label: 'ESTOQUE TOTAL',
                              value: '${stats.estoqueTotal}',
                              subtitle: '${stats.estoqueBaixo} com baixo estoque',
                              accentColor: stats.estoqueBaixo > 0
                                  ? AppTheme.statusAmber
                                  : AppTheme.tertiaryContainer,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _KpiCard(
                              icon: Icons.icecream_rounded,
                              label: 'SABORES',
                              value: '${stats.totalFlavors}',
                              subtitle: 'no cardápio',
                              accentColor: AppTheme.accentGoldDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Actions title
                Text(
                  'ACESSO RÁPIDO',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.icecream_outlined,
                        label: 'Cardápio',
                        color: AppTheme.accentGoldDark,
                        onTap: () => context.go('/catalog'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.people_outline_rounded,
                        label: 'Clientes',
                        color: AppTheme.primaryGreen,
                        onTap: () => context.go('/customers'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.point_of_sale_rounded,
                        label: 'PDV',
                        color: AppTheme.statusGreen,
                        onTap: () => context.go('/pos'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.inventory_2_outlined,
                        label: 'Estoque',
                        color: AppTheme.tertiaryBronze,
                        onTap: () => context.go('/inventory'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SharedBottomNav(selectedIndex: 0),
    );
  }

  String _brl(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  String _weekday(int d) => const [
        '', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
      ][d];

  String _month(int m) => const [
        '', 'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
        'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
      ][m];
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI Card — Tonal layering, no borders (Forest & Gilded)
// ─────────────────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color accentColor;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A042110),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 14),

          // Label
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Value
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.outline,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Action — Tonal backgrounds
// ─────────────────────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Card
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  final String detail;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, color: cs.error, size: 40),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(detail,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

