import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/my_app_bar.dart';
import '../../profile/controllers/profile_controller.dart';
import '../components/gold_confirm_details_card.dart';
import '../components/gold_details_section_title.dart';
import '../components/gold_form_field.dart';
import '../components/gold_payment_summary_sheet.dart';
import '../models/digital_gold_preview.dart';
import '../models/digital_metal.dart';
import '../repo/digital_gold_repo.dart';

class DigitalGoldDetailsView extends HookConsumerWidget {
  const DigitalGoldDetailsView({
    super.key,
    required this.amount,
    this.metal = DigitalMetal.gold,
    this.preview,
    this.redirectToGoldOnSuccess = false,
  });

  final int amount;
  final DigitalMetal metal;
  final DigitalGoldPreview? preview;
  final bool redirectToGoldOnSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final nameController =
        useTextEditingController(text: profileState.profile?.name ?? '');
    final mobileController =
        useTextEditingController(text: profileState.profile?.mobile ?? '');
    final emailController =
        useTextEditingController(text: profileState.profile?.email ?? '');
    final panController =
        useTextEditingController(text: profileState.profile?.panNo ?? '');
    useListenable(nameController);
    useListenable(mobileController);
    useListenable(emailController);
    useListenable(panController);

    final billingAddress1 = useTextEditingController();
    final billingAddress2 = useTextEditingController();
    final billingCity = useTextEditingController();
    final billingState = useTextEditingController();
    final billingStateCode = useTextEditingController();
    final billingZip = useTextEditingController();
    final billingCountry = useTextEditingController();
    final billingMobile = useTextEditingController();

    final deliveryAddress1 = useTextEditingController();
    final deliveryAddress2 = useTextEditingController();
    final deliveryCity = useTextEditingController();
    final deliveryState = useTextEditingController();
    final deliveryStateCode = useTextEditingController();
    final deliveryZip = useTextEditingController();
    final deliveryCountry = useTextEditingController();
    final deliveryMobile = useTextEditingController();

    useEffect(() {
      final profile = profileState.profile;
      if (profile == null) return null;
      nameController.text = profile.name;
      mobileController.text = profile.mobile;
      emailController.text = profile.email ?? '';
      panController.text = profile.panNo ?? '';

      final billing = profile.billingAddress;
      if (billing != null) {
        billingAddress1.text = billing.addressLine1;
        billingAddress2.text = billing.addressLine2;
        billingCity.text = billing.city;
        billingState.text = billing.state;
        billingStateCode.text = billing.stateCode;
        billingZip.text = billing.pincode;
        billingCountry.text = billing.country;
        billingMobile.text = billing.billingMobile.isNotEmpty
            ? billing.billingMobile
            : profile.mobile;

        deliveryAddress1.text = billing.addressLine1;
        deliveryAddress2.text = billing.addressLine2;
        deliveryCity.text = billing.city;
        deliveryState.text = billing.state;
        deliveryStateCode.text = billing.stateCode;
        deliveryZip.text = billing.pincode;
        deliveryCountry.text = billing.country;
        deliveryMobile.text = billing.billingMobile.isNotEmpty
            ? billing.billingMobile
            : profile.mobile;
      } else {
        billingMobile.text = profile.mobile;
        deliveryMobile.text = profile.mobile;
      }
      return null;
    }, [profileState.profile]);

    final repository = ref.read(digitalGoldRepoProvider);
    final isSubmitting = useState<bool>(false);

