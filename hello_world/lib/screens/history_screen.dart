// lib/screens/history_screen.dart
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "History / Record",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        actions: [
          // Calendar filter icon
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "AAJ KI SALE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Sale Item 1
          _buildHistoryItem(
            title: "Bone China Cup (Blue)",
            time: "10:30 AM",
            price: "Rs 450",
            status: "SOLD",
            isSale: true,
          ),

          // Sale Item 2
          _buildHistoryItem(
            title: "Dinner Set (Large)",
            time: "11:15 AM",
            price: "Rs 12,500",
            status: "SOLD",
            isSale: true,
          ),

          const SizedBox(height: 24),
          const Text(
            "KAL KI SALE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Expense Item (Kharcha)
          _buildHistoryItem(
            title: "Dukan ka Bill",
            time: "Yesterday",
            price: "Rs 2,000",
            status: "EXPENSE",
            isSale: false, // Yeh sale nahi, kharcha hai
          ),
        ],
      ),
    );
  }

  // Helper Widget for List Item
  Widget _buildHistoryItem({
    required String title,
    required String time,
    required String price,
    required String status,
    required bool isSale,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // 1. Icon (Green for Sale, Red for Expense)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSale ? Colors.green[50] : Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSale ? Icons.arrow_downward : Icons.arrow_upward,
              color: isSale ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // 2. Name & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // 3. Price & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: isSale
                      ? Colors.black
                      : Colors.red, // Kharcha laal rang mein
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSale ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
