import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/inventory_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/credit_model.dart';
import 'logger_service.dart';

class BackupService {
  static Future<void> exportBackup() async {
    final inventoryBox = Hive.box<InventoryItem>('inventoryBox');

    final salesBox = Hive.box<SaleRecord>('historyBox');
    final cartBox = Hive.box<SaleRecord>('cartBox');
    final expensesBox = Hive.box<ExpenseItem>('expensesBox');
    final creditsBox = Hive.box<CreditRecord>('creditsBox');
    final settingsBox = Hive.box('settingsBox');

    final backupData = {
      'inventory': inventoryBox.values.map((e) => {
        'id': e.id,
        'name': e.name,
        'price': e.price,
        'stock': e.stock,
        'description': e.description,
        'barcode': e.barcode,
      }).toList(),
      'sales': salesBox.values.map((e) => {
        'id': e.id,
        'itemId': e.itemId,
        'name': e.name,
        'price': e.price,
        'actualPrice': e.actualPrice,
        'qty': e.qty,
        'profit': e.profit,
        'date': e.date.toIso8601String(),
        'status': e.status,
        'billId': e.billId,

      }).toList(),
      'cart': cartBox.values.map((e) => {
        'id': e.id,
        'itemId': e.itemId,
        'name': e.name,
        'price': e.price,
        'actualPrice': e.actualPrice,
        'qty': e.qty,
        'profit': e.profit,
        'date': e.date.toIso8601String(),
        'status': e.status,
        'billId': e.billId,
      }).toList(),
      'expenses': expensesBox.values.map((e) => {
        'id': e.id,
        'title': e.title,
        'amount': e.amount,
        'date': e.date.toIso8601String(),
        'category': e.category,
      }).toList(),
      'credits': creditsBox.values.map((e) => {
        'id': e.id,
        'name': e.name,
        'phone': e.phone,
        'amount': e.amount,
        'date': e.date.toIso8601String(),
        'type': e.type,
        'isSettled': e.isSettled,
        'description': e.description,
        'dueDate': e.dueDate?.toIso8601String(),
        'paidAmount': e.paidAmount,
        'logs': e.logs,
      }).toList(),
      'settings': await _prepareSettingsForExport(settingsBox),
      'timestamp': DateTime.now().toIso8601String(),
    };

    final String jsonString = jsonEncode(backupData);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/crockery_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    
    await file.writeAsString(jsonString);
    await Share.shareXFiles([XFile(file.path)], text: 'Crockery Manager Data Backup');
  }

  static Future<bool> importBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final String jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      // Restore Inventory
      if (backupData.containsKey('inventory')) {
        final box = Hive.box<InventoryItem>('inventoryBox');
        await box.clear();
        for (var item in backupData['inventory']) {
          box.put(item['id'], InventoryItem(
            id: item['id'],
            name: item['name'],
            price: ((item['price'] as num?)?.toDouble()) ?? 0.0,
            stock: ((item['stock'] as num?)?.toInt()) ?? 0,
            description: item['description'],
            barcode: item['barcode'],
          ));
        }
      }

      // Restore Sales
      if (backupData.containsKey('sales')) {
        final box = Hive.box<SaleRecord>('historyBox');
        await box.clear();
        for (var item in backupData['sales']) {
          box.put(item['id'], SaleRecord(
            id: item['id'],
            itemId: item['itemId'],
            name: item['name'],
            price: ((item['price'] as num?)?.toDouble()) ?? 0.0,
            actualPrice: ((item['actualPrice'] as num?)?.toDouble()) ?? 0.0,
            qty: ((item['qty'] as num?)?.toInt()) ?? 1,
            profit: ((item['profit'] as num?)?.toDouble()) ?? 0.0,
            date: DateTime.parse(item['date']),
            status: item['status'],
            billId: item['billId'],
          ));
        }
      }

      // Restore Expenses
      if (backupData.containsKey('expenses')) {
        final box = Hive.box<ExpenseItem>('expensesBox');
        await box.clear();
        for (var item in backupData['expenses']) {
          box.put(item['id'], ExpenseItem(
            id: item['id'],
            title: item['title'],
            amount: ((item['amount'] as num?)?.toDouble()) ?? 0.0,
            date: DateTime.parse(item['date']),
            category: item['category'],
          ));
        }
      }

      // Restore Cart
      if (backupData.containsKey('cart')) {
        final box = Hive.box<SaleRecord>('cartBox');
        await box.clear();
        for (var item in backupData['cart']) {
          box.put(item['id'], SaleRecord(
            id: item['id'],
            itemId: item['itemId'],
            name: item['name'],
            price: ((item['price'] as num?)?.toDouble()) ?? 0.0,
            actualPrice: ((item['actualPrice'] as num?)?.toDouble()) ?? 0.0,
            qty: ((item['qty'] as num?)?.toInt()) ?? 1,
            profit: ((item['profit'] as num?)?.toDouble()) ?? 0.0,
            date: DateTime.parse(item['date']),
            status: item['status'],
            billId: item['billId'],
          ));
        }
      }

      // Restore Credits
      if (backupData.containsKey('credits')) {
        final box = Hive.box<CreditRecord>('creditsBox');
        await box.clear();
        for (var item in backupData['credits']) {
          box.put(item['id'], CreditRecord(
            id: item['id'],
            name: item['name'],
            phone: item['phone'],
            amount: ((item['amount'] as num?)?.toDouble()) ?? 0.0,
            date: DateTime.parse(item['date']),
            type: item['type'],
            isSettled: item['isSettled'] ?? false,
            description: item['description'],
            dueDate: item['dueDate'] != null ? DateTime.parse(item['dueDate']) : null,
            paidAmount: ((item['paidAmount'] as num?)?.toDouble()) ?? 0.0,
            logs: (item['logs'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          ));
        }
      }

      // Restore Settings
      if (backupData.containsKey('settings')) {
        final box = Hive.box('settingsBox');
        await box.clear();
        final settings = backupData['settings'] as Map<String, dynamic>;
        
        // Restore Logo Image if present
        if (settings.containsKey('logo_base64')) {
           try {
             final String base64Image = settings['logo_base64'];
             if (base64Image.isNotEmpty) {
               final bytes = base64Decode(base64Image);
               final dir = await getApplicationDocumentsDirectory();
               final file = File('${dir.path}/restored_logo_${DateTime.now().millisecondsSinceEpoch}.png');
               await file.writeAsBytes(bytes);
               
               // Update path to the new local file
               settings['logoPath'] = file.path; 
             }
           } catch (e) {
             AppLogger.error("Error restoring logo", error: e);
           }
           // Remove data key so we don't store it in Hive
           settings.remove('logo_base64'); 
        }

        settings.forEach((key, value) {
          box.put(key, value);
        });
      }
      return true;
    }
    return false;
  }

  static Future<Map<String, dynamic>> _prepareSettingsForExport(Box settingsBox) async {
    final Map<String, dynamic> settingsMap = settingsBox.toMap().map((k, v) => MapEntry(k.toString(), v));
    
    // Retrieve and encode logo if exists
    if (settingsMap.containsKey('logoPath')) {
      final String? path = settingsMap['logoPath'] as String?;
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          try {
            final bytes = await file.readAsBytes();
            final base64Image = base64Encode(bytes);
            settingsMap['logo_base64'] = base64Image;
          } catch (e) {
            AppLogger.error("Failed to encode logo", error: e);
          }
        }
      }
    }
    return settingsMap;
  }
}
