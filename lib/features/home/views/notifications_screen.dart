// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/my_app_bar.dart';
import '../components/quick_action_card.dart';
import '../models/notification_item.dart';
import '../repositories/notifications_repository.dart';
import '../../profile/views/my_wallet_view.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) => NotificationsRepository());

final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
  final repository = ref.read(notificationsRepositoryProvider);
  return repository.fetchNotifications();
});

class NotificationsScreen extends HookConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MyAppBar(
            title: 'Notifications',
            showHelp: true,
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
  NotificationItem item,
) {
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
