// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frappe_flutter_app/constants/file_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../auth/components/pin_input_row.dart';
import '../components/aadhaar_input_formatter.dart';
import '../components/verification_text_field.dart';

class AadhaarVerificationView extends HookConsumerWidget {
  const AadhaarVerificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aadhaarController = useTextEditingController();
    final isOtpStage = useState(false);

    final otpControllers = useMemoized(
      () => List.generate(4, (_) => TextEditingController()),
      const [],
    );
    final otpFocusNodes = useMemoized(
      () => List.generate(4, (_) => FocusNode()),
      const [],
    );

    useEffect(() {
      return () {
        for (final controller in otpControllers) {
          controller.dispose();
        }
        for (final node in otpFocusNodes) {
          node.dispose();
        }
      };
    }, const []);

    void handleConfirm() {
      final digits = aadhaarController.text.replaceAll(' ', '');
      if (digits.length != 12) {
        AppSnackbar.show('Enter 12-digit Aadhaar number');
        return;
      }
      isOtpStage.value = true;
      AppSnackbar.show('OTP sent to your Aadhaar linked mobile');
    }

    void handleVerify() {
      final otp = otpControllers.map((c) => c.text).join();
      if (otp.length != 4) {
        AppSnackbar.show('Enter 4 digit OTP');
        return;
      }

      final isSuccess = otp == '1234';
      context.go(RouteConstants.verificationResult, extra: isSuccess);
    }

    String buttonLabel;
    VoidCallback buttonAction;
    if (!isOtpStage.value) {
      buttonLabel = 'Confirm';
      buttonAction = handleConfirm;
    } else {
      buttonLabel = 'Verify';
      buttonAction = handleVerify;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.onboardingBackground,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aadhar Verification',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'To use e-Rupaiya and earn rewards, please complete your KYC.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter Aadhaar (12 Digits)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                VerificationTextField(
                  controller: aadhaarController,
                  hintText: '1234 1234 1234',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    AadhaarInputFormatter(),
                  ],
                  maxLength: 14,
                  prefix: Image.asset(
                    FileConstants.aadhaar,
                    height: 20,
                    width: 20,
                    color: AppColors.textPrimary,
                  ),
                  suffix: Icon(
                    Icons.check_circle,
                    color: isOtpStage.value ? AppColors.primary : Colors.grey,
                  ),
                ),
                if (isOtpStage.value) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Enter OTP',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  PinInputRow(
                    controllers: otpControllers,
                    focusNodes: otpFocusNodes,
                  ),
                ],
                const Spacer(),
                CustomElevatedButton(
                  onPressed: buttonAction,
                  label: buttonLabel,
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
