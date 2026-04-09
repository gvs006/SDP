import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/catalog/presentation/screens/catalog_list_screen.dart';
import '../../features/customers/presentation/screens/customers_list_screen.dart';
import '../../features/customers/presentation/screens/customer_form_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Dashboard (Home)
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    // Catalog
    GoRoute(
      path: '/catalog',
      name: 'catalog',
      builder: (context, state) => const CatalogListScreen(),
    ),

    // Customers
    GoRoute(
      path: '/customers',
      name: 'customers',
      builder: (context, state) => const CustomersListScreen(),
      routes: [
        GoRoute(
          path: 'new',
          name: 'customer-new',
          builder: (context, state) => const CustomerFormScreen(),
        ),
        GoRoute(
          path: ':id/edit',
          name: 'customer-edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CustomerFormScreen(customerId: id);
          },
        ),
      ],
    ),

    // PDV (Point of Sale)
    GoRoute(
      path: '/pos',
      name: 'pos',
      builder: (context, state) => const PosScreen(),
    ),

    // Inventory
    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => const InventoryScreen(),
    ),
  ],
);
