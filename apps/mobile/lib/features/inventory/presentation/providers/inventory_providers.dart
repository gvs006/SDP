import 'package:flutter_riverpod/flutter_riverpod.dart';

// Represents an ingredient/supply item (Mock for now, would connect to an actual IngredientModel)
class InventoryItem {
  final String id;
  final String name;
  final String unit;
  final double quantity;
  final double minimumStock;
  final String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.minimumStock,
    this.category = 'Ingredientes',
  });

  bool get isLowStock => quantity <= minimumStock;
  double get healthPercentage => (quantity / (minimumStock * 3)).clamp(0.0, 1.0);
}

// Mock data provider for inventory
final inventoryListProvider = FutureProvider<List<InventoryItem>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));
  
  return [
    InventoryItem(id: '1', name: 'Leite Ninho', unit: 'kg', quantity: 2.5, minimumStock: 1.0),
    InventoryItem(id: '2', name: 'Leite Condensado', unit: 'lata', quantity: 15, minimumStock: 20),
    InventoryItem(id: '3', name: 'Nutella', unit: 'kg', quantity: 0.8, minimumStock: 1.5),
    InventoryItem(id: '4', name: 'Embalagem P', unit: 'und', quantity: 120, minimumStock: 50),
    InventoryItem(id: '5', name: 'Leite Integral', unit: 'L', quantity: 12, minimumStock: 5),
    InventoryItem(id: '6', name: 'Morango', unit: 'kg', quantity: 1.2, minimumStock: 2.0),
    InventoryItem(id: '7', name: 'Maracujá', unit: 'kg', quantity: 4.5, minimumStock: 2.0),
    InventoryItem(id: '8', name: 'Adesivo/Lacre', unit: 'und', quantity: 350, minimumStock: 100),
  ];
});

final inventoryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final itemsAsync = ref.watch(inventoryListProvider);
  
  return itemsAsync.maybeWhen(
    data: (items) {
      final total = items.length;
      final lowStock = items.where((i) => i.isLowStock).length;
      return {'total': total, 'lowStock': lowStock};
    },
    orElse: () => {'total': 0, 'lowStock': 0},
  );
});
