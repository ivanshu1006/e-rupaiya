import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';

class GoldDetailsSectionTitle extends StatelessWidget {
  const GoldDetailsSectionTitle({
    super.key,
    required this.title,
    this.trailingIcon,
    this.onTrailingTap,
  });

  final String title;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (trailingIcon != null)
          IconButton(
            onPressed: onTrailingTap,
            icon: Icon(trailingIcon, size: 20.r, color: AppColors.textPrimary),
          ),
      ],
    );
  }
}
