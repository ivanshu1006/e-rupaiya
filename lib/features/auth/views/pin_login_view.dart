// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../components/auth_brand_header.dart';
import '../components/login_input_card.dart';
import '../controllers/auth_controller.dart';

class PinLoginView extends HookConsumerWidget {
  const PinLoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    final phoneController = useTextEditingController();
    final pinControllers = List.generate(4, (_) => useTextEditingController());
    final pinFocusNodes = List.generate(4, (_) => useFocusNode());

    Future<void> handleLogin() async {
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoginInputCard(
                        phoneController: phoneController,
                        pinControllers: pinControllers,
                        pinFocusNodes: pinFocusNodes,
                        onContinue: handleLogin,
                        onForgotPin: () {
                          // TODO: Handle forgot PIN
                        },
                        enabled: !authState.isSubmitting,
                      ),
                      SizedBox(height: 18.h),
                      Text.rich(
                        TextSpan(
                          text: "Don\u2019t Have an account ? ",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                          children: [
                            TextSpan(
                              text: 'Register',
                              style: TextStyle(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  context.go(RouteConstants.register);
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
