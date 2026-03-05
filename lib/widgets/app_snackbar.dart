import 'package:e_rupaiya/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppSnackbar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry? margin,
  }) {
    final snackBar = SnackBar(
      margin: behavior == SnackBarBehavior.floating
          ? (margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8))
          : null,
      behavior: behavior,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: backgroundColor ?? AppColors.gradientStart,
      duration: const Duration(seconds: 2),
      content: Text(
        message,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    messengerKey.currentState
      ?..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
