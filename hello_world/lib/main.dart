import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/splash/splash_screen.dart';
import 'data/models/inventory_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup Database (Hive)
  try {
    await Hive.initFlutter();

    // Register Adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(InventoryItemAdapter());
    }

    // Open Boxes
    await Hive.openBox<InventoryItem>('inventoryBox');
    await Hive.openBox('expensesBox');
    await Hive.openBox('historyBox');
    await Hive.openBox('settingsBox');
  } catch (e) {
    print("CRITICAL INITIALIZATION ERROR: $e");
    // Fallback or just let it try to run - at least we get logs
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Retail POS System',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
