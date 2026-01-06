// lib/features/dashboard/overview_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class OverviewCard extends StatefulWidget {
  final String title;
  final String amount;
  final IconData icon; // Icon can be changed
  final List<Color>? gradientColors; // For changing colors
  final VoidCallback? onTap;

  const OverviewCard({
    super.key,
    required this.title,
    required this.amount,
    this.icon = Icons.inventory_2, // Default Icon
    this.gradientColors, // Optional Color
    this.onTap,
  });

  @override
  State<OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<OverviewCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              widget.gradientColors ??
              [AppColors.secondary, const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === TITLE + EYE ICON ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.title.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                    child: Icon(
                      _isBalanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ],
              ),
              Icon(
                widget.icon,
                color: Colors.white70,
                size: 18,
              ), // Dynamic Icon
            ],
          ),

          const SizedBox(height: 16),

          // === AMOUNT TEXT ===
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isBalanceVisible ? widget.amount : "Rs •••••••",
              key: ValueKey<bool>(_isBalanceVisible),
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
