import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rsellx/features/splash/splash_screen.dart';
import 'package:rsellx/core/theme/app_theme.dart';
import 'package:rsellx/data/models/inventory_model.dart';
import 'package:rsellx/data/models/sale_model.dart';
import 'package:rsellx/data/models/expense_model.dart';
import 'package:rsellx/data/models/credit_model.dart';

import 'package:rsellx/providers/inventory_provider.dart';
import 'package:rsellx/providers/expense_provider.dart';
import 'package:rsellx/providers/sales_provider.dart';
import 'package:rsellx/providers/settings_provider.dart';
import 'package:rsellx/providers/backup_provider.dart';
import 'package:rsellx/providers/credit_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup Database (Hive)
  try {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(InventoryItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SaleRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExpenseItemAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CreditRecordAdapter());
    }

    // 2. Data Migration (Open/Close dynamic boxes to convert Map data)
    await _migrateData();

    // 3. Open Boxes for the App (Typed)
    await Hive.openBox<InventoryItem>('inventoryBox');
    await Hive.openBox<SaleRecord>('historyBox');
    await Hive.openBox<SaleRecord>('cartBox');
    await Hive.openBox<ExpenseItem>('expensesBox');
    await Hive.openBox<CreditRecord>('creditsBox');
    await Hive.openBox('settingsBox');
  } catch (e) {
    print("CRITICAL INITIALIZATION ERROR: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BackupProvider()),
        ChangeNotifierProvider(create: (_) => CreditProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _migrateData() async {
  // 1. Migrate History
  var historyBox = await Hive.openBox('historyBox');
  final List<dynamic> historyKeys = historyBox.keys.toList();
  for (var key in historyKeys) {
    var value = historyBox.get(key);
    if (value is Map) {
      try {
        final sale = SaleRecord(
          id: value['id']?.toString() ?? key.toString(),
          itemId: value['itemId']?.toString() ?? "",
          name: value['name']?.toString() ?? "Unknown",
          price: (value['price'] as num?)?.toDouble() ?? 0.0,
          actualPrice: (value['actualPrice'] as num?)?.toDouble() ?? 0.0,
          qty: (value['qty'] as num?)?.toInt() ?? 1,
          profit: (value['profit'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.tryParse(value['date']?.toString() ?? "") ?? DateTime.now(),
          status: value['status']?.toString() ?? "Sold",
          billId: value['billId']?.toString(),
        );
        await historyBox.put(key, sale);
      } catch (e) {
        print("Failed to migrate history item $key: $e");
      }
    }
  }
  await historyBox.close();

  // 2. Migrate Inventory
  var inventoryBox = await Hive.openBox('inventoryBox');
  final List<dynamic> invKeys = inventoryBox.keys.toList();
  for (var key in invKeys) {
    var value = inventoryBox.get(key);
    if (value is Map) {
      try {
        final item = InventoryItem(
          id: value['id']?.toString() ?? key.toString(),
          name: value['name']?.toString() ?? "Unknown",
          price: (value['price'] as num?)?.toDouble() ?? 0.0,
          stock: (value['stock'] as num?)?.toInt() ?? 0,
          description: value['description']?.toString(),
          barcode: value['barcode']?.toString() ?? "N/A",
        );
        await inventoryBox.put(key, item);
      } catch (e) {
        print("Failed to migrate inventory item $key: $e");
      }
    }
  }
  await inventoryBox.close();

  // 3. Migrate Expenses
  var expensesBox = await Hive.openBox('expensesBox');
  final List<dynamic> expKeys = expensesBox.keys.toList();
  for (var key in expKeys) {
    var value = expensesBox.get(key);
    if (value is Map) {
      try {
        final expense = ExpenseItem(
          id: value['id']?.toString() ?? key.toString(),
          title: value['title']?.toString() ?? "Unknown",
          amount: (value['amount'] as num?)?.toDouble() ?? 0.0,
          date: DateTime.tryParse(value['date']?.toString() ?? "") ?? DateTime.now(),
          category: value['category']?.toString() ?? "General",
        );
        await expensesBox.put(key, expense);
      } catch (e) {
        print("Failed to migrate expense item $key: $e");
      }
    }
  }
  await expensesBox.close();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RsellX',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
