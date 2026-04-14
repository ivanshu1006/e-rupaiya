import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/custom_elevated_button.dart';

class GoldProceedButton extends StatelessWidget {
  const GoldProceedButton({
    super.key,
    required this.onPressed,
    this.label = 'Proceed',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onPressed: onPressed,
      label: label,
      height: 42.h,
      uppercaseLabel: false,
    );
  }
}
