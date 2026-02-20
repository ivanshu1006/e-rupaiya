import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/custom_elevated_button.dart';

class VerificationResultView extends StatelessWidget {
  const VerificationResultView({
    super.key,
    required this.isSuccess,
  });

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              isSuccess
                  ? FileConstants.verificationGreen
                  : FileConstants.verificationRed,
              fit: BoxFit.fitWidth,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, right: 24),
                    child: TextButton(
                      onPressed: () => context.go(RouteConstants.home),
                      child: Text(
                        'Skip',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        isSuccess
                            ? 'Verification Successful'
                            : 'Verification Failed',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isSuccess
                            ? 'Your PAN and Aadhaar details have been successfully verified. All your information matches our records.'
                            : 'The details in your PAN and Aadhaar do not match. Please check your information and try again, or update your records before proceeding.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: CustomElevatedButton(
                    onPressed: () {
                      if (isSuccess) {
                        context.go(RouteConstants.home);
                      } else {
                        context.pop();
                      }
                    },
                    label: isSuccess ? 'Continue to Home' : 'Try Again',
                    showArrow: false,
                    uppercaseLabel: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
