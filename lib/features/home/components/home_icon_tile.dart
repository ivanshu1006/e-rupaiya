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
    this.iconSize = 35,
    this.asset,
    this.offer,
  });

  final String label;
  final VoidCallback? onTap;
  final double iconSize;
  final String? asset;
  final int? offer;

  @override
  Widget build(BuildContext context) {
    final isSingleWord =
        !label.contains(' ') && !label.contains('\n') && label.length > 6;
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 64.r,
                width: 64.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.4),
                    width: 1.4,
                  ),
                  color: Colors.white,
                  boxShadow: const [
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
                      'Up To ₹$offer',
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
          SizedBox(height: 8.h),
          SizedBox(
            width: 64.r,
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
                      style: AppTextStyles.bodySmallSemibold(context),
                    ),
                  )
                : Text(
                    label,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmallSemibold(context),
                  ),
          ),
        ],
      ),
    );
  }
}
