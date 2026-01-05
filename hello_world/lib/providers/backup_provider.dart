import 'package:flutter/foundation.dart';
import 'package:rsellx/core/services/backup_service.dart';
import 'package:rsellx/core/services/reporting_service.dart';
import 'package:hive/hive.dart';
import 'package:rsellx/data/models/inventory_model.dart';
import 'package:rsellx/data/models/sale_model.dart';
import 'package:rsellx/data/models/expense_model.dart';

class BackupProvider extends ChangeNotifier {
  Box<InventoryItem> get _inventoryBox => Hive.box<InventoryItem>('inventoryBox');
  Box<ExpenseItem> get _expensesBox => Hive.box<ExpenseItem>('expensesBox');
  Box<SaleRecord> get _historyBox => Hive.box<SaleRecord>('historyBox');
  Box get _settingsBox => Hive.box('settingsBox');

  Future<void> exportBackup() async {
    await BackupService.exportBackup();
  }

  Future<bool> importBackup() async {
    final success = await BackupService.importBackup();
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<bool> importInventoryFromExcel() async {
    final success = await ReportingService.importInventoryFromExcel();
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<void> clearAllData() async {
    await _inventoryBox.clear();
    await _historyBox.clear();
    await _expensesBox.clear();
    // settingsBox stays to keep shop name, unless explicitly reset
    notifyListeners();
  }
}
