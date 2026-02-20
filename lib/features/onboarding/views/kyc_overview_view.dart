// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frappe_flutter_app/constants/file_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../components/kyc_action_tile.dart';

class KycOverviewView extends HookConsumerWidget {
  const KycOverviewView({super.key, this.selectedLanguage});

  final String? selectedLanguage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void navigate(String route) {
      context.go(route);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.onboardingBackground,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Verify KYC Details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    TextButton(
                      onPressed: () => navigate(RouteConstants.panVerification),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'To use e-Rupaiya and earn rewards, please complete your KYC.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                      ),
                ),
                // if (selectedLanguage != null) ...[
                //   const SizedBox(height: 6),
                //   Text(
                //     'Selected language: $selectedLanguage',
                //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                //           color: AppColors.textPrimary.withOpacity(0.7),
                //         ),
                //   ),
                // ],
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      KycActionTile(
                        title: 'PAN Card Verification',
                        iconAsset: FileConstants.pan,
                        onTap: () => navigate(RouteConstants.panVerification),
                      ),
                      const SizedBox(height: 14),
                      KycActionTile(
                        title: 'Aadhaar Verification',
                        iconAsset: FileConstants.aadhaar,
                        onTap: () =>
                            navigate(RouteConstants.aadhaarVerification),
                      ),
                    ],
                  ),
                ),
                CustomElevatedButton(
                  onPressed: () => navigate(RouteConstants.panVerification),
                  label: 'Continue',
                  showArrow: false,
                  uppercaseLabel: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
