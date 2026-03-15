// ignore_for_file: deprecated_member_use

import 'dart:async';

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
import '../../../widgets/my_app_bar.dart';
import '../../profile/views/my_wallet_view.dart';
import '../components/quick_action_card.dart';
import '../models/notification_item.dart';
import '../repositories/notifications_repository.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) => NotificationsRepository());

final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
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
    final unreadCount =
        useValueListenable(NotificationBadgeService.unreadCount);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: 'Notifications',
            showHelp: true,
            trailing: unreadCount > 0 ? _CountBadge(count: unreadCount) : null,
            onBack: () => context.pop(),
            onHelp: () {},
          ),
          Expanded(
            child: notificationsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (_, __) => const _NotificationsEmptyState(),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return const _NotificationsEmptyState();
                }
                final localReadIds = ref.watch(notificationReadIdsProvider);
                final unreadFromList = notifications
                    .where(
                      (n) => !n.isRead && !localReadIds.contains(n.id),
                    )
                    .length;
                NotificationBadgeService.syncFromList(unreadFromList);
                final today =
                    notifications.where((n) => n.section == 'Today').toList();
                final earlier =
                    notifications.where((n) => n.section != 'Today').toList();
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (today.isNotEmpty) ...[
                        const _SectionTitle('Today'),
                        SizedBox(height: 10.h),
                        ...today.map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: QuickActionCard(
                              title: item.title,
                              subtitle: item.subtitle,
                              amount: '',
                              buttonLabel: item.actionLabel,
                              imageAsset: item.iconAsset,
                              showTail: true,
                              showLeadingImage: true,
                              onTap: () => _handleNotificationTap(
                                context,
                                ref,
                                item,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                      if (earlier.isNotEmpty) ...[
                        const _SectionTitle('Earlier'),
                        SizedBox(height: 10.h),
                        ...earlier.map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: QuickActionCard(
                              title: item.title,
                              subtitle: item.subtitle,
                              amount: '',
                              buttonLabel: item.actionLabel,
                              imageAsset: item.iconAsset,
                              showTail: true,
                              showLeadingImage: true,
                              onTap: () => _handleNotificationTap(
                                context,
                                ref,
                                item,
                              ),
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

  final combined = '${item.title} ${item.subtitle}'.toLowerCase();
  if (combined.contains('spin')) {
    context.push(RouteConstants.spinAndWin);
    return;
  }
  if (combined.contains('wallet')) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: const MyWalletView(),
      withNavBar: false,
    );
    return;
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
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  FileConstants.appLogo,
                  width: 60.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              "You're All Caught Up!",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
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
