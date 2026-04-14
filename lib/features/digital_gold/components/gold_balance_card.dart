import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoldBalanceCard extends StatelessWidget {
  const GoldBalanceCard({
    super.key,
    required this.balance,
    required this.changeText,
    this.backgroundColor = const Color(0xFFC9A06F),
    this.label = 'My Gold',
    this.borderColor = const Color(0xffFFBF2B),
  });

  final String balance;
  final String changeText;
  final Color backgroundColor;
  final String label;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      balance,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      changeText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF1D8E3A),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.black),
        ],
      ),
    );
  }
}
