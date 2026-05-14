// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../constants/app_colors.dart';
import '../features/profile/models/api_response_model.dart';
import '../features/profile/repositories/profile_repository.dart';
import 'app_snackbar.dart';
import 'custom_elevated_button.dart';

class CompleteProfileDialog extends StatefulWidget {
  const CompleteProfileDialog({
    super.key,
    this.onCompleted,
  });

  final VoidCallback? onCompleted;

  @override
  State<CompleteProfileDialog> createState() => _CompleteProfileDialogState();
}

enum _ProfileStep { details, otp, done }

class _CompleteProfileDialogState extends State<CompleteProfileDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  final _emailFocus = FocusNode();
  final _otpFocus = FocusNode();

  _ProfileStep _step = _ProfileStep.details;
  bool _isSubmitting = false;
  bool _otpVerified = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _emailFocus.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  bool _isValidEmail(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  }

  Future<void> _sendOtp() async {
    if (_isSubmitting) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) {
      AppSnackbar.show('Please enter your name');
      return;
    }
    if (!_isValidEmail(email)) {
      AppSnackbar.show('Please enter a valid email');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _otpVerified = false;
    });
    try {
      final repo = ProfileRepository();
      final ApiResponse resp = await repo.updateEmail(email);
      if (!resp.success) {
        AppSnackbar.show(resp.message.isNotEmpty ? resp.message : 'Failed to send OTP');
        return;
      }
      setState(() => _step = _ProfileStep.otp);
      _otpController.clear();
      _otpFocus.requestFocus();
      AppSnackbar.show(
        resp.message.isNotEmpty ? resp.message : 'OTP sent to $email',
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
      );
    } catch (e) {
      AppSnackbar.show('Failed to send OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_isSubmitting) return;
    final otp = _otpController.text.trim();
    if (otp.length != 4) {
      AppSnackbar.show('Please enter the 4-digit OTP');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ProfileRepository();
      final ApiResponse resp = await repo.verifyEmailOtp(otp);
      if (!resp.success) {
        AppSnackbar.show(resp.message.isNotEmpty ? resp.message : 'OTP verification failed');
        return;
      }
      setState(() => _otpVerified = true);

      // Persist name/email (address optional).
      try {
        await repo.updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          address: '',
        );
      } catch (_) {}

      setState(() => _step = _ProfileStep.done);
    } catch (_) {
      AppSnackbar.show('OTP verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _headerIcon() {
    switch (_step) {
      case _ProfileStep.details:
        return Container(
          width: 54.r,
          height: 54.r,
          decoration: const BoxDecoration(
            color: Color(0xFF0B8F3A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        );
      case _ProfileStep.otp:
        return Container(
          width: 54.r,
          height: 54.r,
          decoration: BoxDecoration(
            color: const Color(0xFF0B8F3A).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0B8F3A), width: 2),
          ),
          child: const Icon(Icons.shield, color: Color(0xFF0B8F3A), size: 28),
        );
      case _ProfileStep.done:
        return Container(
          width: 70.r,
          height: 70.r,
          decoration: const BoxDecoration(
            color: Color(0xFF0B8F3A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        );
    }
  }

  Widget _dividerOr() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.textPrimary.withOpacity(0.18))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.textPrimary.withOpacity(0.18))),
      ],
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: OutlinedButton(
        onPressed: _isSubmitting ? null : () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.textPrimary.withOpacity(0.12)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple "G" mark without extra assets.
            Text(
              'G',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Continue with Google',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complete Your Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Please enter your name and\nemail ID to continue.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary.withOpacity(0.8),
                height: 1.25,
              ),
        ),
        SizedBox(height: 18.h),
        Text(
          'Enter Your Name',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        SizedBox(height: 8.h),
        _InputBox(
          controller: _nameController,
          enabled: !_isSubmitting,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _emailFocus.requestFocus(),
          hintText: 'Name',
        ),
        SizedBox(height: 16.h),
        Text(
          'Enter Your Email',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        SizedBox(height: 8.h),
        _InputBox(
          controller: _emailController,
          focusNode: _emailFocus,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _sendOtp(),
          hintText: 'email@example.com',
        ),
        SizedBox(height: 18.h),
        CustomElevatedButton(
          onPressed: _isSubmitting ? null : _sendOtp,
          label: _isSubmitting ? 'Please wait...' : 'Continue',
          uppercaseLabel: false,
          height: 44.h,
        ),
        SizedBox(height: 14.h),
        _dividerOr(),
        SizedBox(height: 14.h),
        _googleButton(),
      ],
    );
  }

  Widget _otpStep() {
    final email = _emailController.text.trim();
    final pinTheme = PinTheme(
      width: 58.w,
      height: 52.w,
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF0B8F3A)),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify OTP',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Enter the 4-digit OTP sent to $email\nemail ID.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary.withOpacity(0.8),
                height: 1.25,
              ),
        ),
        SizedBox(height: 18.h),
        Pinput(
          controller: _otpController,
          focusNode: _otpFocus,
          length: 4,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.number,
          defaultPinTheme: pinTheme,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onCompleted: (_) => _verifyOtp(),
        ),
        SizedBox(height: 12.h),
        if (_otpVerified)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0B8F3A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Color(0xFF0B8F3A), size: 18),
                SizedBox(width: 6.w),
                Text(
                  'OTP Verified',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF0B8F3A),
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        SizedBox(height: 18.h),
        CustomElevatedButton(
          onPressed: _isSubmitting ? null : _verifyOtp,
          label: _isSubmitting ? 'Verifying...' : 'Verify OTP',
          uppercaseLabel: false,
          height: 44.h,
        ),
      ],
    );
  }

  Widget _doneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Profile setup is\ncompleted',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Your details have been verified successfully.\nYou can now continue using the app.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary.withOpacity(0.7),
                height: 1.25,
              ),
        ),
        SizedBox(height: 18.h),
        CustomElevatedButton(
          onPressed: () {
            widget.onCompleted?.call();
            Navigator.of(context).pop();
          },
          label: 'Continue',
          uppercaseLabel: false,
          height: 44.h,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    switch (_step) {
      case _ProfileStep.details:
        content = _detailsStep();
        break;
      case _ProfileStep.otp:
        content = _otpStep();
        break;
      case _ProfileStep.done:
        content = _doneStep();
        break;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 18.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22.r),
          child: Container(
            padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 18.h),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(alignment: Alignment.centerLeft, child: _headerIcon()),
                SizedBox(height: 12.h),
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    this.focusNode,
    required this.enabled,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.hintText,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.textPrimary.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.textPrimary.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}
