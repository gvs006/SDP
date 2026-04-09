import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_bottom_nav.dart';
import '../providers/customer_providers.dart';

class CustomersListScreen extends ConsumerWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersListProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: cs.surface,
            foregroundColor: AppTheme.primaryGreen,
            title: Text(
              'Clientes',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: cs.outline,
                onPressed: () => ref.invalidate(customersListProvider),
              ),
            ],
          ),

          customersAsync.when(
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
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded,
                          size: 56, color: cs.error),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar clientes',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(err.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.outline,
                          ),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () =>
                            ref.invalidate(customersListProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (customers) {
              if (customers.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 72, color: cs.outlineVariant),
                        const SizedBox(height: 20),
                        Text(
                          'Nenhum cliente cadastrado',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Toque no botão abaixo para adicionar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final c = customers[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 250 + index * 50),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 16 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => context.pushNamed(
                              'customer-edit',
                              pathParameters: {'id': c.id},
                            ),
                            borderRadius: BorderRadius.circular(16),
                            splashColor:
                                AppTheme.accentGold.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        AppTheme.primaryGreen,
                                    child: Text(
                                      c.name.isNotEmpty
                                          ? c.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: AppTheme.accentGold,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Name + Phone
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: cs.onSurface,
                                          ),
                                        ),
                                        if (c.phone != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            c.phone!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: cs.outline,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Chevron
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: cs.outlineVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),

      // Pill-shaped FAB (Stitch: NO circular FABs)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('customer-new'),
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryDark,
        elevation: 0,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Novo Cliente',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      bottomNavigationBar: const SharedBottomNav(selectedIndex: 3),
    );
  }
}
