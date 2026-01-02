// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'history_screen.dart';
import 'camera_screen.dart'; // Camera screen import ki

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const InventoryScreen(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Camera kholne ka function
  void _openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CameraScreen(mode: 'sell'), // <--- 'sell' pass kiya
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // === FLOATING CAMERA BUTTON (NEW) ===
      floatingActionButton: SizedBox(
        height: 70, // Button thoda bada
        width: 70,
        child: FloatingActionButton(
          onPressed: _openCamera, // Click par camera kholo
          backgroundColor: Colors.red, // Laal rang
          shape: const CircleBorder(), // Bilkul gol
          elevation: 10, // Shadow
          child: const Icon(Icons.camera_alt, size: 30, color: Colors.white),
        ),
      ),
      // Button ko center mein rakhne ki location
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // === BOTTOM NAVIGATION ===
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          // Beech mein thoda gap dikhane ke liye hum Inventory icon use kar rahe hain
          // lekin Camera button uske upar float karega
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
