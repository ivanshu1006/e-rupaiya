// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:e_rupaiya/constants/app_text_styles.dart';
import 'package:e_rupaiya/features/home/components/home_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../services/notification_badge_service.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/k_dialog.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/offers_view.dart';
import '../../profile/views/profile_view.dart';
import '../../profile/views/transaction_history_screen.dart';
import '../../refer_and_earn/views/refer_and_earn_view.dart';
import '../../spinandear/controllers/spin_options_controller.dart';
import '../components/exit_app_dialog.dart';
import '../components/home_icon_tile.dart';
import '../controllers/home_controller.dart';
import '../controllers/home_tab_controller.dart';
import '../models/quick_action_model.dart';
import 'home_search_view.dart';
import 'notifications_screen.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = ref.watch(homeTabControllerProvider);
    final lastTabIndex = useRef<int>(tabController.index);
    final isExitDialogOpen = useRef<bool>(false);
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
      const NotificationsScreen(),
    ];

    final navTextStyle = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
    final inactiveNavColor = AppColors.textPrimary.withOpacity(0.45);
    final navItems = [
      PersistentBottomNavBarItem(
        icon: _BottomIcon(
          asset: FileConstants.paybills,
          size: 20.r,
          color: AppColors.primary,
        ),
        // inactiveIcon: _BottomIcon(
        //   asset: FileConstants.erupaiyaLogo,
        //   size: 20.r,
        //   color: inactiveNavColor,
        // ),
        title: 'Pay Bills',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: inactiveNavColor,
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(
          asset: FileConstants.offers,
          size: 20.r,
          color: AppColors.primary,
        ),
        inactiveIcon: _BottomIcon(
          asset: FileConstants.offers,
          size: 20.r,
          color: inactiveNavColor,
        ),
        title: 'Offers',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: inactiveNavColor,
      ),
      PersistentBottomNavBarItem(
        icon: _GradientFabIcon(
          asset: FileConstants.scanUser,
          size: 20.r,
          iconColor: Colors.white,
        ),
        inactiveIcon: _GradientFabIcon(
          asset: FileConstants.scanUser,
          size: 20.r,
          iconColor: Colors.white.withOpacity(0.75),
        ),
        title: 'Scan User',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: inactiveNavColor,
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(
          asset: FileConstants.history,
          size: 20.r,
          color: AppColors.primary,
        ),
        inactiveIcon: _BottomIcon(
          asset: FileConstants.history,
          size: 20.r,
          color: inactiveNavColor,
        ),
        title: 'History',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: inactiveNavColor,
      ),
      PersistentBottomNavBarItem(
        icon: _BottomIcon(
          asset: FileConstants.notification,
          size: 20.r,
          color: AppColors.primary,
        ),
        inactiveIcon: _BottomIcon(
          asset: FileConstants.notification,
          size: 20.r,
          color: inactiveNavColor,
        ),
        title: 'Alerts',
        iconSize: 30.r,
        textStyle: navTextStyle,
        activeColorPrimary: Colors.black,
        inactiveColorPrimary: inactiveNavColor,
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
    Future<void> showExitDialog() async {
      if (isExitDialogOpen.value) return;
      isExitDialogOpen.value = true;
      try {
        await KDialog.instance.openDialog(
          barrierDismissible: false,
          dialog: ExitAppDialog(
            onConfirm: () => SystemNavigator.pop(),
          ),
        );
      } finally {
        isExitDialogOpen.value = false;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        showExitDialog();
      },
      child: PersistentTabView(
        context,
        controller: tabController,
        screens: tabs,
        items: navItems,
        navBarStyle: NavBarStyle.style15,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(0),
          // color: Colors.white,
          colorBehindNavBar: Colors.white,
        ),
        navBarHeight: 58.h,
        padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
        backgroundColor: Colors.white,
        hideNavigationBarWhenKeyboardAppears: true,
        confineToSafeArea: true,
      ),
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
    this.size = 36,
    this.iconSize = 18,
  }) : assert(icon != null || iconAsset != null);

  final VoidCallback onTap;
  final IconData? icon;
  final String? iconAsset;
  final int? badgeCount;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size.r;
    final resolvedIconSize = iconSize.r;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(resolvedSize / 2),
      child: Container(
        height: resolvedSize,
        width: resolvedSize,
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
                      height: resolvedIconSize,
                      width: resolvedIconSize,
                      color: AppColors.textPrimary,
                    )
                  : Icon(
                      icon,
                      size: resolvedIconSize,
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
  const _BottomIcon({
    required this.asset,
    this.size = 26,
    this.color,
  });
  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: size,
      width: size,
      color: color ?? const Color.fromARGB(255, 248, 245, 244),
    );
  }
}

