import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../catalog/data/models/flavor_model.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';

// Represents an item in the shopping cart
class CartItem {
  final FlavorModel flavor;
  final int quantity;

  CartItem({required this.flavor, this.quantity = 1});

  CartItem copyWith({FlavorModel? flavor, int? quantity}) {
    return CartItem(
      flavor: flavor ?? this.flavor,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => flavor.preco * quantity;
}

// Manages the state of the shopping cart
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(FlavorModel flavor) {
    final existingIndex = state.indexWhere((item) => item.flavor.id == flavor.id);
    if (existingIndex >= 0) {
      final updatedCart = [...state];
      final item = updatedCart[existingIndex];
      updatedCart[existingIndex] = item.copyWith(quantity: item.quantity + 1);
      state = updatedCart;
    } else {
      state = [...state, CartItem(flavor: flavor)];
    }
  }

  void removeItem(String flavorId) {
    state = state.where((item) => item.flavor.id != flavorId).toList();
  }

  void updateQuantity(String flavorId, int delta) {
    final updatedCart = [...state];
    final existingIndex = updatedCart.indexWhere((item) => item.flavor.id == flavorId);
    
    if (existingIndex >= 0) {
      final item = updatedCart[existingIndex];
      final newQuantity = item.quantity + delta;
      
      if (newQuantity <= 0) {
        removeItem(flavorId);
      } else {
        updatedCart[existingIndex] = item.copyWith(quantity: newQuantity);
        state = updatedCart;
      }
    }
  }

  void clear() {
    state = [];
  }

  double get subtotal => state.fold(0, (sum, item) => sum + item.totalPrice);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

// Category filter for POS
class PosCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void setFilter(String? value) => state = value;
}

final posCategoryFilterProvider = NotifierProvider<PosCategoryFilterNotifier, String?>(() {
  return PosCategoryFilterNotifier();
});

// Filtered catalog for POS
final posFilteredCatalogProvider = Provider<AsyncValue<List<FlavorModel>>>((ref) {
  final catalogAsync = ref.watch(catalogListProvider);
  final filter = ref.watch(posCategoryFilterProvider);

  return catalogAsync.whenData((flavors) {
    if (filter == null || filter == 'Todos') return flavors;
    return flavors.where((f) => f.linha == filter).toList();
  });
});
