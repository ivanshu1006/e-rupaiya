// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../components/pin_input_row.dart';
import '../controllers/auth_controller.dart';

class AppLockView extends HookConsumerWidget {
  const AppLockView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinControllers = List.generate(4, (_) => useTextEditingController());
    final pinFocusNodes = List.generate(4, (_) => useFocusNode());
    final isLoading = useState(true);
    final mobile = useState<String?>(null);
    final biometricAvailable = useState(false);
    final localAuth = useMemoized(() => LocalAuthentication());

    useEffect(() {
      Future.microtask(() async {
        const storage = FlutterSecureStorage();
        final storedMobile = await storage.read(key: 'mobile');
        final canCheck = await localAuth.canCheckBiometrics;
        final isDeviceSupported = await localAuth.isDeviceSupported();
        final enrolled = await localAuth.getAvailableBiometrics();
        biometricAvailable.value =
            canCheck && isDeviceSupported && enrolled.isNotEmpty;
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

    Future<void> handleUnlock() async {
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
      final success =
          await ref.read(authControllerProvider.notifier).login(
                mobile: phone,
                pin: pin,
              );
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      SizedBox(height: 18.h),
                      PinInputRow(
                        controllers: pinControllers,
                        focusNodes: pinFocusNodes,
                      ),
                      SizedBox(height: 12.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot PIN ?',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textPrimary.withOpacity(0.6),
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ),
                      SizedBox(height: 26.h),
                      if (biometricAvailable.value) ...[
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color:
                                        AppColors.textPrimary.withOpacity(0.7),
                                  ),
                        ),
                      ],
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleUnlock,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Unlock',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
