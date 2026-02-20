// ignore_for_file: deprecated_member_use

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
import '../components/home_banner_card.dart';
import '../components/home_icon_tile.dart';
import '../components/home_section_header.dart';
import '../components/home_shimmer.dart';
import '../components/quick_action_card.dart';
import '../controllers/home_controller.dart';

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
}) {
  String _displayServiceName(String name) {
    if (name == 'LPG Gas') return 'Book Gas Cylinder';
    return name;
  }

  return SliverPadding(
    padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
    sliver: SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            title: title,
            actionLabel: 'View All',
            onAction: () {},
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              const int columns = 4;
              const double spacing = 12;
              final double itemWidth =
                  (maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 16,
                children: List.generate(items.length, (index) {
                  final iconAsset = (assets != null && assets.length > index)
                      ? assets[index]
                      : null;
                  return SizedBox(
                    width: itemWidth,
                    child: HomeIconTile(
                      label: _displayServiceName(items[index]),
                      asset: iconAsset,
                      onTap: () => onServiceTap?.call(items[index]),
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

class _EarnPointsBanner extends StatelessWidget {
  const _EarnPointsBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D9E8A), Color(0xFF0A8B7B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: 170,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xff00302C),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Earn Points',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Spin & Win E-Coins',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For Real Use',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -27,
                right: 140,
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    FileConstants.erupaiya_3d,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                right: -35,
                top: 15,
                child: Image.asset(
                  FileConstants.erupaiya_3d,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _serviceIconMap = <String, String>{
  'Mobile Prepaid': 'assets/images/png/home_icon/mobile_light.png',
  'Mobile Postpaid': 'assets/images/png/home_icon/mobile_light.png',
  'Landline Postpaid': 'assets/images/png/home_icon/landline_postpaid.png',
  'Broadband Postpaid': 'assets/images/png/home_icon/broadband.png',
  'DTH': 'assets/images/png/home_icon/dth.png',
  'Cable TV': 'assets/images/png/home_icon/dth.png',
  'Electricity': 'assets/images/png/home_icon/electricity.png',
  'Water': 'assets/images/png/home_icon/water.png',
  'Credit Card': 'assets/images/png/home_icon/creditcard.png',
  'Loan Repayment': 'assets/images/png/home_icon/repayment.png',
  'Recurring Deposit': 'assets/images/png/home_icon/recurring.png',
  'Insurance': 'assets/images/png/home_icon/insurance.png',
  'Life Insurance': 'assets/images/png/home_icon/life_insurance.png',
  'Prepaid Meter': 'assets/images/png/home_icon/prepaid_meter.png',
  'National Pension System': 'assets/images/png/home_icon/mobile_light.png',
  'NPS': 'assets/images/png/home_icon/mobile_light.png',
  'Flight Booking': 'assets/images/png/home_icon/flight.png',
  'Train Ticket Booking': 'assets/images/png/home_icon/train.png',
  'Hotel Booking': 'assets/images/png/home_icon/hotel_booking.png',
};

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
        ref.read(profileControllerProvider.notifier).fetchProfile();
      });
      return null;
    }, const []);

    final quickActions = homeState.quickActions;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
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
                        Row(
                          children: [
                            Image.asset(
                              FileConstants.wallet,
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'e-coins',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textPrimary
                                            .withOpacity(0.7),
                                      ),
                                ),
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
                          ],
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              FileConstants.notification,
                              height: 28,
                              width: 28,
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    HomeSectionHeader(
                      title: 'Quick Actions',
                      actionLabel: 'View All',
                      onAction: () {},
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    const QuickActionCard(
                      title: 'MMSDCL Mahavitaran',
                      subtitle: '11234567890    Due : 06-10-2025',
                      amount: '\u20B9 180',
                      buttonLabel: 'PAY NOW',
                    ),
                    const SizedBox(height: 12),
                    const _PagerDots(),
                  ],
                ),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            ...quickActions.map(
              (category) => _buildIconSection(
                title: category.category,
                items: category.services.map((s) => s.name).toList(),
                assets: category.services
                    .map((s) => _serviceIconMap[s.name])
                    .toList(),
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
            ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: HomeBannerCard(
                title: 'Ab Kro Apne Saare Bill Pay\n#E-Rupaiya App Se',
                subtitle: '#E-Rupaiya App Pe',
                buttonLabel: null,
                onPressed: null,
                height: 110,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  FileConstants.prepaidcard,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _EarnPointsBanner(
                onTap: () => context.push(RouteConstants.spinAndWin),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
