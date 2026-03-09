// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import '../../../constants/app_colors.dart';
// import '../../../constants/file_constants.dart';
// import '../../../constants/routes_constant.dart';
// import '../../../widgets/app_network_image.dart';
// import '../../../widgets/k_dialog.dart';
// import '../../../widgets/my_app_bar.dart';
// import '../../home/controllers/home_tab_controller.dart';
// import '../controllers/transaction_history_controller.dart';
// import '../models/transaction_history_entry.dart';

// class TransactionHistoryScreen extends ConsumerStatefulWidget {
//   const TransactionHistoryScreen({super.key});

//   @override
//   ConsumerState<TransactionHistoryScreen> createState() =>
//       _TransactionHistoryScreenState();
// }

// class _TransactionHistoryScreenState
//     extends ConsumerState<TransactionHistoryScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(
//       () => ref
//           .read(transactionHistoryControllerProvider.notifier)
//           .fetchHistory(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final historyState = ref.watch(transactionHistoryControllerProvider);
//     final controller = ref.read(transactionHistoryControllerProvider.notifier);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: _FilterFab(
//         onPressed: () {
//           _openFilterSheet(
//             context,
//             controller: controller,
//             selectedDays: historyState.selectedDays,
//             selectedLastYears: historyState.selectedLastYears,
//             selectedRange: historyState.selectedRange,
//           );
//         },
//       ),
//       body: Column(
//         children: [
//           MyAppBar(
//             title: 'Transaction History',
//             showHelp: true,
//             onBack: () {
//               if (context.canPop()) {
//                 context.pop();
//                 return;
//               }
//               ref.read(homeTabControllerProvider).index = 0;
//             },
//             onHelp: () {},
//           ),
//           Expanded(
//             child: historyState.isLoading
//                 ? const _TransactionHistoryShimmer()
//                 : historyState.items.isEmpty
//                     ? const _TransactionEmptyState()
//                     : CustomScrollView(
//                         slivers: [
//                           SliverPadding(
//                             padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0.h),
//                             sliver: SliverToBoxAdapter(
//                               child: _TransactionFilterRow(
//                                 selectedDays: historyState.selectedDays,
//                                 selectedRange: historyState.selectedRange,
//                                 selectedLastYears:
//                                     historyState.selectedLastYears,
//                                 onTap: () {
//                                   _openFilterSheet(
//                                     context,
//                                     controller: controller,
//                                     selectedDays: historyState.selectedDays,
//                                     selectedLastYears:
//                                         historyState.selectedLastYears,
//                                     selectedRange: historyState.selectedRange,
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           SliverPadding(
//                             padding:
//                                 EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
//                             sliver: SliverList.separated(
//                               itemCount: historyState.items.length,
//                               separatorBuilder: (_, __) =>
//                                   SizedBox(height: 10.h),
//                               itemBuilder: (context, index) {
//                                 final item = historyState.items[index];
//                                 return _TransactionTile(
//                                   item: item,
//                                   onTap: () {
//                                     context.push(
//                                       RouteConstants.transactionDetail,
//                                       extra: item,
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TransactionFilterRow extends StatelessWidget {
//   const _TransactionFilterRow({
//     required this.selectedDays,
//     required this.selectedRange,
//     this.selectedLastYears,
//     required this.onTap,
//   });

//   final int selectedDays;
//   final DateTimeRange? selectedRange;
//   final int? selectedLastYears;
//   final VoidCallback onTap;

//   String _formatLabel() {
//     if (selectedLastYears != null) {
//       return 'Last ${selectedLastYears!} years';
//     }
//     if (selectedRange == null) {
//       return 'Last $selectedDays days';
//     }
//     final start = selectedRange!.start;
//     final end = selectedRange!.end;
//     return '${_formatDate(start)} - ${_formatDate(end)}';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           'All Transactions',
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//         const Spacer(),
//         InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(8.r),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//             child: Row(
//               children: [
//                 Text(
//                   _formatLabel(),
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: AppColors.textPrimary.withOpacity(0.8),
//                         fontWeight: FontWeight.w600,
//                       ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Icon(
//                   Icons.keyboard_arrow_down,
//                   size: 18.sp,
//                   color: AppColors.textPrimary.withOpacity(0.7),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _TransactionTile extends StatelessWidget {
//   const _TransactionTile({required this.item, required this.onTap});

//   final TransactionHistoryEntry item;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final amount = item.amount.trim();
//     final displayAmount =
//         amount.isEmpty ? '' : (amount.startsWith('₹') ? amount : '₹ $amount');
//     return RepaintBoundary(
//       child: Material(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16.r),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border.all(color: AppColors.lightBorder),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 34.w,
//                   height: 34.w,
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.08),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: AppNetworkImage(
//                       url: item.iconUrl,
//                       width: 18.w,
//                       height: 18.w,
//                       fit: BoxFit.contain,
//                       showShimmer: false,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.paymentType,
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                               color: AppColors.textPrimary.withOpacity(0.7),
//                               fontWeight: FontWeight.w500,
//                             ),
//                       ),
//                       SizedBox(height: 2.h),
//                       Text(
//                         item.billerName,
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                               color: AppColors.textPrimary,
//                               fontWeight: FontWeight.w700,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   displayAmount,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: AppColors.textPrimary,
//                         fontWeight: FontWeight.w700,
//                       ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FilterFab extends StatelessWidget {
//   const _FilterFab({required this.onPressed});

//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton.extended(
//       onPressed: onPressed,
//       backgroundColor: AppColors.primary,
//       icon: const Icon(Icons.filter_list, color: Colors.white),
//       label: Text(
//         'Filters',
//         style: Theme.of(context).textTheme.labelLarge?.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.w700,
//             ),
//       ),
//     );
//   }
// }

// Future<void> _openFilterSheet(
//   BuildContext context, {
//   required TransactionHistoryController controller,
//   required int selectedDays,
//   required int? selectedLastYears,
//   required DateTimeRange? selectedRange,
// }) async {
//   KDialog.instance.openSheet(
//     dialog: _TransactionFilterSheet(
//       selectedDays: selectedDays,
//       selectedLastYears: selectedLastYears,
//       selectedRange: selectedRange,
//       onSelectDays: (days) {
//         Navigator.of(context).pop();
//         controller.applyDaysFilter(days);
//       },
//       onSelectLastYears: (years) {
//         Navigator.of(context).pop();
//         controller.applyLastYears(years);
//       },
//       onSelectRange: (range) {
//         Navigator.of(context).pop();
//         controller.applyDateRange(range);
//       },
//     ),
//   );
// }

// class _TransactionFilterSheet extends StatefulWidget {
//   const _TransactionFilterSheet({
//     required this.selectedDays,
//     this.selectedLastYears,
//     required this.selectedRange,
//     required this.onSelectDays,
//     required this.onSelectLastYears,
//     required this.onSelectRange,
//   });

//   final int selectedDays;
//   final int? selectedLastYears;
//   final DateTimeRange? selectedRange;
//   final ValueChanged<int> onSelectDays;
//   final ValueChanged<int> onSelectLastYears;
//   final ValueChanged<DateTimeRange> onSelectRange;

//   @override
//   State<_TransactionFilterSheet> createState() =>
//       _TransactionFilterSheetState();
// }

// class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
//   Future<void> _pickRange() async {
//     final now = DateTime.now();
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(now.year - 2),
//       lastDate: now,
//       initialDateRange: widget.selectedRange,
//     );
//     if (picked != null) {
//       widget.onSelectRange(picked);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   'Filters',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//           Divider(color: AppColors.lightBorder.withOpacity(0.7)),
//           _FilterOption(
//             label: 'Last 30 days',
//             selected: widget.selectedRange == null && widget.selectedDays == 30,
//             onTap: () => widget.onSelectDays(30),
//           ),
//           _FilterOption(
//             label: 'Last 60 days',
//             selected: widget.selectedRange == null && widget.selectedDays == 60,
//             onTap: () => widget.onSelectDays(60),
//           ),
//           _FilterOption(
//             label: 'Last 90 days',
//             selected: widget.selectedRange == null && widget.selectedDays == 90,
//             onTap: () => widget.onSelectDays(90),
//           ),
//           _FilterOption(
//             label: 'Last 180 days',
//             selected:
//                 widget.selectedRange == null && widget.selectedDays == 180,
//             onTap: () => widget.onSelectDays(180),
//           ),
//           _FilterOption(
//             label: 'Last 4 years',
//             selected: widget.selectedLastYears == 4,
//             onTap: () => widget.onSelectLastYears(4),
//           ),
//           _FilterOption(
//             label: 'Custom date range',
//             selected: widget.selectedRange != null,
//             onTap: _pickRange,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FilterOption extends StatelessWidget {
//   const _FilterOption({
//     required this.label,
//     required this.onTap,
//     required this.selected,
//   });

//   final String label;
//   final VoidCallback onTap;
//   final bool selected;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       title: Text(
//         label,
//         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//       ),
//       trailing: Icon(
//         selected ? Icons.check_circle : Icons.arrow_forward,
//         color: selected ? AppColors.primary : AppColors.textPrimary,
//       ),
//       onTap: onTap,
//     );
//   }
// }

// class _TransactionEmptyState extends StatelessWidget {
//   const _TransactionEmptyState();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 32.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 120.w,
//               height: 120.w,
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Image.asset(
//                   FileConstants.erupaiya_3d,
//                   width: 56.w,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             SizedBox(height: 18.h),
//             Text(
//               'No Transactions Found.',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: AppColors.textPrimary,
//                     fontWeight: FontWeight.w700,
//                   ),
//             ),
//             SizedBox(height: 6.h),
//             Text(
//               'Once You Make A Payment Or Receive Funds,\n'
//               'Your History Will Appear Here.',
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: AppColors.textPrimary.withOpacity(0.6),
//                     height: 1.5,
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TransactionHistoryShimmer extends StatelessWidget {
//   const _TransactionHistoryShimmer();

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
//       child: Column(
//         children: List.generate(
//           6,
//           (_) => Padding(
//             padding: EdgeInsets.only(bottom: 12.h),
//             child: Container(
//               height: 64.h,
//               decoration: BoxDecoration(
//                 color: AppColors.lightBorder.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/search_textfield.dart';
import '../../home/controllers/home_tab_controller.dart';
import '../controllers/transaction_history_controller.dart';
import '../models/transaction_history_entry.dart';
import '../models/transaction_history_filter.dart';
import 'transaction_filter_screen.dart';

// ✅ Pre-computed color constants — avoids withOpacity() in build methods
extension _AppColorExt on Color {
  static const Color primaryFaint =
      Color(0x14000000); // replace with actual primary at 0.08
  static const Color lightBorderFaint =
      Color(0x4D000000); // replace with actual lightBorder at 0.3
}

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionHistoryFilter? _activeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    // ✅ Use select() to avoid full rebuilds when unrelated state changes
    final isLoading = ref.watch(
      transactionHistoryControllerProvider.select((s) => s.isLoading),
    );
    final items = ref.watch(
      transactionHistoryControllerProvider.select((s) => s.items),
    );
    final selectedDays = ref.watch(
      transactionHistoryControllerProvider.select((s) => s.selectedDays),
    );
    final selectedLastYears = ref.watch(
      transactionHistoryControllerProvider.select((s) => s.selectedLastYears),
    );
    final selectedRange = ref.watch(
      transactionHistoryControllerProvider.select((s) => s.selectedRange),
    );

    final controller = ref.read(transactionHistoryControllerProvider.notifier);
    final query = _searchController.text.trim().toLowerCase();
    final filteredItems = query.isEmpty
        ? items
        : items.where((item) {
            final haystack =
                '${item.billerName} ${item.paymentType}'.toLowerCase();
            return haystack.contains(query);
          }).toList();
    final sections = _buildSections(filteredItems);

    return Scaffold(
      backgroundColor: Colors.white,
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
            child: isLoading
                ? const _TransactionHistoryShimmer()
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: SearchTextfield(
                                  hintText: 'Search Transactions',
                                  controller: _searchController,
                                  onChange: (_) => setState(() {}),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              SizedBox(
                                height: 46.h,
                                width: 46.h,
                                child: IconButton(
                                  onPressed: () {
                                    _openFilterScreen(controller);
                                  },
                                  icon: const Icon(
                                    Icons.tune,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (filteredItems.isEmpty)
                        const SliverToBoxAdapter(
                          child: _TransactionEmptyState(),
                        )
                      else ...[
                        for (final section in sections) ...[
                          SliverToBoxAdapter(
                            child: _MonthHeader(title: section.title),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = section.items[index];
                                return _TransactionTile(
                                  item: item,
                                  onTap: () {
                                    context.push(
                                      RouteConstants.transactionDetail,
                                      extra: item,
                                    );
                                  },
                                );
                              },
                              childCount: section.items.length,
                            ),
                          ),
                        ],
                        SliverToBoxAdapter(
                          child: SizedBox(height: 24.h),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterScreen(
    TransactionHistoryController controller,
  ) async {
    final result = await PersistentNavBarNavigator.pushDynamicScreen<
        TransactionHistoryFilter>(
      context,
      withNavBar: false,
      screen: MaterialPageRoute<TransactionHistoryFilter>(
        builder: (_) => TransactionFilterScreen(
          initialFilter: _activeFilter,
        ),
      ),
    );
    if (!mounted) return;
    if (result == null) return;
    _activeFilter = result;
    if (result.isEmpty) {
      await controller.fetchHistory();
    } else {
      await controller.applyFilter(result);
    }
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
    // ✅ Pre-compute styles outside child tree
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        );
    final filterLabelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary.withOpacity(0.8),
          fontWeight: FontWeight.w600,
        );

    return Row(
      children: [
        Text('All Transactions', style: labelStyle),
        const Spacer(),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Text(_formatLabel(), style: filterLabelStyle),
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

    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        );
    final subStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        );
    final amountStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        );

    final status = _resolveStatus(item.paymentStatus);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColors.lightBorder.withOpacity(0.8),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
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
                  width: 22.w,
                  height: 22.w,
                  fit: BoxFit.contain,
                  cacheWidth:
                      (22 * MediaQuery.devicePixelRatioOf(context)).toInt(),
                  cacheHeight:
                      (22 * MediaQuery.devicePixelRatioOf(context)).toInt(),
                  showShimmer: false,
                  fitToDeviceWidth: true,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.paymentType, style: titleStyle),
                  SizedBox(height: 4.h),
                  Text(_formatTxnTime(item.transactionTime), style: subStyle),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(displayAmount, style: amountStyle),
                SizedBox(height: 4.h),
                _StatusChip(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _TxnStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _TxnStatus.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paid From',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(width: 6.w),
            Image.asset(
              FileConstants.upi,
              width: 16.w,
              height: 16.w,
              fit: BoxFit.contain,
            ),
          ],
        );
      case _TxnStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.info_outline,
              size: 14.sp,
              color: Colors.red,
            ),
          ],
        );
      case _TxnStatus.processing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Processing',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.refresh,
              size: 14.sp,
              color: Colors.orange,
            ),
          ],
        );
    }
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F4F4),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

