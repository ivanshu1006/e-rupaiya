import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/custom_elevated_button.dart';

class GoldProceedButton extends StatelessWidget {
  const GoldProceedButton({
    super.key,
    required this.onPressed,
    this.label = 'Proceed',
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onPressed: isLoading ? null : onPressed,
      label: label,
      height: 42.h,
      uppercaseLabel: false,
      isLoading: isLoading,
    );
  }
}
