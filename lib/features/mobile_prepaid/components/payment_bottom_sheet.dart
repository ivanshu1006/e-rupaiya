// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../constants/routes_constant.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/payment_success_flow.dart';
import '../../paymentgateway/razorpay_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../services/controllers/biller_detail_controller.dart';
import '../../services/models/bill_pay_response_model.dart';
import '../controllers/mobile_prepaid_controller.dart';

enum _PaymentOutcome {
  success,
  pending,
  failure,
  insufficient,
}

_PaymentOutcome _resolvePaymentOutcome(
  BillPayResponse? response,
  String? errorMessage,
) {
  final status = response?.status.toUpperCase() ?? '';
  final message = (response?.message ?? errorMessage ?? '').toLowerCase();
  if (message.contains('insufficient')) {
    return _PaymentOutcome.insufficient;
  }
  if (status.contains('PENDING')) {
    return _PaymentOutcome.pending;
  }
  if (response?.isSuccess == true) {
    return _PaymentOutcome.success;
  }
  return _PaymentOutcome.failure;
}

String _paymentTitle(_PaymentOutcome outcome) {
  switch (outcome) {
    case _PaymentOutcome.success:
      return 'Thank You!';
    case _PaymentOutcome.pending:
      return 'Payment Pending!';
    case _PaymentOutcome.failure:
      return 'Payment Failed!';
    case _PaymentOutcome.insufficient:
      return 'Insufficient Balance!';
  }
}

String _paymentSubtitle(_PaymentOutcome outcome) {
  switch (outcome) {
    case _PaymentOutcome.success:
      return 'Thank you for your payment.\n'
          'Your transaction has been successfully completed.\n'
          'We truly appreciate your prompt payment and trust in our services.';
    case _PaymentOutcome.pending:
      return 'Your payment has been received but is currently being processed.\n'
          "Please wait a few moments - we'll notify you once the transaction is confirmed.";
    case _PaymentOutcome.failure:
      return 'Unfortunately, your transaction could not be completed.'
          'Please check your payment details or try again later.'
          'If the amount has been deducted, it will be refunded automatically within a few business days.';
    case _PaymentOutcome.insufficient:
      return 'You do not have enough balance to complete this payment.';
  }
}

String _resultSubtitle(_PaymentOutcome outcome) {
  switch (outcome) {
    case _PaymentOutcome.success:
      return 'Your payment has been processed successfully.';
    default:
      return _paymentSubtitle(outcome);
  }
}

IconData _paymentStatusIcon(_PaymentOutcome outcome) {
  switch (outcome) {
    case _PaymentOutcome.success:
      return Icons.check;
    case _PaymentOutcome.pending:
      return Icons.hourglass_bottom;
    case _PaymentOutcome.failure:
      return Icons.close;
    case _PaymentOutcome.insufficient:
      return Icons.error_outline;
  }
}

Color _paymentStatusColor(_PaymentOutcome outcome) {
  switch (outcome) {
    case _PaymentOutcome.success:
      return Colors.white;
    case _PaymentOutcome.pending:
      return Colors.amber;
    case _PaymentOutcome.failure:
      return Colors.red;
    case _PaymentOutcome.insufficient:
      return Colors.red;
  }
}

List<Color> _paymentHeaderGradient(_PaymentOutcome outcome) {
  switch (outcome) {
    case _PaymentOutcome.success:
      return const [Color(0xFF0D5C32), Color(0xFF0E7340)];
    case _PaymentOutcome.pending:
      return const [Color(0xFFF59E0B), Color(0xFFD97706)];
    case _PaymentOutcome.failure:
    case _PaymentOutcome.insufficient:
      return const [Color(0xFFB91C1C), Color(0xFFDC2626)];
  }
}

