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
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/grey_text_form_field.dart';
import '../components/auth_brand_header.dart';
import '../components/otp_verification_card.dart';
import '../components/phone_number_input_card.dart';
import '../components/pin_input_row.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_flow.dart';

enum _LoginStep {
  mobile,
  pin,
  otp,
}

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final step = useState(_LoginStep.mobile);
    final phoneController = useTextEditingController();
    final allowConsent = useState(false);

    final pinControllers = useMemoized(
      () => List.generate(4, (_) => TextEditingController()),
      const [],
    );
    final pinFocusNodes =
        useMemoized(() => List.generate(4, (_) => FocusNode()), const []);
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
    final showForgotPin = useState(false);

    final otpControllers = useMemoized(
      () => List.generate(6, (_) => TextEditingController()),
      const [],
    );
    final otpFocusNodes =
        useMemoized(() => List.generate(6, (_) => FocusNode()), const []);
    final otpErrorText = useState<String?>(null);
    final remainingSeconds = useState(0);
    final timerRef = useRef<Timer?>(null);
    final forgotRemainingSeconds = useState(0);
    final forgotTimerRef = useRef<Timer?>(null);
    final isRequestingOtp = useState(false);

    useEffect(() {
      return () {
        for (final controller in [
          ...pinControllers,
          ...otpControllers,
          ...forgotOtpControllers,
          ...forgotPinControllers,
          ...forgotConfirmControllers,
        ]) {
          controller.dispose();
        }
        for (final node in [
          ...pinFocusNodes,
          ...otpFocusNodes,
          ...forgotOtpFocusNodes,
          ...forgotPinFocusNodes,
          ...forgotConfirmFocusNodes,
        ]) {
          node.dispose();
        }
        timerRef.value?.cancel();
        forgotTimerRef.value?.cancel();
      };
    }, const []);

    void startOtpTimer() {
      timerRef.value?.cancel();
      timerRef.value = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds.value <= 0) {
          timer.cancel();
          timerRef.value = null;
        } else {
          remainingSeconds.value--;
        }
      });
    }

    void resetToMobileStep() {
      step.value = _LoginStep.mobile;
      otpErrorText.value = null;
      remainingSeconds.value = 0;
      timerRef.value?.cancel();
      timerRef.value = null;
      isRequestingOtp.value = false;
      showForgotPin.value = false;
      for (final controller in otpControllers) {
        controller.clear();
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
      if (step.value == _LoginStep.otp) {
        remainingSeconds.value = 59;
        otpErrorText.value = null;
        startOtpTimer();
      } else {
        timerRef.value?.cancel();
        timerRef.value = null;
      }
      return null;
    }, [step.value]);

    useEffect(() {
      if (!showForgotPin.value) return null;
      Future.microtask(requestForgotOtp);
      return () {
        forgotTimerRef.value?.cancel();
      };
    }, [showForgotPin.value]);

    void resetToMobile() {
      step.value = _LoginStep.mobile;
      otpErrorText.value = null;
      showForgotPin.value = false;
      for (final controller in [
        ...pinControllers,
        ...otpControllers,
        ...forgotOtpControllers,
        ...forgotPinControllers,
        ...forgotConfirmControllers,
      ]) {
        controller.clear();
      }
    }

    Future<void> handleMobileContinue() async {
      final phone = phoneController.text.trim();
      if (phone.isEmpty || phone.length != 10) {
        AppSnackbar.show('Enter a valid 10-digit mobile number');
        return;
      }
      if (!allowConsent.value) {
        AppSnackbar.show('Please allow access to continue');
        return;
      }
      final flow = await ref
          .read(authControllerProvider.notifier)
          .checkLogin(mobile: phone);
      if (flow == null) {
        final latestState = ref.read(authControllerProvider);
        AppSnackbar.show(
          latestState.errorMessage ?? 'Failed to continue. Please try again.',
        );
        return;
      }
      step.value = flow == AuthFlow.login ? _LoginStep.pin : _LoginStep.otp;
    }

    Future<void> handlePinLogin() async {
      final phone = phoneController.text.trim();
      if (phone.isEmpty || phone.length != 10) {
        AppSnackbar.show('Enter a valid 10-digit mobile number');
        return;
      }
      final pin = pinControllers.map((c) => c.text).join();
      if (pin.length != 4) {
        AppSnackbar.show('Please enter a 4-digit PIN');
        return;
      }
      final success = await ref
          .read(authControllerProvider.notifier)
          .login(mobile: phone, pin: pin);
      if (success) {
        if (context.mounted) {
          context.go(RouteConstants.home);
        }
      } else {
        final latestState = ref.read(authControllerProvider);
        AppSnackbar.show(
          latestState.errorMessage ?? 'Login failed. Please try again.',
        );
      }
    }

    Future<void> handleOtpVerify() async {
      final otp = otpControllers.map((c) => c.text).join();
      if (otp.length < otpControllers.length) {
        otpErrorText.value = 'Please enter the 6-digit OTP.';
        return;
      }
      otpErrorText.value = null;
      final success =
          await ref.read(authControllerProvider.notifier).verifyOtp(otp: otp);
      if (success) {
        if (context.mounted) {
          context.go(RouteConstants.otpSuccess);
        }
      } else {
        final latestState = ref.read(authControllerProvider);
        otpErrorText.value = latestState.errorMessage ??
            "Oops! That OTP doesn't seem right. Please check and re-enter.";
      }
    }

    Future<void> handleResendOtp() async {
      final mobile = phoneController.text.trim();
      if (mobile.isEmpty || mobile.length != 10) {
        AppSnackbar.show('Enter a valid 10-digit mobile number');
        return;
      }
      final flow = await ref
          .read(authControllerProvider.notifier)
          .checkLogin(mobile: mobile);
      if (flow != null) {
        remainingSeconds.value = 59;
        otpErrorText.value = null;
        startOtpTimer();
        AppSnackbar.show('OTP resent to $mobile');
      } else {
        final latestState = ref.read(authControllerProvider);
        AppSnackbar.show(
          latestState.errorMessage ?? 'Failed to resend OTP. Please try again.',
        );
      }
    }

    Widget buildCard({required Widget child}) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: child,
        ),
      );
    }

    Widget buildPinCard() {
      return buildCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!showForgotPin.value) ...[
              Center(
                child: Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              SizedBox(height: 4.h),
              Center(
                child: Text(
                  'Log in to continue earning rewards.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.6),
                      ),
                ),
              ),
              SizedBox(height: 14.h),
            ],
            if (!showForgotPin.value) ...[
              Text(
                'Enter Mobile Number',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
              SizedBox(height: 6.h),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  GreyTextFormField(
                    controller: phoneController,
                    enabled: false,
                    isNumber: true,
                  ),
                  Positioned(
                    right: 8.w,
                    child: IconButton(
                      onPressed: authState.isSubmitting ? null : resetToMobile,
                      icon: Icon(
                        Icons.edit,
                        size: 18.sp,
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
            ],
            Text(
              'Enter PIN',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 6.h),
            if (!showForgotPin.value) ...[
              PinInputRow(
                controllers: pinControllers,
                focusNodes: pinFocusNodes,
                enabled: !authState.isSubmitting,
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: authState.isSubmitting
                      ? null
                      : () => showForgotPin.value = true,
                  child: const Text('Forgot PIN ?'),
                ),
              ),
              SizedBox(height: 12.h),
              CustomElevatedButton(
                onPressed: authState.isSubmitting ? null : handlePinLogin,
                label: authState.isSubmitting ? 'Logging in...' : 'Continue',
              ),
            ] else ...[
              Text(
                'Reset Your PIN',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Enter the 4-digit OTP sent to your mobile number.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                      foregroundColor: forgotRemainingSeconds.value == 0
                          ? AppColors.primary
                          : AppColors.textPrimary.withOpacity(0.35),
                    ),
                    child: Text(
                      isRequestingOtp.value ? 'Sending...' : 'Resend OTP',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Divider(color: AppColors.textPrimary.withOpacity(0.1)),
              SizedBox(height: 8.h),
              Text(
                'Create New PIN',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                onPressed: authState.isSubmitting ? null : handleForgotVerify,
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
          ],
        ),
      );
    }

    Widget buildOtpCard() {
      final timerText =
          '${(remainingSeconds.value ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds.value % 60).toString().padLeft(2, '0')}';
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OtpVerificationCard(
            controllers: otpControllers,
            focusNodes: otpFocusNodes,
            onVerify: handleOtpVerify,
            onResend: remainingSeconds.value == 0 ? handleResendOtp : null,
            timerText: timerText,
            errorMessage: otpErrorText.value,
            isVerifying: authState.isSubmitting,
            canResend: remainingSeconds.value == 0,
            onInputChanged: () => otpErrorText.value = null,
          ),
          SizedBox(height: 12.h),
          const SizedBox.shrink(),
        ],
      );
    }

    Widget buildContentCard() {
      switch (step.value) {
        case _LoginStep.mobile:
          return PhoneNumberInputCard(
            controller: phoneController,
            onContinue: authState.isSubmitting ? null : handleMobileContinue,
            isConsentAllowed: allowConsent.value,
            onConsentChanged: (value) => allowConsent.value = value,
            helperText: null,
            showHelper: false,
            enabled: !authState.isSubmitting,
          );
        case _LoginStep.pin:
          return buildPinCard();
        case _LoginStep.otp:
          return buildOtpCard();
      }
    }

    return PopScope(
      canPop: step.value == _LoginStep.mobile,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (step.value != _LoginStep.mobile) {
          resetToMobileStep();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset:
            !(step.value == _LoginStep.pin && showForgotPin.value),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final headerHeight = constraints.maxHeight * 0.62;

            return Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: headerHeight,
                      decoration: const BoxDecoration(
                        gradient: AppColors.authBackgroundGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: ColoredBox(color: Colors.white),
                    ),
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
                  left: 12,
                  right: 12,
                  bottom: 24,
                  child: buildContentCard(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
