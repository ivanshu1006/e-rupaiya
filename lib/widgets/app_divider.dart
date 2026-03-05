import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.height = 1, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: color ?? AppColors.lightBorder,
    );
  }
}
