// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../main/main_screen.dart';
import '../../data/repositories/data_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 Second ka Timer
    Timer(const Duration(seconds: 3), () {
      // 3 sec baad MainScreen par jao
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. AAPKA LOGO (Sellora Brand Logo)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, // Pure white for brand logo
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/logo.png',
                width: 150, // Larger for brand impact
                height: 150,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 60),

            // 3. LOADING LINE BAR
            SizedBox(
              width: 200, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  color: AppColors.primary,
                  minHeight: 6,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Loading...",
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
