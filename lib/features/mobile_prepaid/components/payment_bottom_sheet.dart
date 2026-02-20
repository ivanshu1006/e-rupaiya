// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/payment_success_flow.dart';
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
      return 'Unfortunately, your transaction could not be completed.\n'
          'Please check your payment details or try again later.\n'
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
      ),
  ];

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
                  playSound: outcome == _PaymentOutcome.success,
                  onContinue: (resultContext) => resultContext.go('/'),
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
          playSound: false,
          onContinue: (resultContext) => resultContext.go('/'),
        ),
      ),
    );
  }
}

class PaymentBottomSheet extends ConsumerStatefulWidget {
  const PaymentBottomSheet({super.key, required this.amount});

  final double amount;

  @override
  ConsumerState<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends ConsumerState<PaymentBottomSheet> {
  bool _useECoins = false;
  String _selectedUpi = 'google_pay';

  double _availableECoins() {
    final balance =
        ref.watch(profileControllerProvider).profile?.walletBalance ?? 0;
    return balance.toDouble();
  }

  double _computeECoinsDiscount(double available) {
    return 0.0;
  }

  double _finalAmount(double discount) {
    return widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(billerDetailControllerProvider);
    final controller = ref.read(billerDetailControllerProvider.notifier);
    final isPaying = detailState.isPayingBill;
    final availableECoins = _availableECoins();
    final maxPossibleDiscount = _computeECoinsDiscount(availableECoins);
    final eCoinsDiscount = _useECoins ? maxPossibleDiscount : 0.0;
    final finalAmount = _finalAmount(eCoinsDiscount);
    final insufficientECoins = _useECoins && availableECoins < widget.amount;
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
            subtitle: 'Use E-Coins for recharge',
            trailing: Checkbox(
              value: _useECoins,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: availableECoins <= 0
                  ? null
                  : (v) => setState(() => _useECoins = v ?? false),
            ),
            onTap: availableECoins <= 0
                ? null
                : () => setState(() => _useECoins = !_useECoins),
          ),

          const SizedBox(height: 20),

          // UPI heading
          Text(
            'UPI',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),

          // UPI options
          _PaymentOptionTile(
            icon: Icons.g_mobiledata,
            iconColor: Colors.blue,
            title: 'Google Pay',
            trailing: Radio<String>(
              value: 'google_pay',
              groupValue: _selectedUpi,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedUpi = v!),
            ),
            onTap: () => setState(() => _selectedUpi = 'google_pay'),
          ),
          _PaymentOptionTile(
            icon: Icons.account_balance_wallet,
            iconColor: Colors.deepPurple,
            title: 'Phone Pe',
            trailing: Radio<String>(
              value: 'phonepe',
              groupValue: _selectedUpi,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedUpi = v!),
            ),
            onTap: () => setState(() => _selectedUpi = 'phonepe'),
          ),
          _PaymentOptionTile(
            icon: Icons.currency_rupee,
            iconColor: Colors.green,
            title: 'Bhim UPI',
            trailing: Radio<String>(
              value: 'bhim',
              groupValue: _selectedUpi,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedUpi = v!),
            ),
            onTap: () => setState(() => _selectedUpi = 'bhim'),
          ),
          _PaymentOptionTile(
            icon: Icons.grid_view_rounded,
            iconColor: AppColors.textPrimary,
            title: 'More UPI Options',
            trailing: Radio<String>(
              value: 'more',
              groupValue: _selectedUpi,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedUpi = v!),
            ),
            onTap: () => setState(() => _selectedUpi = 'more'),
          ),

          const SizedBox(height: 16),

          // Bottom bar: amount + PAY NOW
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    '\u20B9 ${finalAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: insufficientECoins
                        ? () {
                            AppSnackbar.show(
                              "You don't have enough E-Coins for this payment.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        : null,
                    child: CustomElevatedButton(
                      onPressed: (isPaying || insufficientECoins)
                          ? null
                          : () async {
                              final ok = await controller.payBill(
                                amount: finalAmount,
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
                                amount: finalAmount,
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
                            },
                      label: isPaying ? 'Processing' : 'Pay Now',
                      showArrow: false,
                      uppercaseLabel: true,
                      width: null,
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
  String _selectedUpi = 'google_pay';

  double _availableECoins() {
    final balance =
        ref.watch(profileControllerProvider).profile?.walletBalance ?? 0;
    return balance.toDouble();
  }

  double _computeECoinsDiscount(double available) {
    return 0.0;
  }

  double _finalAmount(double discount) {
    return widget.amount.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobilePrepaidControllerProvider);
    final controller = ref.read(mobilePrepaidControllerProvider.notifier);
    final isPaying = state.isRecharging;
    final availableECoins = _availableECoins();
    final maxPossibleDiscount = _computeECoinsDiscount(availableECoins);
    final eCoinsDiscount = _useECoins ? maxPossibleDiscount : 0.0;
    final finalAmount = _finalAmount(eCoinsDiscount);
    final insufficientECoins = _useECoins && availableECoins < widget.amount;

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
            subtitle: 'Use E-Coins for recharge',
            trailing: Checkbox(
              value: _useECoins,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: availableECoins <= 0
                  ? null
                  : (v) => setState(() => _useECoins = v ?? false),
            ),
            onTap: availableECoins <= 0
                ? null
                : () => setState(() => _useECoins = !_useECoins),
          ),

          const SizedBox(height: 20),

          // UPI heading
          Text(
            'UPI',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),

          // UPI options
          _PaymentOptionTile(
            icon: Icons.g_mobiledata,
            iconColor: Colors.blue,
            title: 'Google Pay',
            trailing: Radio<String>(
              value: 'google_pay',
              groupValue: _selectedUpi,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedUpi = v!),
            ),
            onTap: () => setState(() => _selectedUpi = 'google_pay'),
          ),
          _PaymentOptionTile(
            icon: Icons.account_balance_wallet,
            iconColor: Colors.deepPurple,
            title: 'Phone Pe',
            trailing: Radio<String>(
              value: 'phonepe',
              groupValue: _selectedUpi,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedUpi = v!),
            ),
            onTap: () => setState(() => _selectedUpi = 'phonepe'),
          ),
          _PaymentOptionTile(
            icon: Icons.currency_rupee,
            iconColor: Colors.green,
            title: 'Bhim UPI',
            trailing: Radio<String>(
              value: 'bhim',
              groupValue: _selectedUpi,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedUpi = v!),
            ),
            onTap: () => setState(() => _selectedUpi = 'bhim'),
          ),
          _PaymentOptionTile(
            icon: Icons.grid_view_rounded,
            iconColor: AppColors.textPrimary,
            title: 'More UPI Options',
            trailing: Radio<String>(
              value: 'more',
              groupValue: _selectedUpi,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _selectedUpi = v!),
            ),
            onTap: () => setState(() => _selectedUpi = 'more'),
          ),

          const SizedBox(height: 16),

          // Bottom bar: amount + PAY NOW
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Text(
                    '\u20B9 ${finalAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: insufficientECoins
                        ? () {
                            AppSnackbar.show(
                              "You don't have enough E-Coins for this payment.",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        : null,
                    child: CustomElevatedButton(
                      onPressed: (isPaying || insufficientECoins)
                          ? null
                          : () async {
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
                                      amount: finalAmount,
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
                                      amount: finalAmount,
                                      billerName: 'Mobile Prepaid',
                                      txId: '',
                                    );
                                  }
                                },
                              );
                            },
                      label: isPaying ? 'Processing' : 'Pay Now',
                      showArrow: false,
                      uppercaseLabel: true,
                      width: null,
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

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.5),
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
