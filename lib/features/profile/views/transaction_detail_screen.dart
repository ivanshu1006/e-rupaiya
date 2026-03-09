// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/k_action_button.dart';
import '../../../widgets/my_app_bar.dart';
import '../models/transaction_history_entry.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, this.entry});

  final TransactionHistoryEntry? entry;

  @override
  Widget build(BuildContext context) {
    final tx = entry ??
        const TransactionHistoryEntry(
          paymentStatus: '',
          paymentType: '',
          billerName: '',
          amount: '',
          iconUrl: '',
          transactionId: '',
          referenceId: '',
          transactionTime: '',
        );
    final statusMeta = _statusMeta(tx.paymentStatus);
    final infoRows = <_InfoRow>[
      _InfoRow(label: 'Recharge Amount', value: _formatAmount(tx.amount)),
      // ignore: prefer_const_constructors
      _InfoRow(label: 'E-Coins', value: '-₹ 0'),
      _InfoRow(
        label: 'Total Amount',
        value: _formatAmount(tx.amount),
        emphasize: true,
      ),
    ];
    final txnId = tx.transactionId.trim();
    final refId = tx.referenceId.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: statusMeta.label,
            height: 150,
            backgroundColor: statusMeta.color,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TransactionSummaryCard(item: tx),
                  SizedBox(height: 16.h),
                  _TransactionInfoSection(
                    title: 'Payment Details',
                    rows: infoRows,
                  ),
                  SizedBox(height: 10.h),
                  if (txnId.isNotEmpty)
                    _CopyRow(
                      label: 'UPI Transaction ID',
                      value: txnId,
                    ),
                  if (refId.isNotEmpty)
                    _CopyRow(
                      label: 'Reference ID',
                      value: refId,
                    ),
                  SizedBox(height: 10.h),
                  _PaidFromRow(),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Expanded(
                        child: KActionButton(
                          label: 'Share Receipt',
                          icon: Icons.share_outlined,
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: KActionButton(
                          label: 'View Receipt',
                          icon: Icons.receipt_long_outlined,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  KActionButton(
                    label: 'Contact Support',
                    icon: Icons.headset_mic_outlined,
                    onPressed: () =>
                        context.push(RouteConstants.helpCenterChat),
                  ),
                  SizedBox(height: 14.h),
                  _PoweredByRow(),
                  SizedBox(height: 18.h),
                  CustomElevatedButton(
                    onPressed: () => context.push(RouteConstants.mobilePrepaid),
                    label: 'Recharge Again',
                    height: 48.h,
                    uppercaseLabel: false,
                    showArrow: false,
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

class _TransactionSummaryCard extends StatelessWidget {
  const _TransactionSummaryCard({required this.item});

  final TransactionHistoryEntry item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
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
                  item.paymentType.isNotEmpty
                      ? item.paymentType
                      : 'Mobile Recharged',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                _formatTxnTime(item.transactionTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.4),
                  ),
                ),
                child: Center(
                  child: AppNetworkImage(
                    url: item.iconUrl,
                    width: 24.w,
                    height: 24.w,
                    fit: BoxFit.contain,
                    showShimmer: false,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.billerName.isNotEmpty ? item.billerName : 'Biller',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.referenceId.isNotEmpty
                          ? item.referenceId
                          : 'Reference ID',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatAmount(item.amount),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
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
                fontSize: 15.sp,
              ),
        ),
        SizedBox(height: 10.h),
        Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        rows[i].label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: rows[i].emphasize
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimary.withOpacity(0.6),
                              fontWeight: rows[i].emphasize
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: rows[i].emphasize ? 13.sp : 12.sp,
                            ),
                      ),
                    ),
                    Text(
                      rows[i].value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: rows[i].emphasize
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: rows[i].emphasize ? 13.sp : 12.sp,
                          ),
                    ),
                  ],
                ),
              ),
              if (i == 1) ...[
                Divider(
                  color: AppColors.lightBorder.withOpacity(0.8),
                  height: 12.h,
                ),
              ],
            ],
          ],
        ),
      ],
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.label,
    required this.value,
    this.canCopy = false,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool canCopy;
  final bool emphasize;
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.6),
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: value));
              AppSnackbar.show('Copied to clipboard');
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Row(
                children: [
                  Icon(
                    Icons.copy_rounded,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Copy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
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

class _PaidFromRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
      child: Row(
        children: [
          Text(
            'Paid From',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(width: 8.w),
          Image.asset(
            FileConstants.upi,
            width: 18.w,
            height: 18.w,
          ),
          SizedBox(width: 6.w),
          Text(
            'GPAY',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PoweredByRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'powered by',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary.withOpacity(0.6),
              ),
        ),
        SizedBox(width: 6.w),
        Image.asset(
          FileConstants.bharatConnectColor,
          height: 16.h,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _StatusMeta {
  const _StatusMeta({required this.label, required this.color});

  final String label;
  final Color color;
}

_StatusMeta _statusMeta(String rawStatus) {
  final status = rawStatus.trim().toUpperCase();
  switch (status) {
    case 'SUCCESS':
      return const _StatusMeta(
        label: 'Transaction Successful',
        color: Color(0xFF1AAE57),
      );
    case 'PENDING':
      return const _StatusMeta(
        label: 'Transaction Pending',
        color: Color(0xFFF59E0B),
      );
    case 'FAILED':
    case 'FAIL':
      return const _StatusMeta(
        label: 'Transaction Failed',
        color: Color(0xFFE53935),
      );
    default:
      return const _StatusMeta(
        label: 'Transaction Details',
        color: Color(0xFF1AAE57),
      );
  }
}

String _formatAmount(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.startsWith('₹') ? trimmed : '₹ $trimmed';
}

String _formatTxnTime(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  final normalized = value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
  final parsed = DateTime.tryParse(normalized);
  if (parsed == null) return value;
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final day = parsed.day.toString().padLeft(2, '0');
  final month = months[parsed.month - 1];
  final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  final minute = parsed.minute.toString().padLeft(2, '0');
  final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
  return '$day $month ${parsed.year}, $hour:$minute$ampm';
}
