import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rsellx/features/splash/splash_screen.dart';
import 'package:rsellx/core/theme/app_theme.dart';
import 'package:rsellx/core/services/database_service.dart';
import 'package:rsellx/core/services/logger_service.dart';

import 'package:rsellx/providers/inventory_provider.dart';
import 'package:rsellx/providers/expense_provider.dart';
import 'package:rsellx/providers/sales_provider.dart';
import 'package:rsellx/providers/settings_provider.dart';
import 'package:rsellx/providers/backup_provider.dart';
import 'package:rsellx/providers/credit_provider.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Database
    await DatabaseService.init();

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
  }, (error, stack) {
    AppLogger.error("Unhandled Exception", error: error, stackTrace: stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RsellX',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Can be made dynamic with SettingsProvider
      home: const SplashScreen(),
    );
  }
}
