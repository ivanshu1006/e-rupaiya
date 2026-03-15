// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:e_rupaiya/features/home/components/home_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../services/notification_badge_service.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../kyc/views/kyc_verification_view.dart';
import '../../mobile_prepaid/models/recharge_quick_action_payload.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/offers_view.dart';
import '../../profile/views/profile_view.dart';
import '../../profile/views/transaction_history_screen.dart';
import '../../refer_and_earn/views/refer_and_earn_view.dart';
import '../../services/controllers/biller_detail_controller.dart';
import '../../services/models/biller_detail_args.dart';
import '../../services/models/biller_model.dart';
import '../../spinandear/controllers/spin_options_controller.dart';
import '../components/home_icon_tile.dart';
import '../components/home_section_header.dart';
import '../components/quick_action_card.dart';
import '../components/service_utils.dart';
import '../controllers/home_controller.dart';
import '../controllers/home_tab_controller.dart';
import '../models/quick_action_model.dart';
import 'home_search_view.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = ref.watch(homeTabControllerProvider);
    final lastTabIndex = useRef<int>(tabController.index);
    final tabs = [
      const _HomeContent(),
      const OffersView(),
      // const ScanUserScreen(),
      SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Scan User Coming Soon',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      const TransactionHistoryScreen(),
      const ProfileView(),
    ];

    final navTextStyle = TextStyle(
        fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black);
    final navItems = [
      PersistentBottomNavBarItem(
        icon: _BottomIcon(asset: FileConstants.paybills, size: 20.r),
        title: 'Pay Bills',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(asset: FileConstants.offers, size: 20.r),
        title: 'Offers',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: _GradientFabIcon(asset: FileConstants.scanUser, size: 20.r),
        title: 'Scan User',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(asset: FileConstants.history, size: 20.r),
        title: 'History',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(asset: FileConstants.profile, size: 20.r),
        title: 'Profile',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
    ];
    useEffect(() {
      NotificationBadgeService.refreshCount();
      void listener() {
        final index = tabController.index;
        if (index == 0 && lastTabIndex.value != 0) {
          ref.read(profileControllerProvider.notifier).fetchProfile();
        }
        lastTabIndex.value = index;
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);
    return PersistentTabView(
      context,
      controller: tabController,
      screens: tabs,
      items: navItems,
      navBarStyle: NavBarStyle.style15,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(0),
        gradient: const LinearGradient(
          colors: [Color(0xffFFEAE3), Color(0xffF6F4F3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        colorBehindNavBar: AppColors.gradientStart,
      ),
      navBarHeight: 65.h,
      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
      backgroundColor: Colors.white,
      hideNavigationBarWhenKeyboardAppears: true,
      confineToSafeArea: true,
    );

    // return PersistentTabView(
    //   context,
    //   screens: tabs,
    //   items: navItems,
    //   navBarStyle: NavBarStyle.style15,
    //   decoration: NavBarDecoration(
    //     borderRadius: BorderRadius.circular(0),
    //     gradient: const LinearGradient(
    //       colors: [Color(0xffFFEAE3), Color(0xffF6F4F3)],
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //     ),
    //     colorBehindNavBar: AppColors.gradientStart,
    //   ),
    //   handleAndroidBackButtonPress: true, // Default is true.
    //   resizeToAvoidBottomInset:
    //       true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
    //   stateManagement: true, // Default is true.
    //   hideNavigationBarWhenKeyboardAppears: true,
    //   padding: const EdgeInsets.only(top: 2),
    //   backgroundColor: Colors.grey.shade900,
    //   isVisible: true,
    //   animationSettings: const NavBarAnimationSettings(
    //     navBarItemAnimation: ItemAnimationSettings(
    //       // Navigation Bar's items animation properties.
    //       duration: Duration(milliseconds: 400),
    //       curve: Curves.ease,
    //     ),
    //     screenTransitionAnimation: ScreenTransitionAnimationSettings(
    //       // Screen transition animation on change of selected tab.
    //       animateTabTransition: true,
    //       duration: Duration(milliseconds: 200),
    //       screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
    //     ),
    //   ),
    //   confineToSafeArea: true,
    //   // popAllScreensOnTapOfSelectedTab: true,
    //   // itemAnimationProperties: const ItemAnimationProperties(
    //   //   duration: Duration(milliseconds: 200),
    //   //   curve: Curves.easeInOut,
    //   // ),
    //   // screenTransitionAnimation: const ScreenTransitionAnimation(
    //   //   animateTabTransition: true,
    //   //   duration: Duration(milliseconds: 200),
    //   //   curve: Curves.easeInOut,
    //   // ),
    // );
  }
}

SliverPadding _buildIconSection({
  required String title,
  required List<String> items,
  List<String?>? assets,
  List<int?>? offers,
  Future<void> Function(String serviceName)? onServiceTap,
  bool expanded = false,
  VoidCallback? onViewAll,
}) {
  const int columns = 4;
  const int maxRows = 2;
  final totalRows = (items.length / columns).ceil();
  final showViewAll = totalRows > maxRows;
  const maxItems = columns * maxRows;
  final visibleCount = (expanded || !showViewAll) ? items.length : maxItems;
  final visibleItems = items.take(visibleCount).toList();
  final visibleAssets = assets?.take(visibleCount).toList();
  final visibleOffers = offers?.take(visibleCount).toList();

  return SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    sliver: SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: title,
            actionLabel:
                showViewAll ? (expanded ? 'View Less' : 'View More') : null,
            onAction: showViewAll ? onViewAll : null,
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: 16.sp),
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final double tileWidth = 64.r;
              final double spacing = columns > 1
                  ? (maxWidth - tileWidth * columns) / (columns - 1)
                  : 0;

              return Wrap(
                spacing: spacing,
                runSpacing: 20.h,
                children: List.generate(visibleItems.length, (index) {
                  final iconAsset =
                      (visibleAssets != null && visibleAssets.length > index)
                          ? visibleAssets[index]
                          : null;
                  final serviceName = visibleItems[index];
                  final offer =
                      (visibleOffers != null && visibleOffers.length > index)
                          ? visibleOffers[index]
                          : null;
                  return SizedBox(
                    width: tileWidth,
                    child: RepaintBoundary(
                      child: HomeIconTile(
                        label: displayServiceName(serviceName),
                        asset: iconAsset,
                        offer: offer,
                        onTap: () async {
                          await onServiceTap?.call(serviceName);
                        },
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    ),
  );
}

List<Widget> _buildQuickActionSlivers(
  List<QuickActionCategory> categories,
  BuildContext context, {
  required WidgetRef ref,
  required Set<String> expandedCategories,
  required void Function(String category) onExpand,
}) {
  final bannerCacheWidth = (MediaQuery.sizeOf(context).width *
          MediaQuery.devicePixelRatioOf(context))
      .round();
  final slivers = <Widget>[
    const SliverToBoxAdapter(child: SizedBox(height: 12)),
  ];
  const utilitiesCategoryName = 'Utilities';
  const financeCategoryName = 'Finance & Banking';
  const propertyRentCategoryName = 'Property & Rent';

  for (final category in categories) {
    final title = category.category;

    slivers.add(
      _buildIconSection(
        title: title,
        items: category.services.map((s) => s.name).toList(),
        assets: category.services.map((s) => serviceIconMap[s.name]).toList(),
        offers: category.services.map((s) => s.offers).toList(),
        expanded: expandedCategories.contains(title),
        onViewAll: () => onExpand(title),
        onServiceTap: (serviceName) async {
          if (serviceName == 'Credit Card') {
            await ref
                .read(homeControllerProvider.notifier)
                .fetchCreditCardActions();
            final cards = ref.read(homeControllerProvider).creditCardActions;
            if (cards != null && cards.isNotEmpty) {
              context.push(RouteConstants.creditCardMyCards);
            } else {
              context.push(RouteConstants.creditCardListing);
            }
          } else if (serviceName == 'Mobile Prepaid') {
            context.push(RouteConstants.mobileRecentRecharges);
          } else {
            context.push(
              RouteConstants.billerListing,
              extra: serviceName,
            );
          }
        },
      ),
    );

    if (title == utilitiesCategoryName) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                FileConstants.digitalGold,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                cacheWidth: bannerCacheWidth,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
        ),
      );
    }

    if (title == financeCategoryName) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                FileConstants.preCard,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: bannerCacheWidth,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
        ),
      );
    }

    if (title == propertyRentCategoryName) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                FileConstants.homeBanner1,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                cacheWidth: bannerCacheWidth,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
        ),
      );
    }
  }

  return slivers;
}

