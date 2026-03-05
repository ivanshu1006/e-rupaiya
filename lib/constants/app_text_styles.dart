import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle? bodySmallSemibold(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textPrimary,
          fontSize: 10.sp,
        );
  }

  static TextStyle? bodySmallMuted(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary.withValues(alpha: 0.65),
          height: 1.4,
        );
  }

  static TextStyle? bodyMediumBold(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: color ?? AppColors.textPrimary,
        );
  }

  static TextStyle? titleMediumBold(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: color ?? AppColors.textPrimary,
        );
  }

  static TextStyle? tabLabel(BuildContext context, {required bool isActive}) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isActive
              ? AppColors.primary
              : AppColors.textPrimary.withValues(alpha: 0.5),
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        );
  }
}
