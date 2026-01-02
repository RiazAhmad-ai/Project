// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Dashboard ki jagah MainScreen import karein

void main() {
  runApp(const CrockeryApp());
}

class CrockeryApp extends StatelessWidget {
  const CrockeryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crockery Manager',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.red),
      // Yahan change kiya: Pehle DashboardScreen tha, ab MainScreen hai
      home: const MainScreen(),
    );
  }
}
