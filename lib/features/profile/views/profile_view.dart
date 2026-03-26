// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:e_rupaiya/features/auth/controllers/auth_controller.dart';
import 'package:e_rupaiya/features/refer_and_earn/views/refer_and_earn_wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:pinput/pinput.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/image_picker_helper.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/profile_image_picker_sheet.dart';
import '../../home/components/quick_action_card.dart';
import '../../kyc/views/complete_kyc_view.dart';
import '../components/profile_field.dart';
import '../components/profile_shimmer.dart';
import '../controllers/profile_controller.dart';
import '../models/profile_model.dart';
import 'bank_accounts_view.dart';

class ProfileView extends HookConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;

    useEffect(() {
      Future.microtask(
        () => ref.read(profileControllerProvider.notifier).fetchProfile(),
      );
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: profileState.isFetching && profile == null
            ? const ProfileShimmer()
            : Column(
                children: [
                  // Header: Avatar + Name + Close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.gradientStart,
                          child: profile?.profilePhotoUrl?.isNotEmpty == true
                              ? AppNetworkImage(
                                  url: profile!.profilePhotoUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(24),
                                  showShimmer: false,
                                )
                              : Text(
                                  profile?.initials ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            profile?.name ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () => context.pop(),
                        //   child: const Icon(
                        //     Icons.close,
                        //     color: AppColors.textPrimary,
                        //     size: 24,
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // My QR Code card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: QuickActionCard(
                      title: 'My QR Code',
                      subtitle: '',
                      amount: '',
                      buttonLabel: '',
                      imageAsset: FileConstants.qr,
                      onTap: () {
                        context.push(RouteConstants.myQr);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Menu items
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _ProfileMenuItem(
                            icon: Icons.person_outline,
                            label: 'Profile',
                            trailing: (profile?.isKycVerified ?? false)
                                ? const _VerifiedBadge()
                                : GestureDetector(
                                    onTap: () {
                                      PersistentNavBarNavigator.pushNewScreen(
                                        context,
                                        screen: const CompleteKycView(),
                                        withNavBar: false,
                                      );
                                    },
                                    child: const _KycBadge(),
                                  ),
                            onTap: () {
                              if (profile == null) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => UpdateProfileView(
                                    profile: profile,
                                  ),
                                ),
                              );
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.local_offer_outlined,
                            label: 'Offers',
                            onTap: () => context.push(RouteConstants.offers),
                          ),
                          _ProfileMenuItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'My Wallet',
                            onTap: () {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (_) =>
                              //         const ReferAndEarnWalletView(),
                              //   ),
                              // );
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: const ReferAndEarnWalletView(),
                                withNavBar: false,
                              );
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.account_balance_outlined,
                            label: 'Bank Account',
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: const BankAccountsView(),
                                withNavBar: false,
                              );
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.swap_horiz,
                            label: 'Transactions',
                            onTap: () {
                              context.push(RouteConstants.transactions);
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onTap: () {
                              context.push(RouteConstants.settings);
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.support_agent_outlined,
                            label: 'Help, Support & Contact Us',
                            onTap: () {
                              context.push(RouteConstants.helpSupport);
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.help_outline,
                            label: 'FAQs',
                            onTap: () {
                              context.push(RouteConstants.faq);
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Legal & Policy Document',
                            onTap: () {
                              context.push(RouteConstants.termsPrivacy);
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.policy_outlined,
                            label: 'Privacy Policy',
                            onTap: () {
                              context.push(RouteConstants.privacyPolicy);
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.info_outline,
                            label: 'About Us',
                            onTap: () {
                              context.push(RouteConstants.aboutUs);
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.logout,
                            label: 'Logout',
                            onTap: () {
                              KDialog.instance.openDialog(
                                dialog: AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text('Logout'),
                                  content: const Text(
                                    'Are you sure you want to logout?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          navigatorKey.currentState?.pop(),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: AppColors.textPrimary
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        navigatorKey.currentState?.pop();
                                        await ref
                                            .read(
                                                authControllerProvider.notifier)
                                            .logout();
                                        if (context.mounted) {
                                          context.go(RouteConstants.login);
                                        }
                                      },
                                      child: const Text(
                                        'Logout',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // // Footer: Version
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 16, top: 8),
                  //   child: FutureBuilder<String>(
                  //     future: Utils.getAppVersion(),
                  //     builder: (context, snapshot) {
                  //       final version = snapshot.data ?? '';
                  //       return Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Image.asset(
                  //             FileConstants.appLogo,
                  //             height: 22,
                  //             width: 22,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Text(
                  //             'Version $version',
                  //             style: Theme.of(context)
                  //                 .textTheme
                  //                 .bodyMedium
                  //                 ?.copyWith(
                  //                   color:
                  //                       AppColors.textPrimary.withOpacity(0.6),
                  //                 ),
                  //           ),
                  //         ],
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _KycBadge extends StatelessWidget {
  const _KycBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Complete Your KYC',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            size: 14,
            color: AppColors.green,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class UpdateProfileView extends HookConsumerWidget {
  const UpdateProfileView({super.key, required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(profileControllerProvider.notifier);
    final state = ref.watch(profileControllerProvider);
    final latestProfile = state.profile ?? profile;
    final pickedImage = useState<File?>(null);
    final fullNameController = useTextEditingController();
    final emailController = useTextEditingController(
      text: profile.email ?? '',
    );
    final mobileController = useTextEditingController(text: profile.mobile);
    final addressController = useTextEditingController(
      text: profile.address ?? '',
    );
    final aadhaarController = useTextEditingController(
      text: profile.aadhaarMasked ?? '',
    );
    final panController = useTextEditingController(
      text: profile.panMasked ?? '',
    );
    final permanentAddressController = useTextEditingController(
      text: profile.permanentAddress ?? '',
    );
    final dobController = useTextEditingController(
      text: profile.dob ?? '',
    );
    useListenable(fullNameController);
    useListenable(addressController);
    useListenable(mobileController);

    useEffect(() {
      fullNameController.text = profile.name.trim();
      return null;
    }, const []);

    final canEdit = !latestProfile.isKycVerified;
    final initialFullName = profile.name.trim();
    final initialAddress = (profile.address ?? '').trim();
    final initialMobile = profile.mobile.trim();

    final currentFullName = fullNameController.text.trim();
    final currentAddress = addressController.text.trim();
    final currentMobile = mobileController.text.trim();
    final hasCommunicationChange = currentAddress != initialAddress;
    final hasNonEmailChanges = currentFullName != initialFullName ||
        currentMobile != initialMobile ||
        hasCommunicationChange;
    final canSave = hasNonEmailChanges && (canEdit || hasCommunicationChange);

    useEffect(() {
      final updatedEmail = state.profile?.email ?? '';
      if (emailController.text != updatedEmail) {
        emailController.text = updatedEmail;
      }
      return null;
    }, [state.profile?.email]);

    useEffect(() {
      final updatedProfile = state.profile;
      if (updatedProfile == null) return null;
      final updatedAadhaar = updatedProfile.aadhaarMasked ?? '';
      if (aadhaarController.text != updatedAadhaar) {
        aadhaarController.text = updatedAadhaar;
      }
      final updatedPan = updatedProfile.panMasked ?? '';
      if (panController.text != updatedPan) {
        panController.text = updatedPan;
      }
      final updatedPermanent = updatedProfile.permanentAddress ?? '';
      if (permanentAddressController.text != updatedPermanent) {
        permanentAddressController.text = updatedPermanent;
      }
      final updatedDob = updatedProfile.dob ?? '';
      if (dobController.text != updatedDob) {
        dobController.text = updatedDob;
      }
      return null;
    }, [
      state.profile?.aadhaarMasked,
      state.profile?.panMasked,
      state.profile?.permanentAddress,
      state.profile?.dob,
    ]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Update Profile',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primary,
                          child: ClipOval(
                            child: pickedImage.value != null
                                ? Image.file(
                                    pickedImage.value!,
                                    width: 84,
                                    height: 84,
                                    fit: BoxFit.cover,
                                  )
                                : profile.profilePhotoUrl?.isNotEmpty == true
                                    ? AppNetworkImage(
                                        url: profile.profilePhotoUrl,
                                        width: 84,
                                        height: 84,
                                        fit: BoxFit.cover,
                                        showShimmer: false,
                                      )
                                    : Text(
                                        profile.initials,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              KDialog.instance.openSheet(
                                dialog: ProfileImagePickerSheet(
                                  onCamera: () async {
                                    navigatorKey.currentState?.pop();
                                    final image =
                                        await ImagePickerHelper.pickFromCamera();
                                    if (image == null) return;
                                    pickedImage.value = image;
                                    final ok =
                                        await controller.updateProfileImage(
                                      image,
                                    );
                                    if (!ok) {
                                      pickedImage.value = null;
                                    }
                                  },
                                  onGallery: () async {
                                    navigatorKey.currentState?.pop();
                                    final image =
                                        await ImagePickerHelper.pickFromGallery();
                                    if (image == null) return;
                                    pickedImage.value = image;
                                    final ok =
                                        await controller.updateProfileImage(
                                      image,
                                    );
                                    if (!ok) {
                                      pickedImage.value = null;
                                    }
                                  },
                                ),
                              );
                            },
                            child: Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ProfileField(
                    label: 'Full Name (as per PAN)',
                    controller: fullNameController,
                    enabled: canEdit,
                  ),
                  const SizedBox(height: 16),
                  ProfileField(
                    label: 'Mobile Number',
                    controller: mobileController,
                    enabled: false,
                    // trailingText: 'Change',
                    // onTrailingTap: () {
                    //   KDialog.instance.openSheet(
                    //     dialog: _MobileUpdateSheet(
                    //       currentMobile: mobileController.text.trim(),
                    //     ),
                    //   );
                    // },
                  ),
                  const SizedBox(height: 16),
                  ProfileField(
                    label: 'Email ID',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: canEdit && !latestProfile.isEmailVerified,
                    trailingText:
                        latestProfile.isEmailVerified ? 'VERIFIED' : 'VERIFY',
                    onTrailingTap: latestProfile.isEmailVerified || !canEdit
                        ? null
                        : () {
                            KDialog.instance.openSheet(
                              dialog: _EmailUpdateSheet(
                                currentEmail: emailController.text.trim(),
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: 16),
                  ProfileField(
                    label: 'Aadhaar Number',
                    controller: aadhaarController,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  ProfileField(
                    label: 'PAN Number',
                    controller: panController,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  ProfileField(
                    label: 'Permanent address',
                    controller: permanentAddressController,
                    maxLines: 2,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  ProfileField(
                    label: 'Communication Address',
                    controller: addressController,
                    maxLines: 2,
                    enabled: true,
                  ),
                  const SizedBox(height: 16),
                  ProfileField(
                    label: 'Date of Birth',
                    controller: dobController,
                    enabled: false,
                  ),
                  const SizedBox(height: 24),
                  CustomElevatedButton(
                    onPressed: state.isUpdating || !canSave
                        ? null
                        : () async {
                            final name = fullNameController.text.trim();
                            if (name.isEmpty) {
                              AppSnackbar.show('Please enter your full name.');
                              return;
                            }
                            final address = addressController.text.trim();
                            final email = state.profile?.email ??
                                profile.email ??
                                emailController.text.trim();
                            final ok = await controller.updateProfile(
                              name: name,
                              email: email,
                              address: address,
                            );
                            if (!context.mounted) return;
                            if (ok) {
                              await controller.fetchProfile();
                              if (!context.mounted) return;
                              AppSnackbar.show('Profile updated successfully.');
                              Navigator.of(context).pop();
                            } else {
                              AppSnackbar.show(
                                state.updateErrorMessage ??
                                    'Failed to update profile.',
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }
                          },
                    label: state.isUpdating ? 'Saving...' : 'Save & Update',
                    uppercaseLabel: false,
                    showArrow: false,
                  ),
                ],
              ),
            ),
            if (state.isUpdating) const _UpdateProfileLoading(),
          ],
        ),
      ),
    );
  }
}

class _UpdateProfileLoading extends StatefulWidget {
  const _UpdateProfileLoading();

  @override
  State<_UpdateProfileLoading> createState() => _UpdateProfileLoadingState();
}

class _UpdateProfileLoadingState extends State<_UpdateProfileLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Container(
        color: Colors.white.withOpacity(0.75),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final value = _controller.value * 3 - 1;
              return ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    colors: [
                      AppColors.lightBorder.withOpacity(0.2),
                      AppColors.lightBorder.withOpacity(0.6),
                      AppColors.lightBorder.withOpacity(0.2),
                    ],
                    stops: const [0.25, 0.5, 0.75],
                    begin: const Alignment(-1, -0.3),
                    end: const Alignment(1, 0.3),
                    transform: _SlidingGradientTransform(value),
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Updating profile',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

// class _MobileUpdateSheet extends HookConsumerWidget {
//   const _MobileUpdateSheet({required this.currentMobile});

//   final String currentMobile;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final mobileController =
//         useTextEditingController(text: currentMobile.trim());
//     final isSending = useState(false);
//     final otpSent = useState(false);
//     final otpErrorText = useState<String?>(null);
//     final isVerifying = useState(false);
//     final pinController = useTextEditingController();
//     final pinFocusNode = useFocusNode();

//     useEffect(() {
//       return null;
//     }, const []);

//     Future<void> sendOtp() async {
//       final mobile = mobileController.text.trim();
//       if (mobile.length != 10) {
//         AppSnackbar.show('Please enter a valid 10-digit mobile number.');
//         return;
//       }
//       isSending.value = true;
//       final ok =
//           await ref.read(profileControllerProvider.notifier).updateMobile(
//                 mobile,
//               );
//       isSending.value = false;
//       if (!context.mounted) return;
//       if (ok) {
//         otpSent.value = true;
//         pinController.clear();
//         otpErrorText.value = null;
//         pinFocusNode.requestFocus();
//         AppSnackbar.show('OTP sent successfully');
//       } else {
//         final error = ref.read(profileControllerProvider).updateErrorMessage ??
//             'Failed to send OTP. Please try again.';
//         AppSnackbar.show(
//           error,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//         );
//       }
//     }

//     Future<void> verifyOtp() async {
//       final otp = pinController.text.trim();
//       if (otp.length < 6) {
//         otpErrorText.value = 'Please enter the 6-digit OTP.';
//         return;
//       }
//       otpErrorText.value = null;
//       isVerifying.value = true;
//       final ok = await ref
//           .read(profileControllerProvider.notifier)
//           .verifyMobileOtp(otp);
//       isVerifying.value = false;
//       if (!context.mounted) return;
//       if (ok) {
//         await ref.read(profileControllerProvider.notifier).fetchProfile();
//         if (!context.mounted) return;
//         Navigator.of(context).pop();
//         AppSnackbar.show('Mobile number updated successfully.');
//       } else {
//         final profileState = ref.read(profileControllerProvider);
//         otpErrorText.value = profileState.updateErrorMessage ??
//             'OTP verification failed. Please try again.';
//       }
//     }

//     return Padding(
//       padding: MediaQuery.of(context).viewInsets +
//           const EdgeInsets.fromLTRB(20, 20, 20, 24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Change Mobile Number',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.textPrimary,
//                 ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Current number: $currentMobile',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: AppColors.textPrimary.withOpacity(0.7),
//                 ),
//           ),
//           const SizedBox(height: 12),
//           Text('Add New Mobile Number',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: AppColors.textPrimary,
//                   )),
//           const SizedBox(
//             height: 2,
//           ),
//           CustomTextField(
//             enabled: true,
//             textEditingController: mobileController,
//             keyboardType: TextInputType.phone,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(10),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (!otpSent.value)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isSending.value ? null : sendOtp,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   elevation: 0,
//                 ),
//                 child: isSending.value
//                     ? const SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation(Colors.white),
//                         ),
//                       )
//                     : const Text(
//                         'Send OTP',
//                         style: TextStyle(fontWeight: FontWeight.w700),
//                       ),
//               ),
//             ),
//           if (otpSent.value) ...[
//             const SizedBox(height: 20),
//             Text(
//               'Enter OTP',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//             ),
//             const SizedBox(height: 10),
//             Center(
//               child: Pinput(
//                 length: 6,
//                 controller: pinController,
//                 focusNode: pinFocusNode,
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 onChanged: (_) => otpErrorText.value = null,
//                 defaultPinTheme: PinTheme(
//                   width: 42.w,
//                   height: 46.h,
//                   textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.textPrimary,
//                       ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.r),
//                     border:
//                         Border.all(color: const Color(0xFFD9D9D9), width: 1.4),
//                   ),
//                 ),
//                 focusedPinTheme: PinTheme(
//                   width: 42.w,
//                   height: 46.h,
//                   textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.textPrimary,
//                       ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.r),
//                     border: Border.all(color: AppColors.primary, width: 1.6),
//                   ),
//                 ),
//                 errorPinTheme: PinTheme(
//                   width: 42.w,
//                   height: 46.h,
//                   textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.textPrimary,
//                       ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.r),
//                     border: Border.all(color: Colors.red, width: 1.6),
//                   ),
//                 ),
//                 errorTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Colors.red.shade700,
//                       fontWeight: FontWeight.w600,
//                     ),
//                 errorText: otpErrorText.value,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 TextButton(
//                   onPressed: isSending.value ? null : sendOtp,
//                   child: const Text(
//                     'Resend OTP',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 const Spacer(),
//                 CustomElevatedButton(
//                   onPressed: isVerifying.value ? null : verifyOtp,
//                   label: isVerifying.value ? 'Saving...' : 'Update',
//                   showArrow: false,
//                   width: 140,
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

class _EmailUpdateSheet extends HookConsumerWidget {
  const _EmailUpdateSheet({required this.currentEmail});

  final String currentEmail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController(text: currentEmail.trim());
    final isSending = useState(false);
    final otpSent = useState(false);
    final otpErrorText = useState<String?>(null);
    final isVerifying = useState(false);
    final pinController = useTextEditingController();
    final pinFocusNode = useFocusNode();

    Future<void> sendOtp() async {
      final email = emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        AppSnackbar.show('Please enter a valid email address.');
        return;
      }
      isSending.value = true;
      final ok = await ref.read(profileControllerProvider.notifier).updateEmail(
            email,
          );
      isSending.value = false;
      if (!context.mounted) return;
      if (ok) {
        otpSent.value = true;
        pinController.clear();
        otpErrorText.value = null;
        pinFocusNode.requestFocus();
        AppSnackbar.show('OTP sent successfully');
      } else {
        final error = ref.read(profileControllerProvider).updateErrorMessage ??
            'Failed to send OTP. Please try again.';
        AppSnackbar.show(
          error,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }

    Future<void> verifyOtp() async {
      final otp = pinController.text.trim();
      if (otp.length < 6) {
        otpErrorText.value = 'Please enter the 6-digit OTP.';
        return;
      }
      otpErrorText.value = null;
      isVerifying.value = true;
      final ok = await ref
          .read(profileControllerProvider.notifier)
          .verifyEmailOtp(otp);
      isVerifying.value = false;
      if (!context.mounted) return;
      if (ok) {
        await ref.read(profileControllerProvider.notifier).fetchProfile();
        if (!context.mounted) return;
        Navigator.of(context).pop();
        AppSnackbar.show('Email updated successfully.');
      } else {
        final profileState = ref.read(profileControllerProvider);
        otpErrorText.value = profileState.updateErrorMessage ??
            'OTP verification failed. Please try again.';
      }
    }

    return Padding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Email',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Current email: $currentEmail',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            labelText: 'New Email',
            enabled: true,
            textEditingController: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          if (!otpSent.value)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSending.value ? null : sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: isSending.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send OTP',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          if (otpSent.value) ...[
            const SizedBox(height: 20),
            Text(
              'Enter OTP',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Pinput(
                length: 6,
                controller: pinController,
                focusNode: pinFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => otpErrorText.value = null,
                defaultPinTheme: PinTheme(
                  width: 42.w,
                  height: 46.h,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border:
                        Border.all(color: const Color(0xFFD9D9D9), width: 1.4),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 42.w,
                  height: 46.h,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.primary, width: 1.6),
                  ),
                ),
                errorPinTheme: PinTheme(
                  width: 42.w,
                  height: 46.h,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.red, width: 1.6),
                  ),
                ),
                errorTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                errorText: otpErrorText.value,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: isSending.value ? null : sendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                CustomElevatedButton(
                  onPressed: isVerifying.value ? null : verifyOtp,
                  label: isVerifying.value ? 'Saving...' : 'Update',
                  showArrow: false,
                  width: 140,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
