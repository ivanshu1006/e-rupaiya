// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/screen_wrapper.dart';
import '../../../widgets/search_textfield.dart';
import '../controllers/biller_detail_controller.dart';
import '../controllers/biller_listing_controller.dart';
import '../models/biller_detail_args.dart';
import '../models/biller_model.dart';

class CreditCardListingView extends HookConsumerWidget {
  const CreditCardListingView({super.key});

  static const String _categoryName = 'Credit Card';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingState = ref.watch(billerListingControllerProvider);
    final searchController = useTextEditingController();

    useEffect(() {
      Future.microtask(() {
        ref
            .read(billerListingControllerProvider.notifier)
            .fetchBillers(categoryName: _categoryName);
        searchController.clear();
        ref.read(billerListingControllerProvider.notifier).updateSearch('');
      });
      return null;
    }, const []);

    final billers = listingState.filteredBillers;
    final topPicks = billers.take(6).toList();
    final remaining = billers.skip(topPicks.length).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: 'Select Your Bank',
            onBack: () => context.pop(),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Image.asset(
                FileConstants.bharatConnect,
                height: 22,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: SearchTextfield(
              hintText: 'Search bank name',
              controller: searchController,
              onChange: (value) => ref
                  .read(billerListingControllerProvider.notifier)
                  .updateSearch(value),
            ),
          ),
          Expanded(
            child: ScreenWrapper(
              isFetching: listingState.isFetching,
              isEmpty: billers.isEmpty,
              emptyMessage: 'No providers found',
              errorMessage: listingState.errorMessage,
              actions: listingState.errorMessage != null
                  ? [
                      TextButton(
                        onPressed: () => ref
                            .read(billerListingControllerProvider.notifier)
                            .fetchBillers(categoryName: _categoryName),
                        child: const Text('Retry'),
                      ),
                    ]
                  : null,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 0),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topPicks.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          final biller = topPicks[index];
                          return _BillerGridTile(
                            biller: biller,
                            onTap: () {
                              ref
                                  .read(billerDetailControllerProvider.notifier)
                                  .selectBiller(biller);
                              context.push(
                                RouteConstants.billerDetail,
                                extra: BillerDetailArgs(
                                  biller: biller,
                                  isCreditCard: true,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: remaining.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: AppColors.lightBorder.withOpacity(0.5),
                        ),
                        itemBuilder: (context, index) {
                          final biller = remaining[index];
                          return _BillerListTile(
                            biller: biller,
                            onTap: () {
                              ref
                                  .read(billerDetailControllerProvider.notifier)
                                  .selectBiller(biller);
                              context.push(
                                RouteConstants.billerDetail,
                                extra: BillerDetailArgs(
                                  biller: biller,
                                  isCreditCard: true,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillerGridTile extends StatelessWidget {
  const _BillerGridTile({required this.biller, this.onTap});

  final Biller biller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BillerIcon(
              name: biller.billerName,
              iconUrl: biller.iconUrl,
              size: 36,
              backgroundColor: AppColors.gradientStart.withOpacity(0.5),
              isCircle: true,
            ),
            const SizedBox(height: 10),
            Text(
              biller.billerName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillerListTile extends StatelessWidget {
  const _BillerListTile({required this.biller, this.onTap});

  final Biller biller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            _BillerIcon(
              name: biller.billerName,
              iconUrl: biller.iconUrl,
              size: 36,
              backgroundColor: Colors.white,
              isCircle: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                biller.billerName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textPrimary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillerIcon extends StatelessWidget {
  const _BillerIcon({
    required this.name,
    required this.iconUrl,
    required this.size,
    required this.backgroundColor,
    this.isCircle = false,
  });

  final String name;
  final String? iconUrl;
  final double size;
  final Color backgroundColor;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '';
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isCircle ? size / 2 : 10),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );

    if (iconUrl == null || iconUrl!.isEmpty) {
      return fallback;
    }

    return AppNetworkImage(
      url: iconUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(isCircle ? size / 2 : 10),
      placeholder: fallback,
      errorWidget: fallback,
    );
  }
}
