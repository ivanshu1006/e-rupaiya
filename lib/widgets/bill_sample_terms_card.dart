// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/file_constants.dart';

class BillSampleTermsCard extends StatelessWidget {
  const BillSampleTermsCard({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Bill Sample & Terms conditions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textPrimary.withOpacity(0.6),
                  size: 20.sp,
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            SizedBox(height: 12.h),
            Text(
              'Bill Sample',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                FileConstants.sampleBill,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Terms conditions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Pricing: The price shown for the refill cylinder is an estimate. '
              'The final price will be determined and charged on the day of delivery.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Advance Payment: The amount you pay now is an advance deposit. '
              'This amount will be adjusted against the actual refill cost at the time of delivery.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Refunds for Overpayment: Any excess amount you paid will be promptly refunded to you.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Payment for Underpayment: If the actual cost is more than your advance payment, '
              'the remaining balance must be paid to the delivery person or electronically at the time of delivery.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Final Cost Documentation: The final cost of the refill will be clearly stated on the cash memo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.5,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Delivery Completion: Delivery is considered complete once the cylinder is handed over to you.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
