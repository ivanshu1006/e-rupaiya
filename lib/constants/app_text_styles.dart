import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle? bodySmallSemibold(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textPrimary,
        );
  }
}
