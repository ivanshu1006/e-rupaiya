// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:e_rupaiya/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../components/pin_input_row.dart';
import '../controllers/auth_controller.dart';

class AppLockView extends HookConsumerWidget {
  const AppLockView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final pinControllers = List.generate(4, (_) => useTextEditingController());
    final pinFocusNodes = List.generate(4, (_) => useFocusNode());
    final forgotOtpControllers =
        useMemoized(() => List.generate(4, (_) => TextEditingController()));
    final forgotOtpFocusNodes =
        useMemoized(() => List.generate(4, (_) => FocusNode()));
    final forgotPinControllers =
        useMemoized(() => List.generate(4, (_) => TextEditingController()));
    final forgotPinFocusNodes =
        useMemoized(() => List.generate(4, (_) => FocusNode()));
    final forgotConfirmControllers =
        useMemoized(() => List.generate(4, (_) => TextEditingController()));
    final forgotConfirmFocusNodes =
        useMemoized(() => List.generate(4, (_) => FocusNode()));
    final isLoading = useState(true);
    final isUnlocking = useState(false);
    final mobile = useState<String?>(null);
    final biometricAvailable = useState(false);
    final localAuth = useMemoized(() => LocalAuthentication());
    final biometricPrompted = useRef(false);
    final showForgotPin = useState(false);
    final forgotRemainingSeconds = useState(0);
    final forgotTimerRef = useRef<Timer?>(null);
    final isRequestingOtp = useState(false);

    useEffect(() {
      return () {
        for (final controller in [
          ...forgotOtpControllers,
          ...forgotPinControllers,
          ...forgotConfirmControllers,
        ]) {
          controller.dispose();
        }
        for (final focusNode in [
          ...forgotOtpFocusNodes,
          ...forgotPinFocusNodes,
          ...forgotConfirmFocusNodes,
        ]) {
          focusNode.dispose();
        }
      };
    }, const []);

    useEffect(() {
      Future.microtask(() async {
        const storage = FlutterSecureStorage();
        final storedMobile = await storage.read(key: 'mobile');
        final canCheck = await localAuth.canCheckBiometrics;
        final isDeviceSupported = await localAuth.isDeviceSupported();
        final enrolled = await localAuth.getAvailableBiometrics();
        biometricAvailable.value =
            canCheck && isDeviceSupported && enrolled.isNotEmpty;
        log(
          'Biometric checks: canCheck=$canCheck supported=$isDeviceSupported enrolled=${enrolled.length}',
        );
        if (storedMobile == null || storedMobile.isEmpty) {
          await ref.read(authControllerProvider.notifier).logout();
          if (context.mounted) {
            context.go(RouteConstants.login);
          }
          return;
        }
        mobile.value = storedMobile;
        isLoading.value = false;
      });
      return null;
    }, const []);

