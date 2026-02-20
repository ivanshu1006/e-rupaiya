// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class GreyTextFormField extends StatelessWidget {
  const GreyTextFormField({
    super.key,
    required this.controller,
    this.labelText,
    this.isNumber = false,
    this.enabled = true,
    this.validator,
    this.hintText,
    this.height,
    this.contentPadding,
  });

  final TextEditingController controller;
  final String? labelText;
  final bool isNumber;
  final bool enabled;
  final String? Function(String?)? validator;
  final String? hintText;
  final double? height;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = contentPadding ??
        EdgeInsets.symmetric(vertical: (height ?? 40.h) * 0.2);
    return Container(
      height: height ?? 40.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.phoneFieldStart,
            AppColors.phoneFieldEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: isNumber ? 10 : null,
        inputFormatters: isNumber
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : null,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText ?? (isNumber ? '1234567890' : labelText),
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary.withOpacity(0.5),
            letterSpacing: 2,
          ),
          isCollapsed: true,
          contentPadding: resolvedPadding,
          counterText: '',
        ),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
        validator: validator,
      ),
    );
  }
}
