// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:e_rupaiya/features/refer_and_earn/views/refer_and_earn_wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../services/notification_badge_service.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/my_app_bar.dart';
import '../controllers/home_tab_controller.dart';
import '../models/notification_item.dart';
import '../models/notifications_feed.dart';
import '../repositories/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) => NotificationsRepository());

final notificationsProvider =
    FutureProvider.autoDispose<NotificationsFeed>((ref) async {
  final repository = ref.read(notificationsRepositoryProvider);
  return repository.fetchNotifications();
});

final notificationReadIdsProvider =
    StateProvider.autoDispose<Set<String>>((ref) => <String>{});

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final dismissedIds = useState<Set<String>>(<String>{});
    final remindingIds = useState<Set<String>>(<String>{});

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: 'Notifications',
            showHelp: true,
            // trailing: unreadCount > 0 ? _CountBadge(count: unreadCount) : null,
            onBack: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
                return;
              }
              ref.read(homeTabControllerProvider).jumpToTab(0);
            },
            onHelp: () {},
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(notificationsProvider.future),
              child: notificationsAsync.when(
                loading: () => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 140),
                    Center(
                      child: SpinKitCircle(
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                  ],
                ),
                error: (_, __) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 40),
                    _NotificationsEmptyState(),
                  ],
                ),
                data: (feed) {
                  final updates = feed.updates
                      .where((n) => !dismissedIds.value.contains(n.id))
                      .toList();
                  final notifications = feed.notifications
                      .where((n) => !dismissedIds.value.contains(n.id))
                      .toList();
                  if (updates.isEmpty && notifications.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 40),
                        _NotificationsEmptyState(),
                      ],
                    );
                  }

                  final localReadIds = ref.watch(notificationReadIdsProvider);
                  final unreadFromList = feed.unreadCount > 0
                      ? feed.unreadCount
                      : notifications
                          .where(
                            (n) => !n.isRead && !localReadIds.contains(n.id),
                          )
                          .length;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    NotificationBadgeService.syncFromList(unreadFromList);
                  });
                  final unreadNotifications = notifications
                      .where((n) => !n.isRead && !localReadIds.contains(n.id))
                      .toList();

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (unreadNotifications.isNotEmpty) ...[
                          const _SectionTitle('Unread'),
                          SizedBox(height: 10.h),
                          ...unreadNotifications.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _NotificationCard(
                                item: item,
                                onClose: () {
                                  dismissedIds.value = {
                                    ...dismissedIds.value,
                                    item.id,
                                  };
                                },
                                onPrimary: () =>
                                    _handleNotificationTap(context, ref, item),
                                onSecondary: item.showRemindButton
                                    ? () async {
                                        if (remindingIds.value
                                            .contains(item.id)) {
                                          return;
                                        }
                                        remindingIds.value = {
                                          ...remindingIds.value,
                                          item.id,
                                        };
                                        final ok = await ref
                                            .read(
                                                notificationsRepositoryProvider)
                                            .remindMeLater(item.id);
                                        final updated = Set<String>.from(
                                          remindingIds.value,
                                        )..remove(item.id);
                                        remindingIds.value = updated;
                                        if (ok) {
                                          AppSnackbar.show(
                                              'We will remind you later');
                                          ref.invalidate(notificationsProvider);
                                        } else {
                                          AppSnackbar.show(
                                            'Failed to set reminder. Please try again.',
                                          );
                                        }
                                      }
                                    : null,
                                secondaryLoading:
                                    remindingIds.value.contains(item.id),
                                primaryLabel: _primaryLabelFor(item),
                                secondaryLabel: item.showRemindButton
                                    ? 'Remind me Later'
                                    : null,
                                isPrimaryFullWidth: !item.showRemindButton,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                        if (updates.isNotEmpty) ...[
                          const _SectionTitle('Updates'),
                          SizedBox(height: 10.h),
                          ...updates.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _NotificationCard(
                                item: item,
                                onClose: () {
                                  dismissedIds.value = {
                                    ...dismissedIds.value,
                                    item.id,
                                  };
                                },
                                onPrimary: () =>
                                    _handleNotificationTap(context, ref, item),
                                primaryLabel: _primaryLabelFor(item),
                                isPrimaryFullWidth: true,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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

void _handleNotificationTap(
  BuildContext context,
  WidgetRef ref,
  NotificationItem item,
) {
  final readIds = ref.read(notificationReadIdsProvider);
  final isAlreadyRead = item.isRead || readIds.contains(item.id);
  if (!isAlreadyRead) {
    NotificationBadgeService.decrement();
    ref.read(notificationReadIdsProvider.notifier).state = {
      ...readIds,
      item.id,
    };
    unawaited(
      ref.read(notificationsRepositoryProvider).markNotificationRead(item.id),
    );
  }

  final redirect = (item.redirectScreen ?? '').trim().toLowerCase();
  if (redirect == 'app_update_screen') {
    unawaited(_openPlayStore());
    return;
  }
  if (redirect == 'spin_screen') {
    context.push(RouteConstants.spinAndWin);
    return;
  }
  if (redirect == 'wallet_history') {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const ReferAndEarnWalletView(),
      withNavBar: false,
    );
    return;
  }
  if (redirect == 'bill_history') {
    context.push(RouteConstants.transactions);
    return;
  }

  final combined = '${item.title} ${item.subtitle}'.toLowerCase();
  if (combined.contains('spin')) {
    context.push(RouteConstants.spinAndWin);
    return;
  }
  if (combined.contains('wallet')) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const ReferAndEarnWalletView(),
      withNavBar: false,
    );
    return;
  }
}

Future<void> _openPlayStore() async {
  try {
    final info = await PackageInfo.fromPlatform();
    final packageName = info.packageName.trim();
    if (packageName.isEmpty) return;
    final uri =
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

String _primaryLabelFor(NotificationItem item) {
  final redirect = (item.redirectScreen ?? '').trim().toLowerCase();
  if (redirect == 'spin_screen') return 'Play Now';
  if (redirect == 'app_update_screen') return 'Tap To Update';
  return 'Pay Now';
}

String _relativeAge(DateTime? dateTime) {
  if (dateTime == null) return '';
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays >= 1) return '${diff.inDays}d';
  if (diff.inHours >= 1) return '${diff.inHours}h';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
  return 'now';
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onPrimary,
    required this.primaryLabel,
    this.onSecondary,
    this.secondaryLabel,
    this.secondaryLoading = false,
    this.onClose,
    this.isPrimaryFullWidth = false,
  });

  final NotificationItem item;
  final VoidCallback onPrimary;
  final String primaryLabel;
  final VoidCallback? onSecondary;
  final String? secondaryLabel;
  final bool secondaryLoading;
  final VoidCallback? onClose;
  final bool isPrimaryFullWidth;

  @override
  Widget build(BuildContext context) {
    final ageText = _relativeAge(item.createdAt);
    final iconUrl = (item.iconUrl ?? '').trim();
    final hasSecondary =
        onSecondary != null && (secondaryLabel ?? '').isNotEmpty;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textPrimary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: AppNetworkImage(
                    url: iconUrl,
                    width: 22.r,
                    height: 22.r,
                    fit: BoxFit.contain,
                    showShimmer: true,
                    errorWidget: Image.asset(
                      item.iconAsset,
                      width: 22.r,
                      height: 22.r,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.72),
                            height: 1.25,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: EdgeInsets.all(6.r),
                      child: Icon(
                        Icons.close,
                        size: 18.r,
                        color: AppColors.textPrimary.withOpacity(0.55),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (ageText.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.r,
                          color: AppColors.textPrimary.withOpacity(0.4),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          ageText,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textPrimary.withOpacity(0.45),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (isPrimaryFullWidth)
            SizedBox(
              width: double.infinity,
              height: 30.h,
              child: ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  primaryLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 30.h,
                    child: OutlinedButton(
                      onPressed: (hasSecondary && !secondaryLoading)
                          ? onSecondary
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(
                            hasSecondary ? 1 : 0.35,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: secondaryLoading
                          ? SizedBox(
                              height: 18.h,
                              width: 18.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary.withOpacity(0.9),
                                ),
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                secondaryLabel ?? '',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary.withOpacity(
                                        hasSecondary ? 1 : 0.5,
                                      ),
                                    ),
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 30.h,
                    child: ElevatedButton(
                      onPressed: onPrimary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        primaryLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final display = count > 99 ? '99+' : '$count';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        display,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 56.r,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              "You're All Caught Up!",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Any Alerts, Updates, Or Activity Related To\n'
              'Your Account Will Appear Here.',
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
