// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../home/components/quick_action_card.dart';
import '../components/support_action_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F3),
      body: Stack(
        children: [
          const _HelpSupportBackground(),
          SafeArea(
            child: Column(
              children: [
                const _HelpSupportHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QuickActionCard(
                          title: 'Need Help?',
                          subtitle: 'We’re Here For You 24×7',
                          amount: '',
                          buttonLabel: '',
                          imageAsset: FileConstants.quickAction,
                          showTail: true,
                          showLeadingImage: false,
                          onTap: () {
                            context.push(RouteConstants.helpCenterChat);
                          },
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          'Quick Support',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        SizedBox(height: 14.h),
                        SupportActionCard(
                          title: 'Chat With Us',
                          subtitle:
                              'Get Instant Help Through Live Chat — Available\n'
                              '24×7 For Payment And Wallet Issues.',
                          buttonLabel: 'Chat Now',
                          icon: Icons.chat_bubble_outline,
                          onTap: () {
                            context.push(RouteConstants.helpCenterChat);
                          },
                        ),
                        SizedBox(height: 14.h),
                        const SupportActionCard(
                          title: 'Call Support',
                          subtitle:
                              'Talk Directly With Our Customer Support Team For\n'
                              'Urgent Queries. Helpline: 1800–123–9876',
                          buttonLabel: 'Call Now',
                          icon: Icons.call,
                        ),
                        SizedBox(height: 14.h),
                        const SupportActionCard(
                          title: 'Email Support',
                          subtitle: 'Share Detailed Concerns Or Feedback At\n'
                              'support@erupaiya.com Response Within 24 Hours.',
                          buttonLabel: 'Send Email',
                          icon: Icons.mail_outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSupportBackground extends StatelessWidget {
  const _HelpSupportBackground();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120.h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE2D7), Color(0xFFFFF7F3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const Expanded(
          child: ColoredBox(color: Color(0xFFFFF7F3)),
        ),
      ],
    );
  }
}

class _HelpSupportHeader extends StatelessWidget {
  const _HelpSupportHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 16.w, 6.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 22.sp),
          ),
          SizedBox(width: 4.w),
          Text(
            'Help & Support',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
