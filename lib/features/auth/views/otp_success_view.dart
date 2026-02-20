// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/custom_elevated_button.dart';

class OtpSuccessView extends HookConsumerWidget {
  const OtpSuccessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingSeconds = useState(5);
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final nextValue = remainingSeconds.value - 1;
        remainingSeconds.value = nextValue;
        if (nextValue <= 0) {
          timer.cancel();
          if (context.mounted) {
            context.go(RouteConstants.addPin);
          }
        }
      });
      return timer.cancel;
    }, const []);

    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.otpSuccessBackground,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Image.asset(
                    FileConstants.logo,
                    height: 48,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'OTP Verified Successfully',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your number has been verified.\nRedirecting you to the home page...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.75),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Redirecting in ${remainingSeconds.value.clamp(0, 5)} sec',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.info_outline,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Protect your account and keep every transaction secure.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomElevatedButton(
                  onPressed: () => context.go(RouteConstants.addPin),
                  label: 'Secure app',
                  showArrow: false,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