class _GradientFabIcon extends StatelessWidget {
  const _GradientFabIcon({
    required this.asset,
    this.size = 24,
    this.iconColor,
  });
  final String asset;
  final double size;
  final Color? iconColor;

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
          color: iconColor ?? Colors.white,
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.initials,
    required this.walletBalance,
    required this.onSearchTap,
    required this.onReferTap,
    required this.onProfileTap,
    this.compact = false,
  });

  final String initials;
  final double walletBalance;
  final VoidCallback onSearchTap;
  final VoidCallback onReferTap;
  final VoidCallback onProfileTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.bricolageGrotesque(
      textStyle: Theme.of(context).textTheme.bodySmall,
    );
    final displayBalance = walletBalance == walletBalance.roundToDouble()
        ? walletBalance.toStringAsFixed(0)
        : walletBalance.toStringAsFixed(2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: _ProfileAvatar(
                initials: initials,
                size: compact ? 32 : 36,
              ),
            ),
            SizedBox(width: 8.w),
            _HeaderIconButton(
              icon: Icons.search,
              size: compact ? 32 : 36,
              iconSize: compact ? 16 : 18,
              onTap: onSearchTap,
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: onReferTap,
              child: Image.asset(
                FileConstants.referandearn,
                height: compact ? 26.h : 30.h,
                width: compact ? 120.w : 132.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Image.asset(
                    FileConstants.coin_3d,
                    width: compact ? 14.w : 16.w,
                    height: compact ? 14.w : 16.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    displayBalance,
                    style: textStyle.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 10.sp : 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials, required this.size});
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.r,
      width: size.r,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.bricolageGrotesque(
            textStyle: Theme.of(context).textTheme.bodySmall,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(18.r),
            child: Row(
              children: [
                Text(
                  actionLabel!,
                  style: GoogleFonts.bricolageGrotesque(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  height: 20.r,
                  width: 20.r,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 14.r,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HomeIconGrid extends StatelessWidget {
  const _HomeIconGrid({
    required this.services,
    required this.onTap,
    this.maxItems = 8,
    this.columns = 4,
    this.tileWidth = 64,
  });

  final List<QuickActionService> services;
  final Future<void> Function(String serviceName) onTap;
  final int maxItems;
  final int columns;
  final double tileWidth;

  @override
  Widget build(BuildContext context) {
    final visibleItems = services.take(maxItems).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final spacing = 12.w;
        final computedTileSize = (maxWidth - spacing * (columns - 1)) / columns;
        final tileSize =
            computedTileSize > tileWidth.r ? tileWidth.r : computedTileSize;
        return Wrap(
          spacing: spacing.w,
          runSpacing: 16.h,
          children: List.generate(visibleItems.length, (index) {
            final service = visibleItems[index];
            return SizedBox(
              width: tileSize,
              child: HomeIconTile(
                label: service.name,
                iconUrl: service.icon,
                offer: service.offers,
                onTap: () async {
                  await onTap(service.name);
                },
              ),
            );
          }),
        );
      },
    );
  }
}

class _CurvedIconGrid extends StatelessWidget {
  const _CurvedIconGrid({
    required this.services,
    required this.onTap,
    this.maxItems = 4,
    this.labelBuilder,
  });

  final List<QuickActionService> services;
  final Future<void> Function(String serviceName) onTap;
  final int maxItems;
  final String Function(QuickActionService service)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final visibleItems = services.take(maxItems).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 10.w;
        final tileWidth = (constraints.maxWidth - spacing * 3) / 4;
        final tileHeight = tileWidth * 1.4;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            final service =
                index < visibleItems.length ? visibleItems[index] : null;
            if (service == null) {
              return SizedBox(width: tileWidth, height: tileHeight);
            }
            return SizedBox(
              width: tileWidth,
              height: tileHeight,
              child: _CurvedIconTile(
                label: labelBuilder?.call(service) ?? service.name,
                iconUrl: service.icon ?? '',
                onTap: () async {
                  await onTap(service.name);
                },
              ),
            );
          }),
        );
      },
    );
  }
}

