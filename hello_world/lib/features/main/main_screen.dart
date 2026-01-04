import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../dashboard/dashboard_screen.dart';
import '../inventory/inventory_screen.dart';
import '../history/history_screen.dart';
import '../expenses/expense_screen.dart';
import '../../data/models/inventory_model.dart';
import '../inventory/sell_item_sheet.dart';

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
    final String? barcode = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Scan Item for Bill", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      Navigator.pop(context, barcodes.first.rawValue);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            const SizedBox(height: 10),
          ],
        ),
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
          backgroundColor: Colors.red,
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
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left Side (Same rahega)
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

              // Beech mein Camera ke liye gap
              const SizedBox(width: 48),

              // Right Side (YAHAN SWAP HUA HAI)
              // Pehle Kharcha (Index 2)
              _buildTabItem(
                icon: Icons.wallet_outlined,
                activeIcon: Icons.wallet,
                label: "Expenses",
                index: 2,
              ),
              // Phir History (Index 3)
              _buildTabItem(
                icon: Icons.history,
                activeIcon: Icons.history,
                label: "History",
                index: 3,
              ),
            ],
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.red : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.red : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
