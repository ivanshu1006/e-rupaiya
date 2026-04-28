import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../controllers/auth_controller.dart';

class SplashView extends HookConsumerWidget {
  const SplashView({super.key, this.duration = const Duration(seconds: 4)});

  final Duration duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final timerDone = useState(false);
    final assetsReady = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
      });
      return null;
    }, const []);

    // Start a one-shot timer that fires after the splash duration.
    useEffect(() {
      var isActive = true;
      Timer? timer;

      Future<void> startTimer() async {
        Duration resolved = duration;
        try {
          final data = await rootBundle.load(FileConstants.splashGif);
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
          );
          var total = Duration.zero;
          for (var i = 0; i < codec.frameCount; i++) {
            final frame = await codec.getNextFrame();
            total += frame.duration;
          }
          if (total.inMilliseconds > 0) {
            resolved = total;
          }
        } catch (_) {
          // Fallback to the provided duration.
        }

        if (!isActive) return;
        timer = Timer(resolved, () {
          timerDone.value = true;
        });
      }

      startTimer();
      return () {
        isActive = false;
        timer?.cancel();
      };
    }, [duration]);

    useEffect(() {
      var isActive = true;
      Future<void> preload() async {
        try {
          if (!context.mounted) return;
          await precacheImage(
            AssetImage(FileConstants.splashGif),
            context,
          );
          if (!context.mounted) return;
          await precacheImage(
            AssetImage(FileConstants.bharatConnectColor),
            context,
          );
        } catch (_) {
          // Ignore preload errors; show immediately.
        }
        if (isActive) {
          assetsReady.value = true;
        }
      }

      preload();
      return () {
        isActive = false;
      };
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
                  AnimatedOpacity(
                    opacity: assetsReady.value ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Image.asset(
                      FileConstants.splashGif,
                      height: 120.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // SizedBox(height: 16.h),
                  // Text(
                  //   'e-rupaiya',
                  //   style: TextStyle(
                  //     fontSize: 22.sp,
                  //     fontWeight: FontWeight.w600,
                  //     color: const Color(0xFF333333),
                  //     letterSpacing: 0.5,
                  //   ),
                  // ),
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
                  AnimatedOpacity(
                    opacity: assetsReady.value ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
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
                            // SizedBox(width: 24.w),
                            // Image.asset(
                            //   FileConstants.upi,
                            //   height: 28.h,
                            //   fit: BoxFit.contain,
                            // ),
                            // SizedBox(width: 24.w),
                            // Image.asset(
                            //   FileConstants.npci,
                            //   height: 28.h,
                            //   fit: BoxFit.contain,
                            // ),
                          ],
                        ),
                      ],
                    ),
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
