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
    final fieldHeight = height ?? 48.h;
    final fontSize = (fieldHeight * 0.42).clamp(12.0, 20.0);
    final verticalPadding =
        ((fieldHeight - fontSize) / 2).clamp(0.0, fieldHeight);
    final resolvedPadding = contentPadding ??
        EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: 12.w,
        );
    return Container(
      height: fieldHeight,
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
        cursorHeight: fontSize + 2,
        cursorWidth: 1.6,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText ?? (isNumber ? '1234567890' : labelText),
          hintStyle: TextStyle(
            fontSize: fontSize,
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
              fontSize: fontSize,
              height: 1.0,
            ),
        validator: validator,
      ),
    );
  }
}
