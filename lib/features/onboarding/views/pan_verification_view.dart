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
import '../components/grey_info_card.dart';
import '../components/verification_text_field.dart';

class PanVerificationView extends HookConsumerWidget {
  const PanVerificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isVerified = useState(false);

    final panRegExp = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

    void handleSubmit() {
      final text = controller.text.toUpperCase();
      if (!panRegExp.hasMatch(text)) {
        AppSnackbar.show('Enter valid PAN (e.g. ABCDE1234F)');
        return;
      }
      isVerified.value = true;
      AppSnackbar.show('PAN verified successfully');
    }

    void handleContinue() {
      context.go(RouteConstants.aadhaarVerification);
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
                  'PAN Verification',
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
                  'Enter PAN Number',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                VerificationTextField(
                  controller: controller,
                  hintText: 'ABCDE1234F',
                  maxLength: 10,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefix: Image.asset(
                    FileConstants.pan,
                    height: 20,
                    width: 20,
                    color: AppColors.textPrimary,
                  ),
                  suffix: isVerified.value
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                if (isVerified.value) ...[
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Your PAN information has been fetched successfully.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const GreyInfoCard(
                    entries: {
                      'Name': 'Darshan Nikam',
                    },
                  ),
                ],
                const Spacer(),
                CustomElevatedButton(
                  onPressed: isVerified.value ? handleContinue : handleSubmit,
                  label: isVerified.value ? 'Continue' : 'Submit',
                  showArrow: false,
                  uppercaseLabel: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
