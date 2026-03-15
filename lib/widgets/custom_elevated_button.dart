// ignore_for_file: deprecated_member_use

import 'package:e_rupaiya/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.width = double.infinity,
    this.height,
    this.showArrow = false,
    this.uppercaseLabel = true,
    this.isBorder = false,
    this.backgroundColor,
    this.borderColor,
    this.labelColor,
  });

  final VoidCallback? onPressed;
  final String label;
  final double? width;
  final double? height;
  final bool showArrow;
  final bool uppercaseLabel;
  final bool isBorder;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final background = isDisabled
        ? LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.35),
              AppColors.primary.withOpacity(0.4),
            ],
          )
        : (backgroundColor != null
            ? LinearGradient(
                colors: [backgroundColor!, backgroundColor!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ));

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isBorder ? null : background,
          color: isBorder ? (backgroundColor ?? Colors.transparent) : null,
          borderRadius: BorderRadius.circular(28.r),
          border: isBorder
              ? Border.all(
                  color: borderColor ?? AppColors.primary,
                )
              : null,
          boxShadow: [
            if (!isDisabled && !isBorder)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: labelColor ?? Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: showArrow
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              Text(
                uppercaseLabel ? label.toUpperCase() : label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: labelColor ?? Colors.white,
                      letterSpacing: 1.1,
                    ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: labelColor ?? AppColors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
