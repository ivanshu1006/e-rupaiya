// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../components/auth_brand_header.dart';
import '../components/otp_verification_card.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationView extends HookConsumerWidget {
  const OtpVerificationView({super.key, this.phoneNumber});

  final String? phoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final controllers = useMemoized(
      () => List.generate(6, (_) => TextEditingController()),
      const [],
    );
    final focusNodes = useMemoized(
      () => List.generate(6, (_) => FocusNode()),
      const [],
    );

    useEffect(() {
      return () {
        for (final controller in controllers) {
          controller.dispose();
        }
        for (final node in focusNodes) {
          node.dispose();
        }
      };
    }, const []);

    final remainingSeconds = useState(5);
    final errorText = useState<String?>(null);
    final timerRef = useRef<Timer?>(null);

    void startTimer() {
      timerRef.value?.cancel();
      timerRef.value = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds.value == 0) {
          timer.cancel();
          timerRef.value = null;
        } else {
          remainingSeconds.value--;
        }
      });
    }

    useEffect(() {
      startTimer();
      return () {
        timerRef.value?.cancel();
      };
    }, const []);

    final timerText =
        '${(remainingSeconds.value ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds.value % 60).toString().padLeft(2, '0')}';

    Future<void> handleVerify() async {
      final otp = controllers.map((c) => c.text).join();
      if (otp.length < controllers.length) {
        errorText.value = 'Please enter the 6-digit OTP.';
        return;
      }

      errorText.value = null;
      final success = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(otp: otp, userId: phoneNumber);
      if (success) {
        if (context.mounted) {
          context.go(RouteConstants.otpSuccess);
        }
      } else {
        final latestState = ref.read(authControllerProvider);
        errorText.value = latestState.errorMessage ??
            "Oops! That OTP doesn't seem right. Please check and re-enter.";
      }
    }

    Future<void> handleResend() async {
      final resolvedMobile = phoneNumber ?? authState.pendingMobile;
      if (resolvedMobile == null || resolvedMobile.isEmpty) {
        AppSnackbar.show('Missing mobile number. Please try again.');
        return;
      }

      final flow = await ref
          .read(authControllerProvider.notifier)
          .checkLogin(mobile: resolvedMobile);
      if (flow != null) {
        remainingSeconds.value = 59;
        errorText.value = null;
        startTimer();
        AppSnackbar.show('OTP resent to $resolvedMobile');
      } else {
        final latestState = ref.read(authControllerProvider);
        AppSnackbar.show(
          latestState.errorMessage ?? 'Failed to resend OTP. Please try again.',
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight = constraints.maxHeight * 0.63;

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: headerHeight,
                    decoration: const BoxDecoration(
                      gradient: AppColors.authBackgroundGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                  ),
                  const Expanded(child: ColoredBox(color: Colors.white)),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: const AuthBrandHeader(),
              ),
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 24.h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OtpVerificationCard(
                      controllers: controllers,
                      focusNodes: focusNodes,
                      onVerify: handleVerify,
                      onResend:
                          remainingSeconds.value == 0 ? handleResend : null,
                      timerText: timerText,
                      errorMessage: errorText.value,
                      isVerifying: authState.isSubmitting,
                      canResend: remainingSeconds.value == 0,
                      onInputChanged: () => errorText.value = null,
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: () => context.go(RouteConstants.login),
                      child: Column(
                        children: [
                          Text(
                            'Incorrect Mobile Number ?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      AppColors.textPrimary.withOpacity(0.75),
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Change now ↻',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