void _openPaymentResultFlow(
  BuildContext context, {
  required _PaymentOutcome outcome,
  required double amount,
  required String billerName,
  required String txId,
}) {
  void goHome(BuildContext localContext) {
    // Refresh wallet balance when returning home after any payment
    try {
      ProviderScope.containerOf(localContext)
          .read(profileControllerProvider.notifier)
          .fetchProfile();
    } catch (_) {}
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!localContext.mounted) return;
      navigatorKey.currentContext?.go(RouteConstants.home);
    });
  }

  final details = [
    PaymentDetailItem(
      label: 'Amount',
      value: '\u20B9 ${amount.toStringAsFixed(2)}',
    ),
    PaymentDetailItem(
      label: 'To',
      value: billerName,
    ),
    if (txId.isNotEmpty)
      PaymentDetailItem(
        label: 'Transaction ID',
        value: '#$txId',
        copyable: true,
      ),
  ];
  final isFailure = outcome == _PaymentOutcome.failure ||
      outcome == _PaymentOutcome.insufficient;
  void Function(BuildContext) onContinue = isFailure
      ? (screenContext) {
          Navigator.of(screenContext).pop();
        }
      : goHome;

  if (outcome == _PaymentOutcome.success) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentThankYouScreen(
          title: _paymentTitle(outcome),
          subtitle: _paymentSubtitle(outcome),
          playSound: true,
          autoNavigateAfter: const Duration(seconds: 2),
          onAutoNavigate: (screenContext) {
            Navigator.of(screenContext).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PaymentResultScreen(
                  title: _paymentTitle(outcome),
                  subtitle: _resultSubtitle(outcome),
                  details: details,
                  statusIcon: _paymentStatusIcon(outcome),
                  statusIconColor: _paymentStatusColor(outcome),
                  statusIconBorderColor: _paymentStatusColor(outcome),
                  headerGradientColors: _paymentHeaderGradient(outcome),
                  headerImageAsset: outcome == _PaymentOutcome.failure ||
                          outcome == _PaymentOutcome.insufficient
                      ? FileConstants.errorBanner
                      : '',
                  emphasizeSubtitle: outcome == _PaymentOutcome.failure ||
                      outcome == _PaymentOutcome.insufficient,
                  showFailureActions: isFailure,
                  continueText:
                      isFailure ? 'Retry Payment' : 'Continue to Home',
                  playSound: outcome == _PaymentOutcome.success,
                  onContinue: onContinue,
                ),
              ),
            );
          },
        ),
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentResultScreen(
          title: _paymentTitle(outcome),
          subtitle: _resultSubtitle(outcome),
          details: details,
          statusIcon: _paymentStatusIcon(outcome),
          statusIconColor: _paymentStatusColor(outcome),
          statusIconBorderColor: _paymentStatusColor(outcome),
          headerGradientColors: _paymentHeaderGradient(outcome),
          headerImageAsset: outcome == _PaymentOutcome.failure ||
                  outcome == _PaymentOutcome.insufficient
              ? FileConstants.errorBanner
              : '',
          emphasizeSubtitle: outcome == _PaymentOutcome.failure ||
              outcome == _PaymentOutcome.insufficient,
          showFailureActions: isFailure,
          continueText: isFailure ? 'Retry Payment' : 'Continue to Home',
          playSound: false,
          onContinue: onContinue,
        ),
      ),
    );
  }
}

class PaymentBottomSheet extends ConsumerStatefulWidget {
  const PaymentBottomSheet({
    super.key,
    required this.amount,
    this.isCreditCardFlow = false,
    this.paymentTypeOverride,
  });

  final double amount;
  final bool isCreditCardFlow;
  final String? paymentTypeOverride;

