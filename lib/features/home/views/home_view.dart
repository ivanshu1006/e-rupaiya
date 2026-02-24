// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../spinandear/controllers/spin_options_controller.dart';
import '../components/home_icon_tile.dart';
import '../components/home_section_header.dart';
import '../components/home_shimmer.dart';
import '../components/quick_action_card.dart';
import '../components/service_utils.dart';
import '../controllers/home_controller.dart';
import '../models/quick_action_model.dart';
import 'home_search_view.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = [
      const _HomeContent(),
      const _PlaceholderTab(title: 'Offers'),
      const _PlaceholderTab(title: 'Scan User'),
      const _PlaceholderTab(title: 'History'),
      const ProfileView(),
    ];

    final navItems = [
      PersistentBottomNavBarItem(
        icon: _BottomIcon(asset: FileConstants.paybills, size: 26),
        title: 'Pay Bills',
        iconSize: 26,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(asset: FileConstants.offers, size: 26),
        title: 'Offers',
        iconSize: 26,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: _GradientFabIcon(asset: FileConstants.scanUser, size: 26),
        title: 'Scan User',
        iconSize: 32,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(asset: FileConstants.history, size: 26),
        title: 'History',
        iconSize: 26,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(asset: FileConstants.profile, size: 26),
        title: 'Profile',
        iconSize: 26,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: AppColors.textPrimary.withOpacity(0.6),
      ),
    ];

    return PersistentTabView(
      context,
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
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardAppears: true,
      padding: const EdgeInsets.only(top: 8),
      backgroundColor: Colors.grey.shade900,
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      // popAllScreensOnTapOfSelectedTab: true,
      // itemAnimationProperties: const ItemAnimationProperties(
      //   duration: Duration(milliseconds: 200),
      //   curve: Curves.easeInOut,
      // ),
      // screenTransitionAnimation: const ScreenTransitionAnimation(
      //   animateTabTransition: true,
      //   duration: Duration(milliseconds: 200),
      //   curve: Curves.easeInOut,
      // ),
    );
  }
}

SliverPadding _buildIconSection({
  required String title,
  required List<String> items,
  List<String?>? assets,
  void Function(String serviceName)? onServiceTap,
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

  return SliverPadding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
    sliver: SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: title,
            actionLabel: showViewAll ? (expanded ? 'View Less' : 'View More') : null,
            onAction: showViewAll ? onViewAll : null,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              const double spacing = 12;
              final double itemWidth =
                  (maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 16,
                children: List.generate(visibleItems.length, (index) {
                  final iconAsset =
                      (visibleAssets != null && visibleAssets.length > index)
                          ? visibleAssets[index]
                          : null;
                  final serviceName = visibleItems[index];
                  return SizedBox(
                    width: itemWidth,
                    child: HomeIconTile(
                      label: displayServiceName(serviceName),
                      asset: iconAsset,
                      onTap: () => onServiceTap?.call(serviceName),
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
  required Set<String> expandedCategories,
  required void Function(String category) onExpand,
}) {
  final slivers = <Widget>[];
  const financeCategoryName = 'Finance & Banking';

  for (final category in categories) {
    final title = category.category;
    if (title == financeCategoryName) {
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
              ),
            ),
          ),
        ),
      );
    }

    slivers.add(
      _buildIconSection(
        title: title,
        items: category.services.map((s) => s.name).toList(),
        assets: category.services.map((s) => serviceIconMap[s.name]).toList(),
        expanded: expandedCategories.contains(title),
        onViewAll: () => onExpand(title),
        onServiceTap: (serviceName) {
          if (serviceName == 'Credit Card') {
            context.push(RouteConstants.creditCardListing);
          } else if (serviceName == 'Mobile Prepaid') {
            context.push(RouteConstants.mobilePrepaid);
          } else {
            context.push(
              RouteConstants.billerListing,
              extra: serviceName,
            );
          }
        },
      ),
    );
  }

  return slivers;
}

class _MembershipChip extends StatelessWidget {
  const _MembershipChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            FileConstants.bharatConnect,
            height: 18,
            width: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(title)),
    );
  }
}

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
    this.showBadge = false,
  }) : assert(icon != null || iconAsset != null);

  final VoidCallback onTap;
  final IconData? icon;
  final String? iconAsset;
  final bool showBadge;

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
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
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
            if (showBadge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
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
      height: 52,
      width: 52,
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
          height: size,
          width: size,
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
    final walletBalance = profileState.profile?.walletBalance ?? 0;

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
      () => [FileConstants.homeBanner2, FileConstants.homeBanner2],
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
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.onboardingBackground,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 52,
                    bottom: 12,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
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
                                  showBadge: true,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: PageView.builder(
                            controller: bannerController,
                            onPageChanged: (page) => bannerPage.value = page,
                            itemCount: banners.length,
                            itemBuilder: (_, index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  banners[index],
                                  width: double.infinity,
                                  fit: BoxFit.fill,
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
                        const SizedBox(height: 16),
                        if (allQuickActions.isNotEmpty) ...[
                          HomeSectionHeader(
                            title: 'Quick Actions',
                            actionLabel: 'View All',
                            onAction: () {},
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
                                final title =
                                    item.billerName?.trim().isNotEmpty == true
                                        ? item.billerName!.trim()
                                        : item.paymentType?.trim().isNotEmpty ==
                                                true
                                            ? item.paymentType!.trim()
                                            : 'Quick Action';
                                final due = (item.nextDue ?? '').trim();
                                final subtitle = due.isEmpty
                                    ? (item.paymentType ?? '')
                                    : '${item.paymentType ?? ''}    Due : $due'
                                        .trim();
                                final amount =
                                    item.amount?.trim().isNotEmpty == true
                                        ? '\u20B9 ${item.amount}'
                                        : '';
                                return SizedBox(
                                  width: 320,
                                  child: QuickActionCard(
                                    title: title,
                                    subtitle: subtitle,
                                    amount: amount,
                                    buttonLabel:
                                        amount.isEmpty ? '' : 'PAY NOW',
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _PagerDots(),
                        ],
                      ]),
                ),
              ),
            ),
            if (homeState.isFetching && quickActions == null)
              const HomeShimmer()
            else if (homeState.errorMessage != null && quickActions == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          homeState.errorMessage!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red.shade700,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => ref
                              .read(homeControllerProvider.notifier)
                              .fetchQuickActions(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (quickActions != null)
              ..._buildQuickActionSlivers(
                quickActions,
                context,
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
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    FileConstants.homeBanner1,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    FileConstants.preCard,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
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
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeSectionHeader(
                      title: 'Memberships',
                      actionLabel: 'View All',
                      onAction: () {},
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 18,
                      runSpacing: 16,
                      children: [
                        _MembershipChip(label: 'Credit Card'),
                        _MembershipChip(label: 'Loan Repayment'),
                        _MembershipChip(label: 'Recurring Deposit'),
                        _MembershipChip(label: 'Insurance'),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'e-rupaiya',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '#India Ka Smartest Bill Payment App',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