class _CurvedIconTile extends StatelessWidget {
  const _CurvedIconTile({
    required this.label,
    required this.iconUrl,
    required this.onTap,
  });

  final String label;
  final String iconUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xffEAEAEA)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Image.asset(
                  FileConstants.bottomOrangeCurve,
                  height: 8.h,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 6.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 50.r,
                      width: 50.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.5,
                          colors: [
                            Color(0xFFF9F9F9),
                            Color(0xFFF6F6F6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: AppNetworkImage(
                          url: iconUrl,
                          width: 26.r,
                          height: 26.r,
                          fit: BoxFit.contain,
                          showShimmer: false,
                          errorWidget: Image.asset(
                            FileConstants.appLogo,
                            height: 26.r,
                            width: 26.r,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmallSemibold(context),
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayBillsCard extends StatelessWidget {
  const _PayBillsCard({
    required this.services,
    required this.onTap,
    required this.onExploreTap,
  });

  final List<QuickActionService> services;
  final Future<void> Function(String serviceName) onTap;
  final VoidCallback onExploreTap;

  QuickActionService? _findService(Set<String> used, List<String> names) {
    for (final name in names) {
      for (final service in services) {
        if (service.name == name && !used.contains(service.name)) {
          used.add(service.name);
          return service;
        }
      }
    }
    return null;
  }

  QuickActionService? _nextUnused(Set<String> used) {
    for (final service in services) {
      if (!used.contains(service.name)) {
        used.add(service.name);
        return service;
      }
    }
    return null;
  }

  String _labelForService(QuickActionService service) {
    return service.name;
  }

  Widget _serviceTile(QuickActionService service) {
    return HomeIconTile(
      label: _labelForService(service),
      iconUrl: service.icon,
      offer: service.offers,
      labelSpacing: 4.h,
      showHalfRing: _isBookGasService(service),
      onTap: () async {
        await onTap(service.name);
      },
    );
  }

  bool _isBookGasService(QuickActionService service) {
    const gasNames = ['LPG Gas', 'Book Gas Cylinder', 'Pipe Gas', 'Book Gas'];
    return gasNames.contains(service.name);
  }

  @override
  Widget build(BuildContext context) {
    final used = <String>{};

    final electricity = _findService(used, const ['Electricity']);
    final recharge = _findService(
      used,
      const ['Mobile Prepaid', 'Mobile Postpaid', 'Recharge'],
    );
    final fastag = _findService(used, const ['Fastag', 'FASTag']);
    final credit = _findService(used, const ['Credit Card']);
    final bookGas = _findService(
          used,
          const ['LPG Gas', 'Book Gas Cylinder', 'Pipe Gas', 'Book Gas'],
        ) ??
        _nextUnused(used);

    final topRow = <QuickActionService?>[
      electricity ?? _nextUnused(used),
      recharge ?? _nextUnused(used),
      fastag ?? _nextUnused(used),
      credit ?? _nextUnused(used),
    ];

    const imageAspectRatio = 1960 / 1380;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = width / imageAspectRatio - 20.h;
            final tileWidth = width * 0.18;
            final bookTileWidth = width * 0.2;
            final horizontalInset = width * 0.06;
            final topRowSpacing =
                (width - (horizontalInset * 2) - (tileWidth * 4)) / 3;
            final firstTileCenter = horizontalInset + (tileWidth / 2);

            Widget positionedTile({
              required double x,
              required double y,
              required QuickActionService? service,
              required double tileW,
            }) {
              if (service == null) return const SizedBox.shrink();
              return Positioned(
                left: x - (tileW / 2),
                top: y,
                width: tileW,
                child: _serviceTile(service),
              );
            }

            return SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      FileConstants.homeIconSection,
                      fit: BoxFit.fill,
                    ),
                  ),
                  positionedTile(
                    x: firstTileCenter,
                    y: height * 0.08,
                    service: topRow[0],
                    tileW: tileWidth,
                  ),
                  positionedTile(
                    x: firstTileCenter + tileWidth + topRowSpacing,
                    y: height * 0.08,
                    service: topRow[1],
                    tileW: tileWidth,
                  ),
                  positionedTile(
                    x: firstTileCenter + ((tileWidth + topRowSpacing) * 2),
                    y: height * 0.08,
                    service: topRow[2],
                    tileW: tileWidth,
                  ),
                  positionedTile(
                    x: firstTileCenter + ((tileWidth + topRowSpacing) * 3),
                    y: height * 0.08,
                    service: topRow[3],
                    tileW: tileWidth,
                  ),
                  positionedTile(
                    x: width * 0.15,
                    y: height * 0.56,
                    service: bookGas,
                    tileW: bookTileWidth,
                  ),
                  if (bookGas != null)
                    Positioned(
                      left: width * 0.32,
                      right: 0,
                      top: height * 0.54,
                      child: _PromoStrip(
                        asset: FileConstants.bookLpgStrip,
                      ),
                    ),
                  Positioned(
                    right: width * 0.01,
                    // left: width * 0.01,
                    bottom: height * -0.00,
                    child: _ExploreUtilitiesRow(onTap: onExploreTap),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 18.h),
        const _ReferStrip(),
      ],
    );
  }
}

class _PromoStrip extends StatelessWidget {
  const _PromoStrip({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      ),
      child: Image.asset(
        asset,
        height: 30.h,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ExploreUtilitiesRow extends StatelessWidget {
  const _ExploreUtilitiesRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 220.w,
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFBE6DE),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Explore All Services',
              style: GoogleFonts.bricolageGrotesque(
                textStyle: Theme.of(context).textTheme.bodyMedium,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              height: 24.r,
              width: 24.r,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 14.r,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferStrip extends StatelessWidget {
  const _ReferStrip();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const ReferAndEarnView(),
          withNavBar: false,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFF794E),
              Color(0xFF99482F),
            ],
            stops: [-0.3508, 1],
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 18.r,
              width: 18.r,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                FileConstants.coin_3d,
                height: 12.r,
                width: 12.r,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Refer Your First Friend And Grab 1000 E-Coins',
                textAlign: TextAlign.center,
                style: GoogleFonts.bricolageGrotesque(
                  textStyle: Theme.of(context).textTheme.bodySmall,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.celebration, size: 14.r, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _InvestmentTile extends StatelessWidget {
  const _InvestmentTile({
    required this.label,
    required this.iconAsset,
    required this.arrowAsset,
    required this.borderColor,
    required this.textColor,
    this.backgroundGradient,
  });

  final String label;
  final String iconAsset;
  final String arrowAsset;
  final Color borderColor;
  final Color textColor;
  final Gradient? backgroundGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: backgroundGradient == null ? Colors.white : null,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 20.r,
            width: 20.r,
            child: Image.asset(
              iconAsset,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.bricolageGrotesque(
                textStyle: Theme.of(context).textTheme.bodySmall,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          SizedBox(
            height: 22.r,
            width: 22.r,
            child: Image.asset(
              arrowAsset,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageBanner extends StatelessWidget {
  const _ImageBanner({required this.asset, required this.height});
  final String asset;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round();
    return Image.asset(
      asset,
      height: height,
      width: double.infinity,
      fit: BoxFit.fill,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.low,
    );
  }
}

class InsuranceBannerCarousel extends HookWidget {
  const InsuranceBannerCarousel({super.key, required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final controller = usePageController();
    final currentIndex = useState(0);

    final banners = [
      FileConstants.homeBanner10,
      FileConstants.homeBanner10,
      FileConstants.homeBanner10,
    ];

    return Stack(
      children: [
        SizedBox(
          height: 128.h,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            onPageChanged: (index) => currentIndex.value = index,
            itemBuilder: (context, index) {
              return _InsuranceBanner(onApply: onApply);
            },
          ),
        ),

        ///DOTS OVERLAY
        Positioned(
          left: 18.w, // match your padding
          bottom: 5.h, // just below button visually
          child: Row(
            children: List.generate(
              banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(right: 4.w),
                height: 6.h,
                width: currentIndex.value == index ? 14.w : 6.w,
                decoration: BoxDecoration(
                  color: currentIndex.value == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsuranceBannerItem extends StatelessWidget {
  const _InsuranceBannerItem({
    required this.image,
    required this.onApply,
    required this.currentIndex,
    required this.total,
  });

  final String image;
  final VoidCallback onApply;
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F8A4B),
            Color(0xFF0C6B3B),
          ],
        ),
      ),
      child: Row(
        children: [
          /// LEFT CONTENT
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Your Future',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Health, Motor & Life Insurance In\nMinutes',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 10.h),

                /// APPLY BUTTON
                InkWell(
                  onTap: onApply,
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFDD5428),
                          Color(0xFF772D16),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Apply Now',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.north_east, size: 12.r, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                Row(
                  children: List.generate(
                    total,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(right: 4.w),
                      height: 6.h,
                      width: currentIndex == index ? 14.w : 6.w,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          /// RIGHT IMAGE
          SizedBox(
            height: 96.h,
            width: 120.w,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsuranceBanner extends StatelessWidget {
  const _InsuranceBanner({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F8A4B),
            Color(0xFF0C6B3B),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Your Future',
                  style: GoogleFonts.bricolageGrotesque(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Health, Motor & Life Insurance In\nMinutes',
                  style: GoogleFonts.bricolageGrotesque(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 10.h),
                InkWell(
                  onTap: onApply,
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFDD5428),
                          Color(0xFF772D16),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Apply Now',
                          style: GoogleFonts.bricolageGrotesque(
                            textStyle: Theme.of(context).textTheme.bodySmall,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.north_east,
                          size: 12.r,
                          color: Colors.white,
                        ),
                        SizedBox(
                          height: 10.h,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            height: 96.h,
            width: 120.w,
            child: Image.asset(
              FileConstants.homeBannerGif,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// class _MiniImageCard extends StatelessWidget {
//   const _MiniImageCard({
//     required this.asset,
//     required this.title,
//     required this.onTap,
//   });
//   final String asset;
//   final String title;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12.r),
//       child: Container(
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: AppColors.lightBorder),
//         ),
//         child: Row(
//           children: [
//             Image.asset(asset, height: 30.h, width: 30.h, fit: BoxFit.contain),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: Text(
//                 title,
//                 style: GoogleFonts.bricolageGrotesque(
//                   textStyle: Theme.of(context).textTheme.bodySmall,
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Container(
//               height: 20.r,
//               width: 20.r,
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.chevron_right,
//                 size: 14.r,
//                 color: AppColors.primary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _MiniActionCard extends StatelessWidget {
  const _MiniActionCard({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.gradientBorder,
  });

  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Gradient? gradientBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: gradientBorder,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: gradientBorder == null
                ? Border.all(
                    color: borderColor ?? AppColors.lightBorder,
                    width: 0.5,
                  )
                : null,
          ),
          margin: gradientBorder == null
              ? EdgeInsets.zero
              : const EdgeInsets.all(0.5),
          child: Row(
            children: [
              Image.asset(asset,
                  height: 20.h, width: 20.h, fit: BoxFit.contain),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.bricolageGrotesque(
                        textStyle: Theme.of(context).textTheme.bodySmall,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.bricolageGrotesque(
                        textStyle: Theme.of(context).textTheme.bodySmall,
                        color: AppColors.textPrimary.withOpacity(0.6),
                        fontSize: 9.sp,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                FileConstants.rightArrow,
                height: 28.r,
                width: 28.r,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Image.asset(FileConstants.faqIcon,
                height: 20.h, width: 20.h, fit: BoxFit.contain),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.bricolageGrotesque(
                  textStyle: Theme.of(context).textTheme.bodySmall,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Image.asset(
              FileConstants.rightArrow,
              height: 28.r,
              width: 28.r,
              fit: BoxFit.contain,
            ),
          ],
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

    // Pull banners dynamically from your updated state
    final banners = homeState.banners ?? [];
    final bannerPage = useState(0);
    final bannerController = useMemoized(() => PageController(), const []);
    useEffect(() {
      if (banners.length < 2) return null;
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!bannerController.hasClients) return;
        final next = (bannerPage.value + 1) % banners.length;
        bannerController.animateToPage(
          next.toInt(),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, [
      banners.length
    ]); // depend on length so timer updates once API returns data

    final showBannerPlaceholder = homeState.isFetching && banners.isEmpty;
    final bannerAreaHeight =
        (banners.isNotEmpty || showBannerPlaceholder) ? 100.h : 0.h;

    final educationBanners = useMemoized(
      () => [FileConstants.homeBanner12, FileConstants.homeBanner10],
    );
    final educationBannerPage = useState(0);
    final educationBannerController =
        useMemoized(() => PageController(), const []);
    useEffect(() {
      if (educationBanners.length < 2) return null;
      final timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!educationBannerController.hasClients) return;
        final next = (educationBannerPage.value + 1) % educationBanners.length;
        educationBannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      return timer.cancel;
    }, const []);

    final quickActions = homeState.quickActions;

    QuickActionCategory? findCategory(
      List<QuickActionCategory> categories,
      List<String> keywords,
    ) {
      for (final category in categories) {
        final label = category.category.toLowerCase();
        if (keywords.any((keyword) => label.contains(keyword))) {
          return category;
        }
      }
      return categories.isNotEmpty ? categories.first : null;
    }

    Future<void> handleServiceTap(String serviceName) async {
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
      } else if (serviceName == 'Tuition Fees' ||
          serviceName == 'Tution Fees' ||
          serviceName == 'School Fees' ||
          serviceName == 'College Fees') {
        context.push(
          RouteConstants.educationFeesAmount,
          extra: serviceName,
        );
      } else {
        context.push(
          RouteConstants.billerListing,
          extra: serviceName,
        );
      }
    }

    final initials = profileState.profile?.initials.isNotEmpty == true
        ? profileState.profile!.initials
        : 'DN';
    final walletBalance = profileState.profile?.walletBalance ?? 0.0;
    final payBillsCategory = quickActions == null
        ? null
        : findCategory(quickActions, ['utilities', 'bills', 'expenses']);
    final educationCategory = quickActions == null
        ? null
        : findCategory(quickActions, ['education', 'lifestyle']);
    final insuranceCategory = quickActions == null
        ? null
        : findCategory(quickActions, ['insurance', 'rent', 'property']);

    return Scaffold(
      // backgroundColor: AppColors.gradientEnd,
      body: Stack(
        children: [
          // Container(color: AppColors.gradientEnd),
          RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => Future.wait([
                    ref
                        .read(homeControllerProvider.notifier)
                        .fetchQuickActions(),
                    ref
                        .read(homeControllerProvider.notifier)
                        .fetchAllQuickActions(),
                    ref
                        .read(spinOptionsControllerProvider.notifier)
                        .fetchSpinOptions(),
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
                      backgroundColor: const Color(0xffD66D4D),
                      elevation: 0,
                      toolbarHeight: 54.h,
                      expandedHeight: MediaQuery.of(context).padding.top +
                          40.h +
                          14.h +
                          bannerAreaHeight +
                          (banners.length > 1 ? 16.h : 0.h),
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.none,
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFF835C),
                                Color(0xFF994F37),
                              ],
                              stops: [0.0, 0.3807],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              top: MediaQuery.of(context).padding.top +
                                  54.h +
                                  10.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 6.h),
                                if (showBannerPlaceholder)
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    child: AppNetworkImage(
                                      url: '',
                                      width: double.infinity,
                                      height: 100.h,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  )
                                else if (banners.isNotEmpty)
                                  SizedBox(
                                    height: 100.h,
                                    child: PageView.builder(
                                      controller: bannerController,
                                      onPageChanged: (page) =>
                                          bannerPage.value = page,
                                      itemCount: banners.length,
                                      itemBuilder: (_, index) {
                                        final banner = banners[index];
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4.w),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (index == 0) {
                                                context.push(
                                                  RouteConstants.referAndEarn,
                                                );
                                              }
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14.r),
                                              child: AppNetworkImage(
                                                url: banner
                                                    .image, // Access API url
                                                width: double.infinity,
                                                height: 100.h,
                                                fit: BoxFit.fill,
                                                placeholder: AppNetworkImage(
                                                  url: '',
                                                  width: double.infinity,
                                                  height: 100.h,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(height: 4.h),
                                if (banners.length > 1)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      banners.length,
                                      (index) => Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 3.w),
                                        child: _Dot(
                                            active: bannerPage.value == index),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      title: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _HomeTopBar(
                          initials: initials,
                          walletBalance: walletBalance,
                          compact: true,
                          onSearchTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HomeSearchView(),
                              ),
                            );
                          },
                          onReferTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const ReferAndEarnView(),
                              withNavBar: false,
                            );
                          },
                          onProfileTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const ProfileView(),
                              withNavBar: false,
                            );
                          },
                        ),
                      ),
                    ),
                    if (homeState.isFetching && quickActions == null)
                      const HomeShimmer()
                    else if (homeState.errorMessage != null &&
                        quickActions == null)
                      SliverToBoxAdapter(
                        child: _HomeErrorState(
                          onRetry: () => ref
                              .read(homeControllerProvider.notifier)
                              .fetchQuickActions(),
                          onRestart: () => context.go(RouteConstants.splash),
                        ),
                      )
                    else if (quickActions != null)
                      SliverToBoxAdapter(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.r),
                            topRight: Radius.circular(24.r),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.r),
                                topRight: Radius.circular(24.r),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 20,
                                  offset: Offset(0, -10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _SectionHeader(
                                        title: 'Pay Bills & Expenses',
                                        actionLabel: 'My Bills',
                                        onAction: () => context
                                            .push(RouteConstants.quickActions),
                                      ),
                                      SizedBox(height: 14.h),
                                      _PayBillsCard(
                                        services: payBillsCategory?.services ??
                                            const [],
                                        onTap: handleServiceTap,
                                        onExploreTap: () {
                                          context.push(
                                              RouteConstants.homeSearchView);
                                        },
                                      ),
                                      SizedBox(height: 12.h),
                                      const _SectionHeader(
                                          title: 'Banking & Investments'),
                                      SizedBox(height: 10.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                context.push(
                                                  RouteConstants.digitalGold,
                                                );
                                              },
                                              child: _InvestmentTile(
                                                label: 'Digital Gold',
                                                iconAsset: FileConstants
                                                    .digitalGoldGif,
                                                arrowAsset:
                                                    FileConstants.goldArrow,
                                                borderColor:
                                                    const Color(0xFFE0C46A),
                                                textColor:
                                                    const Color(0xFF8B6B12),
                                                backgroundGradient:
                                                    const LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Color(0xFFFFFFFF),
                                                    Color(0xFFFFF4D5),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                context.push(
                                                  '${RouteConstants.digitalGold}?metal=silver',
                                                );
                                              },
                                              child: _InvestmentTile(
                                                label: 'Digital Silver',
                                                iconAsset: FileConstants
                                                    .digitalSilverGif,
                                                arrowAsset:
                                                    FileConstants.silverArrow,
                                                borderColor:
                                                    const Color(0xFFE1E1E1),
                                                textColor:
                                                    const Color(0xFF6B6B6B),
                                                backgroundGradient:
                                                    const LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Color(0xFFFFFFFF),
                                                    Color(0xFFF5F5F5),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 18.h),
                                      const _SectionHeader(
                                          title: 'Education & Lifestyle'),
                                      SizedBox(height: 12.h),
                                      _CurvedIconGrid(
                                        services: educationCategory?.services ??
                                            const [],
                                        onTap: handleServiceTap,
                                      ),
                                      SizedBox(height: 14.h),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 110.h,
                                        child: PageView.builder(
                                          controller: educationBannerController,
                                          onPageChanged: (page) =>
                                              educationBannerPage.value = page,
                                          itemCount: educationBanners.length,
                                          itemBuilder: (_, index) => Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14.r),
                                              child: Image.asset(
                                                educationBanners[index],
                                                width: double.infinity,
                                                fit: BoxFit.fill,
                                                alignment: Alignment.centerLeft,
                                                cacheWidth: bannerCacheWidth,
                                                filterQuality:
                                                    FilterQuality.low,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                      if (educationBanners.length > 1)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            educationBanners.length,
                                            (index) => Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 3.w),
                                              child: _Dot(
                                                active:
                                                    educationBannerPage.value ==
                                                        index,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      16.w, 18.h, 16.w, 12.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _SectionHeader(
                                        title: 'Insurance & Rent',
                                        // actionLabel: 'View All',
                                        onAction: () => context
                                            .push(RouteConstants.quickActions),
                                      ),
                                      SizedBox(height: 12.h),
                                      _CurvedIconGrid(
                                        services: insuranceCategory?.services ??
                                            const [],
                                        onTap: handleServiceTap,
                                        labelBuilder: (service) {
                                          final name = service.name.trim();
                                          final lower = name.toLowerCase();
                                          if (lower.contains('insurance')) {
                                            return name;
                                          }
                                          if (lower == 'general' ||
                                              lower == 'health' ||
                                              lower == 'life') {
                                            return '$name Insurance';
                                          }
                                          return name;
                                        },
                                      ),
                                      SizedBox(height: 14.h),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: _ImageBanner(
                                    asset: FileConstants.homeBanner9,
                                    height: 60.h,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _MiniActionCard(
                                              title: 'Gift card',
                                              subtitle: 'Gift your friends',
                                              asset: FileConstants.giftGif,
                                              backgroundColor:
                                                  const Color(0xFFFFF3EE),
                                              gradientBorder:
                                                  const LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  Color(0xFFFF9776),
                                                  Color(0xFFDD5428),
                                                ],
                                              ),
                                              onTap: () {},
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: _MiniActionCard(
                                              title: 'Spin & Win',
                                              subtitle: 'Win big prizes',
                                              asset: FileConstants.spinIcon,
                                              backgroundColor:
                                                  const Color(0xFFEAF2FF),
                                              borderColor:
                                                  const Color(0xFF002352),
                                              onTap: () => context.push(
                                                  RouteConstants.spinAndWin),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      _SupportTile(
                                        title: 'FAQ & Support',
                                        onTap: () => context.push(
                                          RouteConstants.faq,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: InsuranceBannerCarousel(
                                    onApply: () =>
                                        handleServiceTap('Insurance'),
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0XFFFDFDFD),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        16.w, 20.h, 16.w, 24.h),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Powered by',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Image.asset(
                                          FileConstants.bharatConnectColor,
                                          height: 25.h,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ])),
        ],
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
