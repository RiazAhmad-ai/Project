import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../dashboard/dashboard_screen.dart';
import '../inventory/inventory_screen.dart';
import '../history/history_screen.dart';
import '../expenses/expense_screen.dart';
import '../../data/models/inventory_model.dart';
import '../inventory/sell_item_sheet.dart';
import '../../shared/widgets/full_scanner_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(), // 0: Home
    const InventoryScreen(), // 1: Stock
    const ExpenseScreen(), // 2: Expenses
    const HistoryScreen(), // 3: History
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // === BARCODE SCANNER FOR SELLING ===
  void _openBarcodeScanner() async {
    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const FullScannerScreen(title: "Scan to Sell"),
      ),
    );

    if (barcode == null) return;

    // Search for match in inventory
    final box = Hive.box<InventoryItem>('inventoryBox');
    try {
      final match = box.values.firstWhere((item) => item.barcode == barcode);
      
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (context) => SellItemSheet(item: match),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ No item found with Barcode: $barcode"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // Floating Barcode Scanner Button
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: _openBarcodeScanner,
          backgroundColor: AppColors.accent,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.qr_code_scanner, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // === CHANGE 2: Buttons ki jagah badal di ===
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: "Home",
              index: 0,
            ),
            _buildTabItem(
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2,
              label: "Stock",
              index: 1,
            ),
            const SizedBox(width: 48),
            _buildTabItem(
              icon: Icons.wallet_outlined,
              activeIcon: Icons.wallet,
              label: "Expenses",
              index: 2,
            ),
            _buildTabItem(
              icon: Icons.history,
              activeIcon: Icons.history,
              label: "History",
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.accent : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isActive ? AppColors.accent : AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
