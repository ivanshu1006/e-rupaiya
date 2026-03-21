// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';

class QuickActionHeaderCard extends StatelessWidget {
  const QuickActionHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingAsset,
    this.leadingImageUrl,
    this.onTap,
    this.actionLabel,
    this.onAction,
    this.actionBackgroundAsset,
  });

  final String title;
  final String subtitle;
  final String? leadingAsset;
  final String? leadingImageUrl;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? actionBackgroundAsset;

  @override
  Widget build(BuildContext context) {
    final hasAction = (actionLabel ?? '').trim().isNotEmpty;
    final bgAsset = actionBackgroundAsset ?? FileConstants.quickAction;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        constraints: BoxConstraints(minHeight: 72.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12.w, top: 8.h, bottom: 8.h),
              child: CircleAvatar(
                radius: 26.r,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: _LeadingIcon(
                  asset: leadingAsset,
                  url: leadingImageUrl,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 13.sp,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.65),
                            fontSize: 11.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (hasAction)
              SizedBox(
                width: 88.w,
                height: 72.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18.r),
                    bottomRight: Radius.circular(18.r),
                  ),
                  child: InkWell(
                    onTap: onAction ?? onTap,
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          bgAsset,
                          fit: BoxFit.fill,
                        ),
                        Center(
                          child: Text(
                            actionLabel!,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  fontSize: 11.sp,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.asset,
    required this.url,
  });

  final String? asset;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final resolvedAsset = (asset ?? '').trim();
    final resolvedUrl = (url ?? '').trim();

    if (resolvedAsset.isNotEmpty) {
      return Image.asset(
        resolvedAsset,
        width: 34,
        height: 34,
        fit: BoxFit.contain,
      );
    }

    if (resolvedUrl.isEmpty) {
      return Icon(
        Icons.flash_on_outlined,
        color: AppColors.primary.withOpacity(0.7),
        size: 24,
      );
    }

    final isSvg = resolvedUrl.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return SvgPicture.network(
        resolvedUrl,
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        colorFilter: null,
        placeholderBuilder: (_) => _fallbackPlaceholder(context),
      );
    }
    return Image.network(
      resolvedUrl,
      width: 34,
      height: 34,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallbackPlaceholder(context),
    );
  }

  Widget _fallbackPlaceholder(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      color: AppColors.primary.withOpacity(0.08),
      child: Icon(
        Icons.wifi_calling_3_outlined,
        color: AppColors.primary.withOpacity(0.6),
        size: 24,
      ),
    );
  }
}