enum _TxnStatus { success, failed, processing }

_TxnStatus _resolveStatus(String raw) {
  final value = raw.trim().toLowerCase();
  if (value.contains('fail')) return _TxnStatus.failed;
  if (value.contains('process') || value.contains('pending')) {
    return _TxnStatus.processing;
  }
  return _TxnStatus.success;
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
  return '$day $month, $hour:$minute$ampm';
}

class _TxnSection {
  const _TxnSection({required this.title, required this.items});
  final String title;
  final List<TransactionHistoryEntry> items;
}

List<_TxnSection> _buildSections(List<TransactionHistoryEntry> items) {
  if (items.isEmpty) return const [];
  final sections = <String, List<TransactionHistoryEntry>>{};
  for (final item in items) {
    final key = _monthKey(item.transactionTime);
    sections.putIfAbsent(key, () => []).add(item);
  }
  return sections.entries
      .map((e) => _TxnSection(title: e.key, items: e.value))
      .toList();
}

String _monthKey(String raw) {
  final value = raw.trim();
  final normalized = value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
  final parsed = DateTime.tryParse(normalized);
  if (parsed == null) return 'Transactions';
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
  return '${months[parsed.month - 1]},${parsed.year}';
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
            SizedBox(
              width: 120.w,
              height: 120.w,
              child: DecoratedBox(
                // ✅ DecoratedBox instead of Container for paint-only decoration
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
    // ✅ Hoist shimmer color outside List.generate to avoid repeated withOpacity calls
    final shimmerColor = AppColors.lightBorder.withOpacity(0.3);
    final shimmerDecoration = BoxDecoration(
      color: shimmerColor,
      borderRadius: BorderRadius.circular(16.r),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
      child: Column(
        children: List.generate(
          6,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: DecoratedBox(
              // ✅ DecoratedBox instead of Container — no layout overhead
              decoration: shimmerDecoration,
              child: SizedBox(height: 64.h, width: double.infinity),
            ),
          ),
        ),
      ),
    );
  }
}
