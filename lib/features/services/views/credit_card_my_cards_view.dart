// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/my_app_bar.dart';
import '../../home/controllers/home_controller.dart';
import '../../home/models/quick_actions_model.dart';
import '../controllers/biller_detail_controller.dart';
import '../models/biller_detail_args.dart';
import '../models/biller_model.dart';

class CreditCardMyCardsView extends HookConsumerWidget {
  const CreditCardMyCardsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final isFetching = homeState.isFetchingCreditCards;
    final cards = homeState.creditCardActions;

    useEffect(() {
      Future.microtask(() {
        ref.read(homeControllerProvider.notifier).fetchCreditCardActions();
      });
      return null;
    }, const []);

    // Once data is loaded and empty, replace this screen with biller listing
    final isLoaded = !isFetching && cards != null;
    useEffect(() {
      if (isLoaded && cards.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.pushReplacement(RouteConstants.creditCardListing);
          }
        });
      }
      return null;
    }, [isLoaded]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: 'My Cards',
            showHelp: true,
            onBack: () => context.pop(),
            onHelp: () {},
          ),
          Expanded(
            child: isFetching || cards == null || cards.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        SizedBox(height: 12.h),
                        ...cards.map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: _CreditCardTile(
                              item: item,
                              onTap: () {
                                final billerName =
                                    item.billerName?.trim().isNotEmpty == true
                                        ? item.billerName!.trim()
                                        : 'Card';
                                final biller = Biller(
                                  billerId: item.billerId ?? '',
                                  billerName: billerName,
                                  icon: item.icon,
                                );
                                ref
                                    .read(
                                        billerDetailControllerProvider.notifier)
                                    .selectBiller(biller);
                                context.push(
                                  RouteConstants.billerDetail,
                                  extra: BillerDetailArgs(
                                    biller: biller,
                                    isCreditCard: true,
                                    paymentType: 'Credit card',
                                  ),
                                );
                              },
                              onMenuTap: () => _openCardActions(item),
                            ),
                          ),
                        ),
                        SizedBox(height: 22.h),
                        CustomElevatedButton(
                          onPressed: () =>
                              context.push(RouteConstants.creditCardListing),
                          label: 'Add New Card',
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

  void _openCardActions(Data item) {
    KDialog.instance.openSheet(
      dialog: _CardActionSheet(item: item),
    );
  }
}

class _CreditCardTile extends StatelessWidget {
  const _CreditCardTile({
    required this.item,
    required this.onTap,
    required this.onMenuTap,
  });

  final Data item;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final bankName = item.billerName?.trim().isNotEmpty == true
        ? item.billerName!.trim()
        : 'Card';
    final masked = _maskedId(item.billerId);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    FileConstants.credit,
                    width: 18.w,
                    height: 18.w,
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
                      bankName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      masked,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 56.w,
                height: 48.h,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14.r),
                  child: InkWell(
                    onTap: onMenuTap,
                    borderRadius: BorderRadius.circular(14.r),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _maskedId(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return 'XXXX1234';
    final suffix =
        value.length >= 4 ? value.substring(value.length - 4) : value;
    return 'XXXX$suffix';
  }
}

class _CardActionSheet extends StatelessWidget {
  const _CardActionSheet({required this.item});

  final Data item;

  @override
  Widget build(BuildContext context) {
    final bankName = item.billerName?.trim().isNotEmpty == true
        ? item.billerName!.trim()
        : 'Card';
    final masked = _maskedId(item.billerId);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bankName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      masked,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(color: AppColors.lightBorder),
          _SheetActionRow(
            icon: Icons.history,
            label: 'History',
            onTap: () => Navigator.of(context).pop(),
          ),
          const Divider(color: AppColors.lightBorder),
          _SheetActionRow(
            icon: Icons.delete_outline,
            label: 'Remove Card',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String _maskedId(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return 'XXXX1234';
    final suffix =
        value.length >= 4 ? value.substring(value.length - 4) : value;
    return 'XXXX$suffix';
  }
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.lightBorder.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14.sp, color: AppColors.textPrimary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