// class _MembershipChip extends StatelessWidget {
//   const _MembershipChip({required this.label});
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.lightBorder),
//         boxShadow: const [
//           BoxShadow(
//             color: AppColors.cardShadow,
//             blurRadius: 10,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Image.asset(
//             FileConstants.bharatConnect,
//             height: 18,
//             width: 18,
//             color: AppColors.primary,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.w600,
//                 ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PlaceholderTab extends StatelessWidget {
//   const _PlaceholderTab({required this.title});
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: Text(title)),
//     );
//   }
// }

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 14 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.lightBorder,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.onTap,
    this.icon,
    this.iconAsset,
    this.badgeCount,
  }) : assert(icon != null || iconAsset != null);

  final VoidCallback onTap;
  final IconData? icon;
  final String? iconAsset;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        width: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: iconAsset != null
                  ? Image.asset(
                      iconAsset!,
                      height: 22,
                      width: 22,
                      color: AppColors.textPrimary,
                    )
                  : Icon(
                      icon,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
            ),
            if ((badgeCount ?? 0) > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    (badgeCount ?? 0) > 99 ? '99+' : '${badgeCount ?? 0}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
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

class _PagerDots extends StatelessWidget {
  const _PagerDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(active: true),
        SizedBox(width: 6),
        _Dot(active: false),
        SizedBox(width: 6),
        _Dot(active: false),
      ],
    );
  }
}

