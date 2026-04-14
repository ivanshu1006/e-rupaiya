// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../models/digital_metal.dart';

class DigitalGoldSuccessView extends StatelessWidget {
  const DigitalGoldSuccessView({
    super.key,
    this.metal = DigitalMetal.gold,
  });

  final DigitalMetal metal;

  @override
  Widget build(BuildContext context) {
    final theme = DigitalMetalTheme.of(metal);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: theme.valueCardGradient),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                FileConstants.designTop,
                fit: BoxFit.contain,
                height: 100.h,
                width: 200.w,
                color: theme.designTopTint,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(Icons.arrow_back,
                            color: AppColors.textPrimary, size: 22.r),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.help_outline,
                            color: AppColors.textPrimary, size: 22.r),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Image.asset(
                    FileConstants.digitalCoin,
                    height: 90.h,
                    width: 130.w,
                  ),
                ),
                Text(
                  '${theme.label} Added Successfully',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: theme.successTitleColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Great Choice! Your ${theme.label} Is Now Safely Stored.\nKeep Investing And Grow Your Wealth.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.successAccentColor.withOpacity(0.7),
                      ),
                ),
                SizedBox(height: 14.h),
                Text(
                  '₹500',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.successTitleColor,
                      ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.taxBadgeColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'Includes 3% Tax',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _GoldActionButton(
                          label: 'View ${theme.label}',
                          icon: FileConstants.viewGold,
                          onPressed: () => context.go(
                            '${RouteConstants.digitalGoldLocker}?metal=${theme.queryValue}',
                          ),
                          gradient: theme.successButtonGradient,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _GoldActionButton(
                          label: 'Buy More',
                          icon: FileConstants.buyMore,
                          onPressed: () => context.go(
                            '${RouteConstants.digitalGold}?metal=${theme.queryValue}',
                          ),
                          gradient: theme.successButtonGradient,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                    child: CustomElevatedButton(
                      onPressed: () => context.go(RouteConstants.digitalGold),
                      label: 'Go to Dashboard',
                      uppercaseLabel: false,
                      height: 42.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldActionButton extends StatelessWidget {
  const _GoldActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.gradient,
  });

  final String label;
  final String icon;
  final VoidCallback onPressed;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 26.w, height: 26.w),
              SizedBox(width: 6.w),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8A4D18),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
