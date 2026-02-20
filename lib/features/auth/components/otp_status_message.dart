import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpStatusMessage extends StatelessWidget {
  const OtpStatusMessage({
    super.key,
    required this.title,
    required this.subtitle,
    this.isSuccess = true,
  });

  final String title;
  final String subtitle;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? Colors.green : Colors.red;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isSuccess ? Icons.check_circle_outline : Icons.error_outline,
          color: color,
          size: 48.r,
        ),
        SizedBox(height: 12.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