    Future<void> handleBiometric() async {
      if (!biometricAvailable.value) return;
      try {
        final didAuth = await localAuth.authenticate(
          localizedReason: 'Unlock with biometrics',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        if (didAuth && context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (_) {
        AppSnackbar.show('Biometric authentication failed');
      }
    }

    useEffect(() {
      if (isLoading.value) return null;
      if (!biometricAvailable.value) return null;
      if (showForgotPin.value) return null;
      if (biometricPrompted.value) return null;
      biometricPrompted.value = true;
      Future.microtask(handleBiometric);
      return null;
    }, [isLoading.value, biometricAvailable.value, showForgotPin.value]);

    Future<void> handleUnlock() async {
      if (isUnlocking.value) return;
      final pin = pinControllers.map((c) => c.text).join();
      if (pin.length != 4) {
        AppSnackbar.show('Please enter a 4-digit PIN');
        return;
      }
      final phone = mobile.value ?? '';
      if (phone.isEmpty) {
        AppSnackbar.show('Missing mobile number. Please login again.');
        await ref.read(authControllerProvider.notifier).logout();
        if (context.mounted) {
          context.go(RouteConstants.login);
        }
        return;
      }
      isUnlocking.value = true;
      final success = await ref.read(authControllerProvider.notifier).login(
            mobile: phone,
            pin: pin,
          );
      isUnlocking.value = false;
      if (success) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        AppSnackbar.show(
          ref.read(authControllerProvider).errorMessage ??
              'Invalid PIN. Try again.',
        );
        for (final c in pinControllers) {
          c.clear();
        }
        if (pinFocusNodes.isNotEmpty) {
          pinFocusNodes.first.requestFocus();
        }
      }
    }

    String joinDigits(List<TextEditingController> controllers) {
      return controllers.map((c) => c.text).join();
    }

    Future<void> requestForgotOtp() async {
      if (isRequestingOtp.value) return;
      isRequestingOtp.value = true;
      final message =
          await ref.read(authControllerProvider.notifier).requestForgotPinOtp();
      isRequestingOtp.value = false;
      if (!context.mounted) return;
      if (message != null) {
        AppSnackbar.show(message);
        forgotRemainingSeconds.value = 60;
        forgotTimerRef.value?.cancel();
        forgotTimerRef.value =
            Timer.periodic(const Duration(seconds: 1), (timer) {
          if (forgotRemainingSeconds.value <= 1) {
            forgotRemainingSeconds.value = 0;
            timer.cancel();
          } else {
            forgotRemainingSeconds.value -= 1;
          }
        });
        if (forgotOtpFocusNodes.isNotEmpty) {
          forgotOtpFocusNodes.first.requestFocus();
        }
      } else {
        AppSnackbar.show(
          ref.read(authControllerProvider).errorMessage ??
              'Failed to request OTP.',
        );
      }
    }

    Future<void> handleForgotResend() async {
      if (forgotRemainingSeconds.value > 0) return;
      await requestForgotOtp();
    }

    Future<void> handleForgotVerify() async {
      final otp = joinDigits(forgotOtpControllers);
      final pin = joinDigits(forgotPinControllers);
      final confirmPin = joinDigits(forgotConfirmControllers);
      if (otp.length != 4) {
        AppSnackbar.show('Please enter the 4-digit OTP.');
        return;
      }
      if (pin.length != 4) {
        AppSnackbar.show('Please enter a 4-digit PIN.');
        return;
      }
      if (confirmPin.length != 4) {
        AppSnackbar.show('Please confirm your 4-digit PIN.');
        return;
      }
      if (pin != confirmPin) {
        AppSnackbar.show('PIN and confirm PIN do not match.');
        return;
      }

      final message = await ref
          .read(authControllerProvider.notifier)
          .forgotPin(otp: otp, pin: pin);
      if (!context.mounted) return;
      if (message != null) {
        AppSnackbar.show(message);
        showForgotPin.value = false;
        for (final controller in [
          ...forgotOtpControllers,
          ...forgotPinControllers,
          ...forgotConfirmControllers,
        ]) {
          controller.clear();
        }
      } else {
        AppSnackbar.show(
          ref.read(authControllerProvider).errorMessage ??
              'Failed to reset PIN.',
        );
      }
    }

    useEffect(() {
      if (!showForgotPin.value) return null;
      Future.microtask(requestForgotOtp);
      return () {
        forgotTimerRef.value?.cancel();
      };
    }, [showForgotPin.value]);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        CircleAvatar(
                          radius: 38.r,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.lock_outline,
                            size: 34.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Please Enter Your Security Pin',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        SizedBox(height: 18.h),
                        if (!showForgotPin.value) ...[
                          PinInputRow(
                            controllers: pinControllers,
                            focusNodes: pinFocusNodes,
                            enabled: !isUnlocking.value,
                            onPinCompleted: (_) => handleUnlock(),
                          ),
                          SizedBox(height: 12.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => showForgotPin.value = true,
                              child: Text(
                                'Forgot PIN ?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textPrimary
                                          .withOpacity(0.6),
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Reset Your PIN',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Enter the 4-digit OTP sent to your mobile number.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textPrimary.withOpacity(0.6),
                                ),
                          ),
                          SizedBox(height: 12.h),
                          PinInputRow(
                            controllers: forgotOtpControllers,
                            focusNodes: forgotOtpFocusNodes,
                            enabled: !authState.isSubmitting,
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 18, color: AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Text(
                                '${(forgotRemainingSeconds.value ~/ 60).toString().padLeft(2, '0')}:${(forgotRemainingSeconds.value % 60).toString().padLeft(2, '0')}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: forgotRemainingSeconds.value == 0 &&
                                        !isRequestingOtp.value
                                    ? handleForgotResend
                                    : null,
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      forgotRemainingSeconds.value == 0
                                          ? AppColors.primary
                                          : AppColors.textPrimary
                                              .withOpacity(0.35),
                                ),
                                child: Text(
                                  isRequestingOtp.value
                                      ? 'Sending...'
                                      : 'Resend OTP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Divider(
                            color: AppColors.textPrimary.withOpacity(0.1),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Create New PIN',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          PinInputRow(
                            controllers: forgotPinControllers,
                            focusNodes: forgotPinFocusNodes,
                            enabled: !authState.isSubmitting,
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'Confirm PIN',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          PinInputRow(
                            controllers: forgotConfirmControllers,
                            focusNodes: forgotConfirmFocusNodes,
                            enabled: !authState.isSubmitting,
                          ),
                          SizedBox(height: 18.h),
                          CustomElevatedButton(
                            onPressed: authState.isSubmitting
                                ? null
                                : handleForgotVerify,
                            label: authState.isSubmitting
                                ? 'Verifying...'
                                : 'Verify & Continue',
                            uppercaseLabel: false,
                            showArrow: false,
                          ),
                          SizedBox(height: 8.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                showForgotPin.value = false;
                                for (final controller in [
                                  ...forgotOtpControllers,
                                  ...forgotPinControllers,
                                  ...forgotConfirmControllers,
                                ]) {
                                  controller.clear();
                                }
                              },
                              child: const Text('Back'),
                            ),
                          ),
                        ],
                        SizedBox(height: 26.h),
                        if (biometricAvailable.value &&
                            !showForgotPin.value) ...[
                          GestureDetector(
                            onTap: handleBiometric,
                            child: Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade100,
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.cardShadow,
                                    blurRadius: 10,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.fingerprint,
                                size: 30.sp,
                                color: AppColors.textPrimary.withOpacity(0.7),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Use Fingerprint Instead',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textPrimary.withOpacity(0.7),
                                ),
                          ),
                        ],
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
