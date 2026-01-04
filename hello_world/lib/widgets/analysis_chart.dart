import 'package:flutter/material.dart';
import '../utils/formatting.dart';
import 'dart:math'; // Max value nikalne ke liye

class AnalysisChart extends StatefulWidget {
  final String title;
  // Ab hum pura data map pass karenge
  final Map<String, dynamic> chartData;

  const AnalysisChart({
    super.key,
    required this.title,
    required this.chartData, // <--- Changed
  });

  @override
  State<AnalysisChart> createState() => _AnalysisChartState();
}

class _AnalysisChartState extends State<AnalysisChart> {
  String _selectedView = "Sales";
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    // Data nikalna
    List<String> labels = widget.chartData['labels'] ?? [];
    List<double> rawValues = widget.chartData[_selectedView] ?? [];

    // Graph ki height adjust karna (Normalization)
    // Sabse bari value dhundo taake graph us hisaab se scale ho
    double maxValue = rawValues.reduce(max);
    if (maxValue == 0) maxValue = 1; // Divide by zero se bachne ke liye

    // Total Amount Calculate karna
    double totalSum = rawValues.fold(0, (p, c) => p + c);
    String totalAmountStr = "Rs ${Formatter.formatCurrency(totalSum)}";

    // Current Display Logic
    String displayAmount =
        (touchedIndex != null && touchedIndex! < rawValues.length)
        ? "Rs ${Formatter.formatCurrency(rawValues[touchedIndex!])}"
        : totalAmountStr;

    String displayLabel =
        (touchedIndex != null && touchedIndex! < labels.length)
        ? "${labels[touchedIndex!]} ${_selectedView}"
        : "TOTAL ${_selectedView.toUpperCase()} (Last 7 Days)";

    // Color Selection
    Color barColor = _selectedView == "Sales"
        ? Colors.blue
        : _selectedView == "Profit"
        ? Colors.green
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleButton("Sales"),
                        _buildToggleButton("Profit"),
                        _buildToggleButton("Expenses"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // === AMOUNT DISPLAY ===
          Text(
            displayAmount,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          Text(
            displayLabel,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          // === BARS ===
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(rawValues.length, (index) {
                bool isTouched = touchedIndex == index;

                // === REAL LOGIC ===
                // Value ko 140px ki height mein fit karna
                double percentage = rawValues[index] / maxValue;
                double barHeight = 140 * percentage;
                if (barHeight < 5)
                  barHeight = 5; // Minimum height taake bar dikhayi de

                return GestureDetector(
                  onTapDown: (_) => setState(() => touchedIndex = index),
                  onTapUp: (_) => setState(() => touchedIndex = null),
                  onPanEnd: (_) => setState(() => touchedIndex = null),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        width: isTouched ? 16 : 12,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: isTouched
                              ? barColor.withOpacity(1.0)
                              : barColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        index < labels.length ? labels[index] : "",
                        style: TextStyle(
                          color: isTouched ? Colors.black : Colors.grey,
                          fontWeight: isTouched
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text) {
    bool isActive = _selectedView == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
