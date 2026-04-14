import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/custom_textfield.dart';

class GoldFormField extends StatelessWidget {
  const GoldFormField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.labelBackgroundColor,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final Color? labelBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 6.h),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: CustomTextField(
            labelText: null,
            enabled: true,
            textEditingController: controller,
            keyboardType: keyboardType,
            showBorder: false,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ],
    );
  }
}
