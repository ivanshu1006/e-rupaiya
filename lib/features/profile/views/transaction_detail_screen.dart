// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../models/transaction_item.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, this.item});

  final TransactionItem? item;

  @override
  Widget build(BuildContext context) {
    final tx = item ??
        TransactionItem(
          id: 't1',
          title: 'Mobile Recharge',
          subtitle: 'Airtel Prepaid',
          amount: '₹ 435',
          dateTime: '30 Sep 2025, 05:02pm',
          status: 'success',
          iconAsset: FileConstants.mobile,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _TransactionDetailHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TransactionSummaryCard(item: tx),
                  SizedBox(height: 16.h),
                  const _TransactionInfoSection(
                    title: 'Payment Details',
                    rows: [
                      _InfoRow(
                          label: 'Transaction ID',
                          value: 'TXNID2025101200123456'),
                      _InfoRow(label: 'Reference ID', value: '123456789'),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const _TransactionInfoSection(
                    title: 'Payment Option Details',
                    rows: [
                      _InfoRow(label: 'UPI', value: 'sample007@ybl'),
                      _InfoRow(label: 'UTR', value: '123456789012'),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                          onPressed: () {},
                          label: 'Share Receipt',
                          height: 44.h,
                          uppercaseLabel: false,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CustomElevatedButton(
                          onPressed: () {},
                          label: 'Download',
                          height: 44.h,
                          uppercaseLabel: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  CustomElevatedButton(
                    onPressed: () {
                      context.push(RouteConstants.helpCenterChat);
                    },
                    label: 'Help Center',
                    height: 46.h,
                    uppercaseLabel: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionDetailHeader extends StatelessWidget {
  const _TransactionDetailHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 14.h, 16.w, 16.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1AAE57), Color(0xFF0C8F45)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                'Transaction Successful',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSummaryCard extends StatelessWidget {
  const _TransactionSummaryCard({required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                item.dateTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.lightBorder.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      item.iconAsset,
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '1234567890',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.amount,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
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

class _TransactionInfoSection extends StatelessWidget {
  const _TransactionInfoSection({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: rows
                .map(
                  (row) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            row.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textPrimary.withOpacity(0.6),
                                ),
                          ),
                        ),
                        Text(
                          row.value,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.copy_rounded,
                          size: 16.sp,
                          color: AppColors.textPrimary.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;
}
