// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/my_app_bar.dart';
import '../../home/controllers/home_tab_controller.dart';
import '../controllers/transaction_history_controller.dart';
import '../models/transaction_history_entry.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(transactionHistoryControllerProvider.notifier)
          .fetchHistory(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(transactionHistoryControllerProvider);
    final controller = ref.read(transactionHistoryControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _FilterFab(
        onPressed: () {
          _openFilterSheet(
            context,
            controller: controller,
            selectedDays: historyState.selectedDays,
            selectedLastYears: historyState.selectedLastYears,
            selectedRange: historyState.selectedRange,
          );
        },
      ),
      body: Column(
        children: [
          MyAppBar(
            title: 'Transaction History',
            showHelp: true,
            onBack: () {
              if (context.canPop()) {
                context.pop();
                return;
              }
              ref.read(homeTabControllerProvider).index = 0;
            },
            onHelp: () {},
          ),
          Expanded(
            child: historyState.isLoading
                ? const _TransactionHistoryShimmer()
                : historyState.items.isEmpty
                    ? const _TransactionEmptyState()
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TransactionFilterRow(
                              selectedDays: historyState.selectedDays,
                              selectedRange: historyState.selectedRange,
                              selectedLastYears: historyState.selectedLastYears,
                              onTap: () {
                                _openFilterSheet(
                                  context,
                                  controller: controller,
                                  selectedDays: historyState.selectedDays,
                                  selectedLastYears:
                                      historyState.selectedLastYears,
                                  selectedRange: historyState.selectedRange,
                                );
                              },
                            ),
                            SizedBox(height: 12.h),
                            ...historyState.items.map(
                              (item) => Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _TransactionTile(
                                  item: item,
                                  onTap: () {
                                    context
                                        .push(RouteConstants.transactionDetail);
                                  },
                                ),
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

class _TransactionFilterRow extends StatelessWidget {
  const _TransactionFilterRow({
    required this.selectedDays,
    required this.selectedRange,
    this.selectedLastYears,
    required this.onTap,
  });

  final int selectedDays;
  final DateTimeRange? selectedRange;
  final int? selectedLastYears;
  final VoidCallback onTap;

  String _formatLabel() {
    if (selectedLastYears != null) {
      return 'Last ${selectedLastYears!} years';
    }
    if (selectedRange == null) {
      return 'Last $selectedDays days';
    }
    final start = selectedRange!.start;
    final end = selectedRange!.end;
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'All Transactions',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Text(
                  _formatLabel(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.sp,
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item, required this.onTap});

  final TransactionHistoryEntry item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amount = item.amount.trim();
    final displayAmount =
        amount.isEmpty ? '' : (amount.startsWith('₹') ? amount : '₹ $amount');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppNetworkImage(
                    url: item.iconUrl,
                    width: 18.w,
                    height: 18.w,
                    fit: BoxFit.contain,
                    showShimmer: false,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.paymentType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.billerName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                displayAmount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterFab extends StatelessWidget {
  const _FilterFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.filter_list, color: Colors.white),
      label: Text(
        'Filters',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

Future<void> _openFilterSheet(
  BuildContext context, {
  required TransactionHistoryController controller,
  required int selectedDays,
  required int? selectedLastYears,
  required DateTimeRange? selectedRange,
}) async {
  KDialog.instance.openSheet(
    dialog: _TransactionFilterSheet(
      selectedDays: selectedDays,
      selectedLastYears: selectedLastYears,
      selectedRange: selectedRange,
      onSelectDays: (days) {
        Navigator.of(context).pop();
        controller.applyDaysFilter(days);
      },
      onSelectLastYears: (years) {
        Navigator.of(context).pop();
        controller.applyLastYears(years);
      },
      onSelectRange: (range) {
        Navigator.of(context).pop();
        controller.applyDateRange(range);
      },
    ),
  );
}

class _TransactionFilterSheet extends StatefulWidget {
  const _TransactionFilterSheet({
    required this.selectedDays,
    this.selectedLastYears,
    required this.selectedRange,
    required this.onSelectDays,
    required this.onSelectLastYears,
    required this.onSelectRange,
  });

  final int selectedDays;
  final int? selectedLastYears;
  final DateTimeRange? selectedRange;
  final ValueChanged<int> onSelectDays;
  final ValueChanged<int> onSelectLastYears;
  final ValueChanged<DateTimeRange> onSelectRange;

  @override
  State<_TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: widget.selectedRange,
    );
    if (picked != null) {
      widget.onSelectRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Divider(color: AppColors.lightBorder.withOpacity(0.7)),
          _FilterOption(
            label: 'Last 30 days',
            selected: widget.selectedRange == null && widget.selectedDays == 30,
            onTap: () => widget.onSelectDays(30),
          ),
          _FilterOption(
            label: 'Last 60 days',
            selected: widget.selectedRange == null && widget.selectedDays == 60,
            onTap: () => widget.onSelectDays(60),
          ),
          _FilterOption(
            label: 'Last 90 days',
            selected: widget.selectedRange == null && widget.selectedDays == 90,
            onTap: () => widget.onSelectDays(90),
          ),
          _FilterOption(
            label: 'Last 180 days',
            selected:
                widget.selectedRange == null && widget.selectedDays == 180,
            onTap: () => widget.onSelectDays(180),
          ),
          _FilterOption(
            label: 'Last 4 years',
            selected: widget.selectedLastYears == 4,
            onTap: () => widget.onSelectLastYears(4),
          ),
          _FilterOption(
            label: 'Custom date range',
            selected: widget.selectedRange != null,
            onTap: _pickRange,
          ),
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.onTap,
    required this.selected,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: Icon(
        selected ? Icons.check_circle : Icons.arrow_forward,
        color: selected ? AppColors.primary : AppColors.textPrimary,
      ),
      onTap: onTap,
    );
  }
}

class _TransactionEmptyState extends StatelessWidget {
  const _TransactionEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  FileConstants.erupaiya_3d,
                  width: 56.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'No Transactions Found.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Once You Make A Payment Or Receive Funds,\n'
              'Your History Will Appear Here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.6),
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionHistoryShimmer extends StatelessWidget {
  const _TransactionHistoryShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
      child: Column(
        children: List.generate(
          6,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: AppColors.lightBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
