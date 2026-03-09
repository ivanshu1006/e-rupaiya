// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/screen_wrapper.dart';
import '../../../widgets/search_textfield.dart';
import '../controllers/biller_detail_controller.dart';
import '../controllers/biller_listing_controller.dart';
import '../models/biller_detail_args.dart';
import '../models/biller_model.dart';

class BillerListingView extends HookConsumerWidget {
  const BillerListingView({super.key, required this.categoryName});

  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingState = ref.watch(billerListingControllerProvider);
    final searchController = useTextEditingController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(billerListingControllerProvider.notifier).updateSearch('');
        searchController.clear();
        ref
            .read(billerListingControllerProvider.notifier)
            .fetchBillers(categoryName: categoryName);
      });
      return null;
    }, [categoryName]);

    useEffect(() {
      searchController.text = listingState.searchQuery;
      if (listingState.searchQuery.isNotEmpty) {
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: listingState.searchQuery.length),
        );
      }
      return null;
    }, [listingState.searchQuery]);

    final billers = listingState.filteredBillers;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: 'Fetch Your Provider',
            showHelp: true,
            onBack: () => context.pop(),
            onHelp: () {},
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchTextfield(
              hintText: 'Search Service',
              controller: searchController,
              onChange: (value) => ref
                  .read(billerListingControllerProvider.notifier)
                  .updateSearch(value),
            ),
          ),

          // List
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
                            .fetchBillers(categoryName: categoryName),
                        child: const Text('Retry'),
                      ),
                    ]
                  : null,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: billers.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: AppColors.lightBorder.withOpacity(0.5),
                ),
                itemBuilder: (context, index) {
                  return _BillerTile(
                    biller: billers[index],
                    onTap: () {
                      ref
                          .read(billerDetailControllerProvider.notifier)
                          .selectBiller(billers[index]);
                      context.push(
                        RouteConstants.billerDetail,
                        extra: BillerDetailArgs(
                          biller: billers[index],
                          paymentType: categoryName,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillerTile extends StatelessWidget {
  const _BillerTile({required this.biller, this.onTap});

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
            // Provider logo placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gradientStart.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _BillerIcon(
                name: biller.billerName,
                iconUrl: biller.iconUrl,
                size: 40,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                biller.billerName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
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
    required this.borderRadius,
  });

  final String name;
  final String? iconUrl;
  final double size;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '';
    final fallback = Center(
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
      borderRadius: borderRadius,
      placeholder: fallback,
      errorWidget: fallback,
    );
  }
}