    final theme = DigitalMetalTheme.of(metal);
    return Scaffold(
      backgroundColor: theme.designTopTint,
      body: Column(
        children: [
          MyAppBar(
            title: '${theme.label} Buy And Sell',
            onBack: () => context.pop(),
            showHelp: false,
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.help_outline, color: Colors.white),
            ),
            backgroundColor: theme.designTopTint,
            height: 90.h,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24.r),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GoldDetailsSectionTitle(
                      title: 'Confirm Your Details',
                      trailingIcon: Icons.close,
                      onTrailingTap: () {},
                    ),
                    SizedBox(height: 8.h),
                    GoldConfirmDetailsCard(
                      name: nameController.text,
                      mobile: mobileController.text,
                      email: emailController.text,
                      pan: panController.text,
                    ),
                    SizedBox(height: 16.h),
                    const GoldDetailsSectionTitle(title: 'Enter Other Details'),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Billing Address Line1',
                      controller: billingAddress1,
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Billing Address Line2',
                      controller: billingAddress2,
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Billing City',
                      controller: billingCity,
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Billing State',
                      controller: billingState,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: GoldFormField(
                            label: 'Billing Statecode',
                            controller: billingStateCode,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: GoldFormField(
                            label: 'Billing Zip',
                            controller: billingZip,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Billing Country',
                      controller: billingCountry,
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Billing Mobile',
                      controller: billingMobile,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),
                    const GoldDetailsSectionTitle(title: 'Delivery Address'),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Delivery Address Line1',
                      controller: deliveryAddress1,
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Delivery Address Line2',
                      controller: deliveryAddress2,
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Delivery City',
                      controller: deliveryCity,
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Delivery State',
                      controller: deliveryState,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: GoldFormField(
                            label: 'Delivery Statecode',
                            controller: deliveryStateCode,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: GoldFormField(
                            label: 'Delivery Zip',
                            controller: deliveryZip,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Delivery Country',
                      controller: deliveryCountry,
                    ),
                    SizedBox(height: 10.h),
                    GoldFormField(
                      label: 'Delivery Mobile',
                      controller: deliveryMobile,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 16.h),
            child: CustomElevatedButton(
              onPressed: () async {
                if (isSubmitting.value) return;
                isSubmitting.value = true;
                try {
                  await repository.createCustomer(
                    mobile: mobileController.text.trim(),
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    panNumber: panController.text.trim(),
                    billingAddressLine1: billingAddress1.text.trim(),
                    billingAddressLine2: billingAddress2.text.trim(),
                    billingCity: billingCity.text.trim(),
                    billingState: billingState.text.trim(),
                    billingStateCode: billingStateCode.text.trim(),
                    billingZip: billingZip.text.trim(),
                    billingCountry: billingCountry.text.trim(),
                    billingMobile: billingMobile.text.trim(),
                    deliveryAddressLine1: deliveryAddress1.text.trim(),
                    deliveryAddressLine2: deliveryAddress2.text.trim(),
                    deliveryCity: deliveryCity.text.trim(),
                    deliveryState: deliveryState.text.trim(),
                    deliveryStateCode: deliveryStateCode.text.trim(),
                    deliveryZip: deliveryZip.text.trim(),
                    deliveryCountry: deliveryCountry.text.trim(),
                    deliveryMobile: deliveryMobile.text.trim(),
                  );
                  if (!context.mounted) return;
                  if (redirectToGoldOnSuccess || amount <= 0) {
                    context.go(
                      '${RouteConstants.digitalGold}?metal=${theme.queryValue}',
                    );
                    return;
                  }

                  KDialog.instance.openSheet(
                    dialog: GoldPaymentSummarySheet(
                      amount: amount.toDouble(),
                      preview: preview ??
                          const DigitalGoldPreview(
                            kycStatus: true,
                            isUserRegistered: true,
                            myGoldBalance: 0,
                            taxAmt1: 0,
                            taxAmt2: 0,
                            preTaxAmount: 0,
                            totalAmount: 0,
                          ),
                      metal: metal,
                      onBuyNow: () {
                        context.push(
                          '${RouteConstants.digitalGoldSuccess}?metal=${theme.queryValue}',
                        );
                      },
                    ),
                  );
                } catch (e) {
                  AppSnackbar.show(
                    e.toString().replaceFirst('Exception: ', ''),
                    type: AppSnackbarType.error,
                  );
                } finally {
                  isSubmitting.value = false;
                }
              },
              label: 'Confirm Details',
              uppercaseLabel: false,
              height: 42.h,
            ),
          ),
        ),
      ),
    );
  }
}
