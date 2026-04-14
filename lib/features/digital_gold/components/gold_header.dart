import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';

class GoldHeader extends StatelessWidget {
  const GoldHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onHelp,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, size: 22.r, color: AppColors.textPrimary),
          ),
          SizedBox(width: 4.w),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onHelp,
            icon: Icon(Icons.help_outline, size: 22.r, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
