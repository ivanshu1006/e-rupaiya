import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoldAmountChip extends StatelessWidget {
  const GoldAmountChip({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color ?? const Color(0xffD7AA41),
          gradient: gradient,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
