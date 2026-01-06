import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:rsellx/data/models/inventory_model.dart';

class InventoryProvider extends ChangeNotifier {
  List<InventoryItem> _cachedInventory = [];
  bool _inventoryDirty = true;

  InventoryProvider() {
    _inventoryBox.watch().listen((_) {
      _inventoryDirty = true;
      notifyListeners();
    });
    // Initial load
    _refreshCache();
  }

  Box<InventoryItem> get _inventoryBox => Hive.box<InventoryItem>('inventoryBox');

  List<InventoryItem> get inventory {
    if (_inventoryDirty) {
      _refreshCache();
    }
    return _cachedInventory;
  }

  void _refreshCache() {
    _cachedInventory = _inventoryBox.values.toList();
    _inventoryDirty = false;
  }

  void addInventoryItem(InventoryItem item) {
    _inventoryBox.put(item.id, item);
  }

  void updateInventoryItem(InventoryItem item) {
    item.save();
  }

  void deleteInventoryItem(InventoryItem item) {
    item.delete();
  }

  double getTotalStockValue() {
    // Perform calculation on cached list which is faster than box iteration
    double total = 0.0;
    for (var item in inventory) {
      total += (item.price * item.stock);
    }
    return total;
  }

  int getLowStockCount() {
    return inventory.where((item) => item.stock < item.lowStockThreshold).length;
  }

  Future<void> clearAllData() async {
    await _inventoryBox.clear();
  }

  InventoryItem? findItemByBarcode(String barcode) {
    try {
      // Search in memory cache
      return inventory.firstWhere((item) => item.barcode == barcode);
    } catch (_) {
      return null;
    }
  }
}
