// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../widgets/my_app_bar.dart';
import '../components/quick_action_card.dart';
import '../models/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<Map<String, dynamic>> _mockNotifications = [
    {
      'id': 'n1',
      'title': 'Bill Due',
      'subtitle': 'Pay ₹450 By Tomorrow',
      'actionLabel': 'Check Now',
      'iconAsset': FileConstants.electricity,
      'section': 'Today',
    },
    {
      'id': 'n2',
      'title': 'Recharge Expire Soon',
      'subtitle': '+911234567890',
      'actionLabel': 'Explore Plans',
      'iconAsset': FileConstants.mobile,
      'section': 'Today',
    },
    {
      'id': 'n3',
      'title': 'Spin The Wheel And Earn E-Coins',
      'subtitle': '',
      'actionLabel': 'Play Now',
      'iconAsset': FileConstants.spincoin,
      'section': 'Today',
    },
    {
      'id': 'n4',
      'title': 'Update App',
      'subtitle': 'Update App For Better Experience',
      'actionLabel': 'Update Now',
      'iconAsset': FileConstants.notification,
      'section': 'Reminder',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationItem.fromJsonList(_mockNotifications);
    final today = notifications.where((n) => n.section == 'Today').toList();
    final reminder =
        notifications.where((n) => n.section == 'Reminder').toList();

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
            child: notifications.isEmpty
                ? const _NotificationsEmptyState()
                : SingleChildScrollView(
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
                                onTap: () {},
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                        if (reminder.isNotEmpty) ...[
                          const _SectionTitle('Reminder'),
                          SizedBox(height: 10.h),
                          ...reminder.map(
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
                                onTap: () {},
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
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
