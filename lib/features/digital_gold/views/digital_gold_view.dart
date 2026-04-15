import 'dart:async';

import 'package:e_rupaiya/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/routes_constant.dart';
import '../../../widgets/k_dialog.dart';
import '../components/gold_balance_card.dart';
import '../components/gold_buy_card.dart';
import '../components/gold_header.dart';
import '../components/gold_payment_summary_sheet.dart';
import '../components/gold_proceed_button.dart';
import '../components/gold_provider_section.dart';
import '../models/digital_gold_preview.dart';
import '../models/digital_metal.dart';
import '../models/quick_amount_option.dart';
import '../repo/digital_gold_repo.dart';

class DigitalGoldView extends HookConsumerWidget {
  const DigitalGoldView({
    super.key,
    this.mode = GoldTradeMode.buy,
    this.metal = DigitalMetal.gold,
  });

  final GoldTradeMode mode;
  final DigitalMetal metal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSell = mode == GoldTradeMode.sell;
    final theme = DigitalMetalTheme.of(metal);
    final isBuyingInRupees = useState<bool>(true);
    final amountController =
        useTextEditingController(text: isSell ? '2000' : '500');
    useListenable(amountController);
    final quickAmounts = isSell
        ? const [
            QuickAmountOption(label: '10%', value: 10),
            QuickAmountOption(label: '25%', value: 25),
            QuickAmountOption(label: '50%', value: 50),
            QuickAmountOption(label: '100%', value: 100),
          ]
        : isBuyingInRupees.value
            ? const [
                QuickAmountOption(label: '₹500', value: 500),
                QuickAmountOption(label: '₹1000', value: 1000),
                QuickAmountOption(label: '₹5000', value: 5000),
                QuickAmountOption(label: '₹10000', value: 10000),
              ]
            : const [
                QuickAmountOption(label: '0.5g', value: 1),
                QuickAmountOption(label: '1.0g', value: 2),
                QuickAmountOption(label: '1.5g', value: 3),
                QuickAmountOption(label: '2.0g', value: 4),
              ];

    final repository = ref.read(digitalGoldRepoProvider);
    final preview = useState<DigitalGoldPreview?>(null);
    final error = useState<String?>(null);
    final pollTimer = useRef<Timer?>(null);
    final inFlight = useRef<bool>(false);

    String formatAmount(String text) {
      final parsed = double.tryParse(text) ?? 0.0;
      return parsed.toStringAsFixed(2);
    }

    String calculationType() => isBuyingInRupees.value ? 'A' : 'Q';
    String metalType() => metal == DigitalMetal.gold ? 'G' : 'S';
    String quantityValue(String amountText) {
      if (isBuyingInRupees.value) return '1';
      return formatAmount(amountText);
    }

    Future<void> fetchPreview({bool silent = true}) async {
      if (inFlight.value) return;
      final amountText = amountController.text.trim();
      if (amountText.isEmpty) return;
      inFlight.value = true;
      // no-op
      try {
        final response = await repository.fetchProceedPreview(
          calculationType: calculationType(),
          amount: formatAmount(amountText),
          quantity: quantityValue(amountText),
          metalType: metalType(),
        );
        if (preview.value != response) {
          preview.value = response;
        }
        if (error.value != null) error.value = null;
      } catch (e) {
        final message = e.toString().toLowerCase();
        if (!silent) {
          error.value = e.toString();
        }
      } finally {
        // no-op
        inFlight.value = false;
      }
    }

    useEffect(() {
      fetchPreview(silent: false);
      pollTimer.value?.cancel();
      pollTimer.value = Timer.periodic(
        const Duration(seconds: 5),
        (_) => fetchPreview(),
      );
      return () => pollTimer.value?.cancel();
    }, [isBuyingInRupees.value, metal, amountController.text]);

    final priceValue = preview.value?.totalAmount ?? 0.0;
    final balanceValue = preview.value?.myGoldBalance ?? 0.0;
    final inputAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
    final gramConversion = priceValue > 0 ? (inputAmount / priceValue) : 0.0;
    final rupeeConversion = priceValue > 0 ? (inputAmount * priceValue) : 0.0;
    final trailingText = isBuyingInRupees.value
        ? '=${gramConversion.isNaN ? 0 : gramConversion.toStringAsFixed(4)}g'
        : '=₹${rupeeConversion.isNaN ? 0 : rupeeConversion.toStringAsFixed(2)}';
    final prefixText = isBuyingInRupees.value ? '₹' : '';

