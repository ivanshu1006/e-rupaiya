// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/app_snackbar.dart';
import 'phone_number_input_card.dart';

class LoginForm extends HookWidget {
  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    this.onLoginTap,
  });

  final Future<void> Function(String name, String phoneNumber) onSubmit;
  final bool isLoading;
  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final allowConsent = useState(false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhoneNumberInputCard(
            nameController: nameController,
            controller: phoneController,
            onContinue: isLoading
                ? null
                : () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      AppSnackbar.show('Please enter your name');
                      return;
                    }
                    final phone = phoneController.text.trim();
                    if (phone.isEmpty || phone.length != 10) {
                      AppSnackbar.show('Enter a valid 10-digit mobile number');
                      return;
                    }
                    if (!allowConsent.value) {
                      AppSnackbar.show('Please allow access to continue');
                      return;
                    }
                    await onSubmit(name, phone);
                  },
            isConsentAllowed: allowConsent.value,
            onConsentChanged: (value) {
              allowConsent.value = value;
            },
            helperText: null,
            showHelper: false,
            enabled: !isLoading,
          ),
          SizedBox(height: 18.h),
          Text.rich(
            TextSpan(
              text: 'Already Have an account ? ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
              children: [
                TextSpan(
                  text: 'Login',
                  // ignore: prefer_const_constructors
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onLoginTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
