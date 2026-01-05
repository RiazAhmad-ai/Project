import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:rsellx/data/models/inventory_model.dart';

class InventoryProvider extends ChangeNotifier {
  InventoryProvider() {
    _inventoryBox.watch().listen((_) => notifyListeners());
  }

  Box<InventoryItem> get _inventoryBox => Hive.box<InventoryItem>('inventoryBox');

  List<InventoryItem> get inventory => _inventoryBox.values.toList();

  void addInventoryItem(InventoryItem item) {
    _inventoryBox.put(item.id, item);
    notifyListeners();
  }

  void updateInventoryItem(InventoryItem item) {
    item.save();
    notifyListeners();
  }

  void deleteInventoryItem(InventoryItem item) {
    item.delete();
    notifyListeners();
  }

  double getTotalStockValue() {
    double total = 0.0;
    for (var item in _inventoryBox.values) {
      total += (item.price * item.stock);
    }
    return total;
  }

  int getLowStockCount() {
    return _inventoryBox.values.where((item) => item.stock < item.lowStockThreshold).length;
  }

  Future<void> clearAllData() async {
    await _inventoryBox.clear();
    notifyListeners();
  }

  InventoryItem? findItemByBarcode(String barcode) {
    try {
      return _inventoryBox.values.firstWhere((item) => item.barcode == barcode);
    } catch (_) {
      return null;
    }
  }
}
