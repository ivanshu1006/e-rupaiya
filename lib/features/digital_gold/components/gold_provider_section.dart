import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';

class GoldProviderSection extends StatelessWidget {
  const GoldProviderSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.showChevron = false,
  });

  final String title;
  final String subtitle;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(FileConstants.mmtcPamp, width: 48.w, height: 48.h),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF5B3A12),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.75),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        if (showChevron)
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22.r,
            color: AppColors.textPrimary,
          ),
      ],
    );
  }
}