    return Scaffold(
      backgroundColor: theme.pageBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: theme.buyGradient,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  GoldHeader(
                    title: isSell ? theme.sellTitle : theme.buyTitle,
                    onBack: () => context.pop(),
                    onHelp: () {},
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.push(
                              '${RouteConstants.digitalGoldLocker}?metal=${theme.queryValue}',
                            ),
                            child: GoldBalanceCard(
                              balance: '₹${balanceValue.toStringAsFixed(0)}',
                              // changeText: '↑ ₹50(10%)',
                              changeText: '',
                              backgroundColor: theme.balanceCardColor,
                              label: theme.balanceLabel,
                              borderColor: metal == DigitalMetal.silver
                                  ? Colors.white
                                  : const Color(0xffFFBF2B),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          GoldProviderSection(
                            title: isSell
                                ? 'Selling To MMTC-PAMP'
                                : 'Buying From MMTC-PAMP',
                            subtitle: theme.providerSubtitle,
                            showChevron: isSell,
                          ),
                          SizedBox(height: 16.h),
                          GoldBuyCard(
                            isBuyingInRupees: isBuyingInRupees.value,
                            onUnitChanged: (value) {
                              isBuyingInRupees.value = value;
                              if (value) {
                                amountController.text = '500';
                              } else {
                                amountController.text = '0.5';
                              }
                            },
                            amountController: amountController,
                            quickAmounts: quickAmounts,
                            onAmountSelected: (value) {
                              if (isSell) {
                                amountController.text = value.toString();
                                return;
                              }
                              if (isBuyingInRupees.value) {
                                amountController.text = value.toString();
                              } else {
                                final grams = value * 0.5;
                                amountController.text =
                                    grams.toStringAsFixed(1);
                              }
                            },
                            leftToggleLabel:
                                isSell ? 'Sell In Rupees' : 'Buy In Rupees',
                            rightToggleLabel:
                                isSell ? 'Sell In Grams' : 'Buy In Grams',
                            priceText: isSell
                                ? 'Selling Price: ₹${priceValue.toStringAsFixed(2)}/G + 3% GST'
                                : 'Buy Price: ₹${priceValue.toStringAsFixed(2)}/G + 3% GST',
                            trailingText: trailingText,
                            cardColor: Colors.white,
                            chipGradient: theme.quickChipGradient,
                            toggleActiveColor: theme.toggleActiveColor,
                            prefixText: prefixText,
                          ),
                          if (error.value != null) ...[
                            SizedBox(height: 10.h),
                            Text(
                              error.value!.replaceFirst('Exception: ', ''),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                      child: GoldProceedButton(
                        label: isSell ? 'Sell Now' : 'Proceed',
                        onPressed: () async {
                          await fetchPreview(silent: false);
                          final lastError = error.value?.toLowerCase() ?? '';
                          if (lastError.contains('kyc not completed')) {
                            AppSnackbar.show(
                              'Please complete kyc first',
                              type: AppSnackbarType.error,
                            );
                            context.push(RouteConstants.kycVerification);
                            return;
                          }
                          final data = preview.value;
                          if (data == null) return;
                          if (!data.kycStatus) {
                            AppSnackbar.show(
                              'Please complete kyc first',
                              type: AppSnackbarType.error,
                            );
                            context.push(RouteConstants.kycVerification);
                            return;
                          }

                          if (data.isUserRegistered) {
                            KDialog.instance.openSheet(
                              dialog: GoldPaymentSummarySheet(
                                amount: data.totalAmount,
                                preview: data,
                                metal: metal,
                                onBuyNow: () {
                                  context.push(
                                    '${RouteConstants.digitalGoldSuccess}?metal=${theme.queryValue}',
                                  );
                                },
                              ),
                            );
                            return;
                          }
                          final parsed =
                              int.tryParse(amountController.text.trim()) ?? 0;
                          context.push(
                            '${RouteConstants.digitalGoldDetails}?metal=${theme.queryValue}',
                            extra: {
                              'amount': parsed,
                              'preview': data,
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