  @override
  ConsumerState<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends ConsumerState<PaymentBottomSheet> {
  bool _useECoins = false;

  double _availableECoins() {
    final balance =
        ref.watch(profileControllerProvider).profile?.walletBalance ?? 0;
    return balance.toDouble();
  }

  double _eCoinsApplied(double available) {
    if (!_useECoins) return 0.0;
    return available >= widget.amount ? widget.amount : available;
  }

  double _remainingAmount(double applied) {
    final remaining = widget.amount - applied;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> _startRazorpay({
    required double amount,
    required String billerName,
  }) async {
    await RazorpayService.instance.openCheckout(
      amount: amount,
      name: billerName,
      description: 'Bill payment',
      onSuccess: (paymentId) {
        _completeBillPaymentWithRazorpay(
          paymentId: paymentId,
          amount: amount,
          billerName: billerName,
        );
      },
      onFailure: (message) {
        if (!mounted) return;
        AppSnackbar.show(
          message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        _openPaymentResultFlow(
          context,
          outcome: _PaymentOutcome.failure,
          amount: amount,
          billerName: billerName,
          txId: '',
        );
      },
    );
  }

  Future<void> _completeBillPaymentWithRazorpay({
    required String paymentId,
    required double amount,
    required String billerName,
  }) async {
    if (paymentId.isEmpty) {
      AppSnackbar.show(
        'Somehing went wrong with the payment. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      _openPaymentResultFlow(
        context,
        outcome: _PaymentOutcome.failure,
        amount: amount,
        billerName: billerName,
        txId: '',
      );
      return;
    }

    final controller = ref.read(billerDetailControllerProvider.notifier);
    final ok = await controller.payBill(
      amount: amount,
      refIdOverride: paymentId,
      isCreditCardFlow: widget.isCreditCardFlow,
      paymentTypeOverride: widget.paymentTypeOverride,
    );
    if (!mounted) return;
    final latestState = ref.read(billerDetailControllerProvider);
    final outcome = _resolvePaymentOutcome(
      latestState.payResponse,
      latestState.payErrorMessage,
    );
    _openPaymentResultFlow(
      context,
      outcome: outcome,
      amount: amount,
      billerName: billerName,
      txId: paymentId,
    );
    if (!ok && latestState.payResponse == null) {
      AppSnackbar.show(
        latestState.payErrorMessage ?? 'Payment failed. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(billerDetailControllerProvider);
    final controller = ref.read(billerDetailControllerProvider.notifier);
    final isPaying = detailState.isPayingBill;
    final availableECoins = _availableECoins();
    final canUseECoins = availableECoins > 0;
    final eCoinsApplied = _eCoinsApplied(availableECoins);
    final remainingAmount = _remainingAmount(eCoinsApplied);
    final buttonLabel = remainingAmount == 0 ? 'Pay Now' : 'Proceed';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Payment Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                '\u20B9 ${widget.amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Orange progress bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // E-Coins option
          _PaymentOptionTile(
            icon: Icons.monetization_on_outlined,
            iconColor: AppColors.primary,
            title: 'E-Coins (${availableECoins.toStringAsFixed(0)})',
            subtitle: _useECoins
                ? 'Using \u20B9${eCoinsApplied.toStringAsFixed(0)}'
                : 'Use E-Coins for payment',
            enabled: canUseECoins,
            trailing: Checkbox(
              value: _useECoins,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: canUseECoins
                  ? (v) => setState(() => _useECoins = v ?? false)
                  : null,
            ),
            onTap: canUseECoins
                ? () => setState(() => _useECoins = !_useECoins)
                : null,
          ),

          const SizedBox(height: 20),
          const SizedBox(height: 16),

          // Bottom bar: amount + PAY NOW
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    '\u20B9 ${remainingAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  CustomElevatedButton(
                    onPressed: isPaying
                        ? null
                        : () async {
                            if (_useECoins && remainingAmount == 0) {
                              final ok = await controller.payBill(
                                amount: widget.amount,
                                isCreditCardFlow: widget.isCreditCardFlow,
                                paymentTypeOverride: widget.paymentTypeOverride,
                              );
                              if (!context.mounted) return;
                              final latestState =
                                  ref.read(billerDetailControllerProvider);
                              context.pop();
                              final outcome = _resolvePaymentOutcome(
                                latestState.payResponse,
                                latestState.payErrorMessage,
                              );
                              final billerName =
                                  latestState.selectedBiller?.billerName ??
                                      'Biller';
                              final txId =
                                  latestState.payResponse?.transactionId ?? '';
                              _openPaymentResultFlow(
                                context,
                                outcome: outcome,
                                amount: widget.amount,
                                billerName: billerName,
                                txId: txId,
                              );
                              if (!ok && latestState.payResponse == null) {
                                AppSnackbar.show(
                                  latestState.payErrorMessage ??
                                      'Payment failed. Please try again.',
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                              return;
                            }

                            final amountToPay =
                                _useECoins ? remainingAmount : widget.amount;
                            final billerName =
                                detailState.selectedBiller?.billerName ??
                                    'Biller';
                            await _startRazorpay(
                              amount: amountToPay,
                              billerName: billerName,
                            );
                          },
                    label: isPaying ? 'Processing' : buttonLabel,
                    showArrow: false,
                    uppercaseLabel: true,
                    width: null,
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

class PrepaidPaymentBottomSheet extends ConsumerStatefulWidget {
  const PrepaidPaymentBottomSheet({super.key, required this.amount});

  final int amount;

  @override
  ConsumerState<PrepaidPaymentBottomSheet> createState() =>
      _PrepaidPaymentBottomSheetState();
}

class _PrepaidPaymentBottomSheetState
    extends ConsumerState<PrepaidPaymentBottomSheet> {
  bool _useECoins = false;

  double _availableECoins() {
    final balance =
        ref.watch(profileControllerProvider).profile?.walletBalance ?? 0;
    return balance.toDouble();
  }

  double _eCoinsApplied(double available) {
    if (!_useECoins) return 0.0;
    return available >= widget.amount ? widget.amount.toDouble() : available;
  }

  double _remainingAmount(double applied) {
    final remaining = widget.amount - applied;
    return remaining < 0 ? 0 : remaining.toDouble();
  }

  Future<void> _startRazorpay({
    required double amount,
    required String billerName,
  }) async {
    await RazorpayService.instance.openCheckout(
      amount: amount,
      name: billerName,
      description: 'Recharge',
      onSuccess: (paymentId) async {
        if (!mounted) return;
        final controller = ref.read(mobilePrepaidControllerProvider.notifier);
        await controller.recharge(referenceId: paymentId);
        if (!mounted) return;
        final latestState = ref.read(mobilePrepaidControllerProvider);
        final outcome = latestState.errorMessage != null
            ? _resolvePaymentOutcome(null, latestState.errorMessage)
            : _PaymentOutcome.success;
        _openPaymentResultFlow(
          context,
          outcome: outcome,
          amount: amount,
          billerName: billerName,
          txId: paymentId,
        );
        final message = latestState.errorMessage?.trim().toLowerCase();
        if (latestState.errorMessage != null &&
            message != 'unable to process recharge') {
          AppSnackbar.show(
            latestState.errorMessage!,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
      onFailure: (message) {
        if (!mounted) return;
        AppSnackbar.show(
          message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        _openPaymentResultFlow(
          context,
          outcome: _PaymentOutcome.failure,
          amount: amount,
          billerName: billerName,
          txId: '',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobilePrepaidControllerProvider);
    final controller = ref.read(mobilePrepaidControllerProvider.notifier);
    final isPaying = state.isRecharging;
    final availableECoins = _availableECoins();
    final canUseECoins = availableECoins > 0;
    final eCoinsApplied = _eCoinsApplied(availableECoins);
    final remainingAmount = _remainingAmount(eCoinsApplied);
    final buttonLabel = remainingAmount == 0 ? 'Pay Now' : 'Proceed';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Payment Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                '\u20B9 ${widget.amount}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Orange progress bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // E-Coins option
          _PaymentOptionTile(
            icon: Icons.monetization_on_outlined,
            iconColor: AppColors.primary,
            title: 'E-Coins (${availableECoins.toStringAsFixed(0)})',
            subtitle: _useECoins
                ? 'Using \u20B9${eCoinsApplied.toStringAsFixed(0)}'
                : 'Use E-Coins for payment',
            enabled: canUseECoins,
            trailing: Checkbox(
              value: _useECoins,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: canUseECoins
                  ? (v) => setState(() => _useECoins = v ?? false)
                  : null,
            ),
            onTap: canUseECoins
                ? () => setState(() => _useECoins = !_useECoins)
                : null,
          ),

          const SizedBox(height: 20),
          const SizedBox(height: 16),

          // Bottom bar: amount + PAY NOW
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    '\u20B9 ${remainingAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  CustomElevatedButton(
                    onPressed: isPaying
                        ? null
                        : () async {
                            if (_useECoins && remainingAmount == 0) {
                              controller.recharge();
                              // Listen for state changes
                              ref.listenManual(
                                mobilePrepaidControllerProvider,
                                (previous, next) {
                                  if (!context.mounted) return;
                                  if (next.rechargeMessage != null &&
                                      next.rechargeMessage !=
                                          previous?.rechargeMessage) {
                                    Navigator.of(context).pop();
                                    _openPaymentResultFlow(
                                      context,
                                      outcome: _PaymentOutcome.success,
                                      amount: widget.amount.toDouble(),
                                      billerName: 'Mobile Prepaid',
                                      txId: '',
                                    );
                                  }
                                  if (next.errorMessage != null &&
                                      next.errorMessage !=
                                          previous?.errorMessage) {
                                    Navigator.of(context).pop();
                                    final outcome = _resolvePaymentOutcome(
                                      null,
                                      next.errorMessage,
                                    );
                                    _openPaymentResultFlow(
                                      context,
                                      outcome: outcome,
                                      amount: widget.amount.toDouble(),
                                      billerName: 'Mobile Prepaid',
                                      txId: '',
                                    );
                                  }
                                },
                              );
                              return;
                            }

                            final amountToPay = _useECoins
                                ? remainingAmount
                                : widget.amount.toDouble();
                            await _startRazorpay(
                              amount: amountToPay,
                              billerName: 'Mobile Prepaid',
                            );
                          },
                    label: isPaying ? 'Processing' : buttonLabel,
                    showArrow: false,
                    uppercaseLabel: true,
                    width: null,
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

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        enabled ? iconColor : AppColors.textPrimary.withOpacity(0.35);
    final titleColor = enabled
        ? AppColors.textPrimary
        : AppColors.textPrimary.withOpacity(0.45);
    final subtitleColor = enabled
        ? AppColors.textPrimary.withOpacity(0.5)
        : AppColors.textPrimary.withOpacity(0.35);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: effectiveIconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                          ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
