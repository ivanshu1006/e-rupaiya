// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../components/pin_input_row.dart';
import '../controllers/auth_controller.dart';

class PinSetupView extends HookConsumerWidget {
  const PinSetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final newPinControllers =
        useMemoized(() => List.generate(4, (_) => TextEditingController()));
    final confirmControllers =
        useMemoized(() => List.generate(4, (_) => TextEditingController()));
    final newPinFocus = useMemoized(() => List.generate(4, (_) => FocusNode()));
    final confirmFocus =
        useMemoized(() => List.generate(4, (_) => FocusNode()));

    useEffect(() {
      return () {
        for (final c in [...newPinControllers, ...confirmControllers]) {
          c.dispose();
        }
        for (final f in [...newPinFocus, ...confirmFocus]) {
          f.dispose();
        }
      };
    }, const []);

    Future<void> handleSubmit() async {
      final newPin = newPinControllers.map((c) => c.text).join();
      final confirmPin = confirmControllers.map((c) => c.text).join();
      if (newPin.length != 4 || confirmPin.length != 4) {
        AppSnackbar.show('Please enter a 4-digit pin');
        return;
      }
      if (newPin != confirmPin) {
        AppSnackbar.show('Pins do not match');
        return;
      }
      final message =
          await ref.read(authControllerProvider.notifier).setPin(pin: newPin);
      if (message != null) {
        AppSnackbar.show(message);
        if (context.mounted) {
          context.go(RouteConstants.login);
        }
      } else {
        final latestState = ref.read(authControllerProvider);
        AppSnackbar.show(
          latestState.errorMessage ?? 'Failed to set PIN. Please try again.',
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.onboardingBackground,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a 4-digit PIN',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enhance your security with a personal access code.\nUse this PIN for quick and safe access to your E-Rupaiya wallet.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Add New PIN',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                PinInputRow(
                  controllers: newPinControllers,
                  focusNodes: newPinFocus,
                ),
                const SizedBox(height: 28),
                Text(
                  'Confirm New PIN',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                PinInputRow(
                  controllers: confirmControllers,
                  focusNodes: confirmFocus,
                ),
                const Spacer(),
                CustomElevatedButton(
                  onPressed: authState.isSubmitting ? null : handleSubmit,
                  label: authState.isSubmitting ? 'Saving...' : 'Confirm',
                  showArrow: false,
                  uppercaseLabel: false,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
