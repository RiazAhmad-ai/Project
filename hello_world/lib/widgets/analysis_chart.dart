// lib/widgets/analysis_chart.dart
import 'package:flutter/material.dart';

class AnalysisChart extends StatefulWidget {
  final String title;
  final List<String> labels;

  const AnalysisChart({super.key, required this.title, required this.labels});

  @override
  State<AnalysisChart> createState() => _AnalysisChartState();
}

class _AnalysisChartState extends State<AnalysisChart> {
  String _selectedView = "Sales";
  int? touchedIndex;

  // === DATA LOGIC ===
  List<double> get currentData {
    bool isWeekly = widget.labels.length == 7;
    // Data values 0.0 se 1.0 ke darmiyan hone chahiye
    if (_selectedView == "Sales") {
      return isWeekly
          ? [0.4, 0.6, 0.8, 0.5, 0.9, 0.7, 0.4]
          : [0.5, 0.7, 0.9, 0.6];
    } else if (_selectedView == "Profit") {
      return isWeekly
          ? [0.2, 0.4, 0.6, 0.3, 0.7, 0.5, 0.2]
          : [0.3, 0.5, 0.8, 0.4];
    } else {
      // EXPENSES
      return isWeekly
          ? [0.2, 0.1, 0.3, 0.4, 0.2, 0.1, 0.5]
          : [0.4, 0.3, 0.5, 0.2];
    }
  }

  List<String> get currentValues {
    bool isWeekly = widget.labels.length == 7;
    if (_selectedView == "Sales") {
      return isWeekly
          ? ["5k", "8k", "12k", "6k", "15k", "9k", "5k"]
          : ["50k", "80k", "95k", "60k"];
    } else if (_selectedView == "Profit") {
      return isWeekly
          ? ["2k", "4k", "7k", "3k", "9k", "5k", "2k"]
          : ["15k", "25k", "40k", "20k"];
    } else {
      return isWeekly
          ? ["3k", "2k", "4k", "5k", "3k", "2k", "1k"]
          : ["35k", "55k", "45k", "40k"];
    }
  }

  Color get currentColor {
    if (_selectedView == "Sales") return Colors.blue;
    if (_selectedView == "Profit") return Colors.green;
    return Colors.red;
  }

  String get totalAmount {
    if (_selectedView == "Sales") return "Rs 124,000";
    if (_selectedView == "Profit") return "Rs 32,500";
    return "Rs 45,200";
  }

  @override
  Widget build(BuildContext context) {
    final data = currentData;
    final values = currentValues;
    Color barColor = currentColor;

    String displayAmount =
        (touchedIndex != null && touchedIndex! < values.length)
        ? "Rs ${values[touchedIndex!]}"
        : totalAmount;

    String displayLabel =
        (touchedIndex != null && touchedIndex! < widget.labels.length)
        ? "${widget.labels[touchedIndex!]} ${_selectedView}"
        : "TOTAL ${_selectedView.toUpperCase()}";

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
          // === HEADER (Fix Right Overflow) ===
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
              const SizedBox(width: 10), // Gap
              // FIX: Flexible + ScrollView lagaya taake buttons katein nahi
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

          // === AMOUNT ===
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  displayAmount,
                  key: ValueKey<String>(displayAmount),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              if (touchedIndex == null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: _selectedView == "Expenses"
                        ? Colors.red[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedView == "Expenses"
                            ? Icons.arrow_upward
                            : Icons.trending_up,
                        color: _selectedView == "Expenses"
                            ? Colors.red
                            : Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedView == "Expenses" ? "+5%" : "+12%",
                        style: TextStyle(
                          color: _selectedView == "Expenses"
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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

          // === BARS (Fix Bottom Overflow) ===
          // FIX: Height badha di 150 -> 180 taake text ko jagah miley
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (index) {
                bool isTouched = touchedIndex == index;
                // FIX: Bar ki max height control ki (140) taake text ke liye 40px bachein
                double barHeight = 140 * data[index];

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
                        height: barHeight, // Controlled Height
                        decoration: BoxDecoration(
                          color: isTouched
                              ? barColor.withOpacity(1.0)
                              : barColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        index < widget.labels.length
                            ? widget.labels[index]
                            : "",
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
      onTap: () {
        setState(() {
          _selectedView = text;
        });
      },
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