class _BottomIcon extends StatelessWidget {
  const _BottomIcon({required this.asset, this.size = 26});
  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: size,
      width: size,
      color: AppColors.primary,
    );
  }
}

class _GradientFabIcon extends StatelessWidget {
  const _GradientFabIcon({required this.asset, this.size = 24});
  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      width: 55.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Image.asset(
          asset,
          height: 35.h,
          width: 20.w,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _HomeContent extends HookConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final unreadCount =
        useValueListenable(NotificationBadgeService.unreadCount);
    final walletBalance = profileState.profile?.walletBalance ?? 0;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bannerCacheWidth = (screenWidth * devicePixelRatio).round();

    useEffect(() {
      Future.microtask(() {
        ref.read(homeControllerProvider.notifier).fetchQuickActions();
        ref.read(homeControllerProvider.notifier).fetchAllQuickActions();
        ref.read(spinOptionsControllerProvider.notifier).fetchSpinOptions();
        ref.read(profileControllerProvider.notifier).fetchProfile();
      });
      return null;
    }, const []);

    final banners = useMemoized(
      () => [FileConstants.homeBanner3, FileConstants.homeBanner4],
    );
    final bannerPage = useState(0);
    final bannerController = useMemoized(() => PageController(), const []);
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!bannerController.hasClients) return;
        final next = (bannerPage.value + 1) % banners.length;
        bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, const []);

    final quickActions = homeState.quickActions;
    final allQuickActions = homeState.allQuickActions ?? [];
    final expandedCategories = useState<Set<String>>(<String>{});

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => Future.wait([
          ref.read(homeControllerProvider.notifier).fetchQuickActions(),
          ref.read(homeControllerProvider.notifier).fetchAllQuickActions(),
          ref.read(spinOptionsControllerProvider.notifier).fetchSpinOptions(),
          ref.read(profileControllerProvider.notifier).fetchProfile(),
        ]),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              automaticallyImplyLeading: false,
              centerTitle: false,
              titleSpacing: 0,
              backgroundColor: const Color(0xFFFFE8DF),
              elevation: 0,
              toolbarHeight: 64,
              expandedHeight:
                  MediaQuery.of(context).padding.top + 64 + 12 + 100.h + 10 + 8,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.none,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.onboardingBackground,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: MediaQuery.of(context).padding.top + 64 + 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 100.h,
                          child: PageView.builder(
                            controller: bannerController,
                            onPageChanged: (page) => bannerPage.value = page,
                            itemCount: banners.length,
                            itemBuilder: (_, index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: GestureDetector(
                                onTap: () {
                                  if (index == 0) {
                                    context.push(
                                        RouteConstants.mobileRecentRecharges);
                                  } else if (index == 1) {
                                    context
                                        .push(RouteConstants.creditCardMyCards);
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    banners[index],
                                    width: double.infinity,
                                    fit: BoxFit.fill,
                                    cacheWidth: bannerCacheWidth,
                                    filterQuality: FilterQuality.low,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            banners.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: _Dot(active: bannerPage.value == index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 30,
                            width: 30,
                            child: Center(
                              child: Image.asset(
                                FileConstants.wallet,
                                height: 24,
                                width: 24,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$walletBalance',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _HeaderIconButton(
                          icon: Icons.search,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HomeSearchView(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _HeaderIconButton(
                          iconAsset: FileConstants.notification,
                          badgeCount: unreadCount,
                          onTap: () {
                            context.push(RouteConstants.notifications);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const ReferAndEarnView(),
                          withNavBar: false,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A56A1),
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              FileConstants.coin_3d,
                              width: 18.w,
                              height: 18.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Refer & Earn',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            // SizedBox(width: 8.w),
                            // const Icon(
                            //   Icons.arrow_forward,
                            //   color: Colors.white,
                            //   size: 16,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: CustomElevatedButton(
                  label: 'Complete Your KYC',
                  uppercaseLabel: false,
                  height: 42.h,
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const KycVerificationView(),
                      withNavBar: false,
                    );
                  },
                ),
              ),
            ),
            if (allQuickActions.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.onboardingBackground,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeSectionHeader(
                        title: 'Quick Actions',
                        actionLabel: 'View All',
                        onAction: () =>
                            context.push(RouteConstants.quickActions),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 92,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: allQuickActions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = allQuickActions[index];
                            final title = item.billerName?.trim().isNotEmpty ==
                                    true
                                ? item.billerName!.trim()
                                : item.paymentType?.trim().isNotEmpty == true
                                    ? item.paymentType!.trim()
                                    : 'Quick Action';
                            final due = (item.nextDue ?? '').trim();
                            final subtitle = due.isEmpty
                                ? (item.paymentType ?? '')
                                : '${item.paymentType ?? ''} Due : $due'.trim();
                            final amount =
                                item.amount?.trim().isNotEmpty == true
                                    ? '\u20B9 ${item.amount}'
                                    : '';
                            final rawAmount = item.amount ?? '';
                            final amountValue =
                                (double.tryParse(rawAmount) ?? 0).round();
                            final billerId = item.billerId ?? '';
                            final billerName =
                                item.billerName?.trim().isNotEmpty == true
                                    ? item.billerName!.trim()
                                    : 'Biller';
                            return SizedBox(
                              width: 320.w,
                              child: RepaintBoundary(
                                child: QuickActionCard(
                                  title: title,
                                  subtitle: subtitle,
                                  amount: amount,
                                  buttonLabel: amount.isEmpty ? '' : 'PAY NOW',
                                  onTap: () {
                                    final type =
                                        item.paymentType?.toLowerCase() ?? '';
                                    if (type.contains('recharge')) {
                                      if (billerId.isEmpty) return;
                                      context.push(
                                        RouteConstants.mobilePrepaid,
                                        extra: RechargeQuickActionPayload(
                                          phone: billerId,
                                          amount: amountValue,
                                          desc: item.desc,
                                          operatorName: billerName,
                                          iconUrl: item.icon,
                                        ),
                                      );
                                    } else {
                                      if (billerId.isEmpty) return;
                                      ref
                                          .read(billerDetailControllerProvider
                                              .notifier)
                                          .selectBiller(
                                            Biller(
                                              billerId: billerId,
                                              billerName: billerName,
                                            ),
                                          );
                                      context.push(
                                        RouteConstants.billerDetail,
                                        extra: BillerDetailArgs(
                                          biller: Biller(
                                            billerId: billerId,
                                            billerName: billerName,
                                          ),
                                          paymentType: item.paymentType,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _PagerDots(),
                    ],
                  ),
                ),
              ),
            if (homeState.isFetching && quickActions == null)
              const HomeShimmer()
            else if (homeState.errorMessage != null && quickActions == null)
              SliverToBoxAdapter(
                child: _HomeErrorState(
                  onRetry: () => ref
                      .read(homeControllerProvider.notifier)
                      .fetchQuickActions(),
                  onRestart: () => context.go(RouteConstants.splash),
                ),
              )
            else if (quickActions != null)
              ..._buildQuickActionSlivers(
                quickActions,
                context,
                ref: ref,
                expandedCategories: expandedCategories.value,
                onExpand: (category) {
                  if (expandedCategories.value.contains(category)) {
                    final next = {...expandedCategories.value};
                    next.remove(category);
                    expandedCategories.value = next;
                  } else {
                    expandedCategories.value = {
                      ...expandedCategories.value,
                      category,
                    };
                  }
                },
              ),
            if (quickActions != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: InkWell(
                    onTap: () => context.push(RouteConstants.spinAndWin),
                    borderRadius: BorderRadius.circular(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        FileConstants.spincoin,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        cacheWidth: bannerCacheWidth,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 14.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          FileConstants.homeBanner5,
                          height: 100.h,
                          fit: BoxFit.contain,
                          cacheWidth: bannerCacheWidth,
                          filterQuality: FilterQuality.low,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          FileConstants.homeBanner6,
                          height: 50.h,
                          fit: BoxFit.contain,
                          cacheWidth: bannerCacheWidth,
                          filterQuality: FilterQuality.low,
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         HomeSectionHeader(
            //           title: 'Memberships',
            //           actionLabel: 'View All',
            //           onAction: () {},
            //           padding: EdgeInsets.zero,
            //         ),
            //         const SizedBox(height: 12),
            //         const Wrap(
            //           spacing: 18,
            //           runSpacing: 16,
            //           children: [
            //             _MembershipChip(label: 'Credit Card'),
            //             _MembershipChip(label: 'Loan Repayment'),
            //             _MembershipChip(label: 'Recurring Deposit'),
            //             _MembershipChip(label: 'Insurance'),
            //           ],
            //         ),
            //         const SizedBox(height: 28),
            //         Text(
            //           'e-rupaiya',
            //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //                 color: AppColors.primary,
            //                 fontWeight: FontWeight.w700,
            //               ),
            //         ),
            //         const SizedBox(height: 6),
            //         Text(
            //           '#India Ka Smartest Bill Payment App',
            //           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            //                 color: AppColors.textPrimary,
            //               ),
            //         ),
            //         const SizedBox(height: 18),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({
    required this.onRetry,
    required this.onRestart,
  });

  final VoidCallback onRetry;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 32.h),
      child: Column(
        children: [
          Image.asset(
            FileConstants.somethingWentWrong,
            width: 170.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h),
          Text(
            'Something Went Wrong',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            'We’re facing a temporary issue loading your data. Please try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.7),
                  height: 1.4,
                ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  onPressed: onRetry,
                  label: 'Retry',
                  uppercaseLabel: false,
                  height: 35.h,
                  isBorder: true,
                  backgroundColor: Colors.white,
                  borderColor: AppColors.primary,
                  labelColor: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomElevatedButton(
                  onPressed: onRestart,
                  label: 'Restart',
                  uppercaseLabel: false,
                  height: 35.h,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
