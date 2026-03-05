// ignore_for_file: deprecated_member_use

import 'package:e_rupaiya/constants/routes_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../home/components/home_icon_tile.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WalletHeader(),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Referral Code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 10.h),
                  _ReferralCodeCard(),
                  SizedBox(height: 18.h),
                  Text(
                    'Coins Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 10.h),
                  _CoinsSummaryPill(),
                  SizedBox(height: 18.h),
                  Text(
                    'Use Coin For',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 14.h),
                  _UseCoinForRow(),
                ],
              ),
            ),
            SizedBox(height: 22.h),
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: -45.h,
                      child: Image.asset(
                        FileConstants.ellipse10,
                        width: constraints.maxWidth,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Text(
                            'How To Earn More Coins',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'Invite Friends → +100 Coins\n'
                            'Complete Your First Bill Payment → +75 Coins\n'
                            'Complete KYC → +50 Coins',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textPrimary.withOpacity(0.7),
                                  height: 1.5,
                                ),
                          ),
                          SizedBox(height: 18.h),
                          CustomElevatedButton(
                            onPressed: () {},
                            label: 'Refer A Friend Now',
                            uppercaseLabel: false,
                            height: 42.h,
                            isBorder: true,
                            backgroundColor: Colors.white,
                            borderColor: AppColors.primary,
                            labelColor: AppColors.primary,
                          ),
                          SizedBox(height: 12.h),
                          CustomElevatedButton(
                            onPressed: () {},
                            label: 'Use Coins',
                            uppercaseLabel: false,
                            height: 42.h,
                          ),
                          SizedBox(height: 80.h),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 26.h),
      decoration: const BoxDecoration(
        gradient: AppColors.onboardingBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  'My Wallet / Coins',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline,
                    color: AppColors.textPrimary),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 120.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earned',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '600',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: const Color(0xFF7A2E17),
                                fontWeight: FontWeight.w800,
                                fontSize: 64.sp,
                              ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'You Can Use Your Earned Coins To Pay Bills Or\n'
                      'Redeem Offers.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.7),
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -8.w,
                top: -8.h,
                child: Image.asset(
                  FileConstants.goldcoin,
                  width: 110.w,
                ),
              ),
              Positioned(
                right: 40.w,
                top: 32.h,
                child: Image.asset(
                  FileConstants.goldcoin,
                  width: 80.w,
                ),
              ),
              Positioned(
                right: -18.w,
                top: 70.h,
                child: Image.asset(
                  FileConstants.goldcoin,
                  width: 70.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const code = 'E-RUPAIYA78XZ';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: code));
              AppSnackbar.show('Referral code copied');
            },
            child: Text(
              'Copy Code',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinsSummaryPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0D4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Text(
            'Earned: 600 Coins',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          Text(
            'Used: 420',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          Text(
            'Balance',
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

class _UseCoinForRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 18.h,
      children: [
        HomeIconTile(
          label: 'Mobile\nPrepaid',
          asset: FileConstants.mobile,
          onTap: () => context.push(RouteConstants.mobileRecentRecharges),
          iconSize: 28,
        ),
        HomeIconTile(
          label: 'Broadband\nPostpaid',
          asset: FileConstants.broadband,
          onTap: () => context.push(
            RouteConstants.billerListing,
            extra: 'Broadband Postpaid',
          ),
          iconSize: 28,
        ),
        HomeIconTile(
          label: 'DTH',
          asset: FileConstants.dth,
          onTap: () => context.push(
            RouteConstants.billerListing,
            extra: 'DTH',
          ),
          iconSize: 28,
        ),
        HomeIconTile(
          label: 'Cable TV',
          asset: FileConstants.cable,
          onTap: () => context.push(
            RouteConstants.billerListing,
            extra: 'Cable TV',
          ),
          iconSize: 28,
        ),
      ],
    );
  }
}
