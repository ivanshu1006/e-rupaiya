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
import '../components/pin_input_row.dart';
import '../components/phone_number_input_card.dart';
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

    final otpControllers = useMemoized(
      () => List.generate(6, (_) => TextEditingController()),
      const [],
    );
    final otpFocusNodes =
        useMemoized(() => List.generate(6, (_) => FocusNode()), const []);
    final otpErrorText = useState<String?>(null);
    final remainingSeconds = useState(0);
    final timerRef = useRef<Timer?>(null);

    useEffect(() {
      return () {
        for (final controller in [
          ...pinControllers,
          ...otpControllers,
        ]) {
          controller.dispose();
        }
        for (final node in [
          ...pinFocusNodes,
          ...otpFocusNodes,
        ]) {
          node.dispose();
        }
        timerRef.value?.cancel();
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

    void resetToMobile() {
      step.value = _LoginStep.mobile;
      otpErrorText.value = null;
      for (final controller in [
        ...pinControllers,
        ...otpControllers,
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
            Text(
              'Enter Mobile Number',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 6.h),
            GreyTextFormField(
              controller: phoneController,
              enabled: false,
              isNumber: true,
            ),
            SizedBox(height: 14.h),
            Text(
              'Enter PIN',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            SizedBox(height: 6.h),
            PinInputRow(
              controllers: pinControllers,
              focusNodes: pinFocusNodes,
              enabled: !authState.isSubmitting,
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: authState.isSubmitting ? null : resetToMobile,
                child: const Text('Change number'),
              ),
            ),
            SizedBox(height: 12.h),
            CustomElevatedButton(
              onPressed: authState.isSubmitting ? null : handlePinLogin,
              label: authState.isSubmitting ? 'Logging in...' : 'Continue',
            ),
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
          TextButton(
            onPressed: authState.isSubmitting ? null : resetToMobile,
            child: const Text('Change number'),
          ),
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

    return Scaffold(
      backgroundColor: Colors.white,
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
    );
  }
}
