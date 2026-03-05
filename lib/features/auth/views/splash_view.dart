import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../controllers/auth_controller.dart';

class SplashView extends HookConsumerWidget {
  const SplashView({super.key, this.duration = const Duration(seconds: 2)});

  final Duration duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final timerDone = useState(false);

    // Start a one-shot timer that fires after the splash duration.
    useEffect(() {
      final timer = Timer(duration, () {
        timerDone.value = true;
      });
      return timer.cancel;
    }, []);

    // Navigate only after the timer is done AND auth has resolved.
    useEffect(() {
      if (!timerDone.value || authState.isLoading) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (authState.isAuthenticated) {
          context.go(RouteConstants.home);
        } else {
          context.go(RouteConstants.login);
        }
      });
      return null;
    }, [timerDone.value, authState.isLoading, authState.isAuthenticated]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Center logo + app name
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    FileConstants.wallet,
                    height: 90.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'e-rupaiya',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Digital Partners section
            Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Digital Partners',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        FileConstants.bharatConnectColor,
                        height: 28.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 24.w),
                      Image.asset(
                        FileConstants.upi,
                        height: 28.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 24.w),
                      Image.asset(
                        FileConstants.npci,
                        height: 28.h,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
