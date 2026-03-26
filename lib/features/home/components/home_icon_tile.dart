// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/file_constants.dart';

class HomeIconTile extends StatelessWidget {
  const HomeIconTile({
    super.key,
    required this.label,
    this.onTap,
    this.iconSize = 24,
    this.asset,
    this.offer,
    this.labelSpacing,
  });

  final String label;
  final VoidCallback? onTap;
  final double iconSize;
  final String? asset;
  final int? offer;
  final double? labelSpacing;

  @override
  Widget build(BuildContext context) {
    final isSingleWord =
        !label.contains(' ') && !label.contains('\n') && label.length > 6;
    final labelTextStyle = AppTextStyles.bodySmallSemibold(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 40.r,
                width: 40.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // border: Border.all(
                  //   color: AppColors.primary.withOpacity(0.4),
                  //   width: 1.4,
                  // ),
                  color: Color(0xffDEDEDE),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    asset ?? FileConstants.appLogo,
                    height: iconSize.r,
                    width: iconSize.r,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (offer != null)
                Positioned(
                  top: -4.h,
                  right: 7.w,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '₹$offer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: labelSpacing ?? 6.h),
          SizedBox(
            width: 68.r,
            child: isSingleWord
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: labelTextStyle,
                    ),
                  )
                : Text(
                    label,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: labelTextStyle,
                  ),
          ),
        ],
      ),
    );
  }
}
