import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_bottom_nav.dart';
import '../providers/pos_providers.dart';
import '../../../catalog/data/models/flavor_model.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800; // threshold for tablet/desktop
    // If not large enough screen, we might need a bottom sheet or a toggle. For simplicity, we lay it out responsively.
    
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        title: Text(
          'PDV - Novo Pedido',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryGreen,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              cartNotifier.clear();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.close_rounded, color: AppTheme.statusRed),
            label: const Text('Cancelar', style: TextStyle(color: AppTheme.statusRed)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT SIDE (Cart / Resumo do Pedido) ──
          if (isDesktop)
            Expanded(
              flex: 4,
              child: _CartPanel(),
            ),
          
          if (!isDesktop)
            const SizedBox.shrink(), // On mobile, we might overlay or show it differently. We will assume Tablet for now.

          // ── RIGHT SIDE (Products Catalog) ──
          Expanded(
            flex: 6,
            child: _ProductCatalogPanel(),
          ),
        ],
      ),
      // On mobile screens, show a bottom sheet or a floating action to view the cart
      floatingActionButton: !isDesktop && cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: _CartPanel(),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart_rounded),
              label: Text('${cartItems.length} itens - R\$ ${cartNotifier.subtotal.toStringAsFixed(2)}'),
            )
          : null,
      bottomNavigationBar: const SharedBottomNav(selectedIndex: 2),
    );
  }
}

class _ProductCatalogPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final flavorsAsync = ref.watch(posFilteredCatalogProvider);
    final selectedCategory = ref.watch(posCategoryFilterProvider);

    final categories = ['Todos', 'Gourmet', 'Refrescante', 'Bebidas'];

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          // Search & Categories
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Buscar produtos...',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = selectedCategory == cat || (selectedCategory == null && cat == 'Todos');
                      
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(posCategoryFilterProvider.notifier).setFilter(cat == 'Todos' ? null : cat);
                          }
                        },
                        showCheckmark: false,
                        selectedColor: AppTheme.tertiaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF4C3E0B) : cs.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: flavorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
              error: (err, _) => Center(child: Text('Erro: $err')),
              data: (flavors) {
                if (flavors.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado.'));
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: flavors.length,
                  itemBuilder: (context, index) {
                    return _ProductCard(flavor: flavors[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final FlavorModel flavor;

  const _ProductCard({required this.flavor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isGourmet = flavor.linha == 'Gourmet';
    final accentColor = isGourmet ? AppTheme.accentGoldDark : AppTheme.statusGreen;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A042110),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/flavors/${flavor.externalId}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    isGourmet ? Icons.icecream_rounded : Icons.local_drink_rounded,
                    size: 48,
                    color: accentColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flavor.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${flavor.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(cartProvider.notifier).addItem(flavor);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      flavor.estoque < flavor.minStock ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                      size: 12,
                      color: flavor.estoque < flavor.minStock ? AppTheme.statusRed : cs.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${flavor.estoque} em estoque',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: flavor.estoque < flavor.minStock ? AppTheme.statusRed : cs.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15)),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Pedido Atual',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (cartItems.isNotEmpty)
                  TextButton(
                    onPressed: () => cartNotifier.clear(),
                    child: const Text('Limpar', style: TextStyle(color: AppTheme.statusRed)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_checkout_rounded, size: 64, color: cs.outlineVariant),
                        const SizedBox(height: 16),
                        Text('Carrinho vazio', style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text('Adicione produtos para iniciar', style: theme.textTheme.bodySmall?.copyWith(color: cs.outline)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 16, height: 1, color: cs.outlineVariant.withValues(alpha: 0.1)),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item.flavor.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('R\$ ${item.flavor.preco.toStringAsFixed(2).replaceAll('.', ',')} un', style: theme.textTheme.bodySmall),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded),
                              color: cs.outline,
                              onPressed: () => cartNotifier.updateQuantity(item.flavor.id, -1),
                            ),
                            Text('${item.quantity}', style: theme.textTheme.titleMedium),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded),
                              color: AppTheme.primaryGreen,
                              onPressed: () => cartNotifier.updateQuantity(item.flavor.id, 1),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              child: Text(
                                'R\$ ${item.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Checkout Summary
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.15))),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                      Text('R\$ ${cartNotifier.subtotal.toStringAsFixed(2).replaceAll('.', ',')}', style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Desconto', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                      Text('R\$ 0,00', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.statusGreen)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        'R\$ ${cartNotifier.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: cs.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: const Text('Pagamento via Pix', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Escaneie o QR Code abaixo para pagar', textAlign: TextAlign.center),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: cs.outlineVariant),
                                  ),
                                  child: const Icon(Icons.qr_code_2_rounded, size: 200, color: AppTheme.primaryGreen),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'R\$ ${cartNotifier.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar', style: TextStyle(color: AppTheme.statusRed)),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                                onPressed: () {
                                  Navigator.pop(ctx); // Close dialog
                                  cartNotifier.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Pagamento Confirmado! Venda Finalizada.'),
                                      backgroundColor: AppTheme.statusGreen,
                                    ),
                                  );
                                  context.go('/'); // Return to dashboard
                                },
                                child: const Text('Simular Pagamento', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Finalizar Venda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
