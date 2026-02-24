// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frappe_flutter_app/constants/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.width = double.infinity,
    this.height,
    this.showArrow = false,
    this.uppercaseLabel = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final double? width;
  final double? height;
  final bool showArrow;
  final bool uppercaseLabel;

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
        : const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDisabled)
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
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: AppColors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
