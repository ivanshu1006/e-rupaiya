import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class PolicySectionTitle extends StatelessWidget {
  const PolicySectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
