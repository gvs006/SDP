import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SharedBottomNav extends StatelessWidget {
  final int selectedIndex;

  const SharedBottomNav({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F042110),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'DASHBOARD',
              isActive: selectedIndex == 0,
              onTap: () => context.go('/'),
            ),
            _NavItem(
              icon: Icons.icecream_rounded,
              label: 'CATÁLOGO',
              isActive: selectedIndex == 1,
              onTap: () => context.go('/catalog'),
            ),
            // Middle Prominent Item (PDV)
            _PdvItem(
              isActive: selectedIndex == 2,
              onTap: () => context.go('/pos'),
            ),
            _NavItem(
              icon: Icons.people_rounded,
              label: 'CLIENTES',
              isActive: selectedIndex == 3,
              onTap: () => context.go('/customers'),
            ),
            _NavItem(
              icon: Icons
                  .settings_rounded, // Assuming 'Ajustes' maps to settings, or inventory for now
              label: 'AJUSTES',
              isActive: selectedIndex == 4,
              onTap: () => context.go('/inventory'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppTheme.primaryGreen
        : AppTheme.primaryGreen.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PdvItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _PdvItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = AppTheme.primaryGreen;
    final iconColor = Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.point_of_sale_rounded, color: iconColor, size: 26),
            const SizedBox(height: 2),
            Text(
              'PDV',
              style: TextStyle(
                color: iconColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
