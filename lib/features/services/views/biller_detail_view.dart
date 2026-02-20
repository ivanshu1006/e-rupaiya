// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frappe_flutter_app/features/services/models/biller_detail_state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/k_dialog.dart';
import '../../mobile_prepaid/components/payment_bottom_sheet.dart';
import '../controllers/biller_detail_controller.dart';
import '../models/bill_response_model.dart';

class BillerDetailView extends HookConsumerWidget {
  const BillerDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(billerDetailControllerProvider);
    final controller = ref.read(billerDetailControllerProvider.notifier);
    final biller = detailState.selectedBiller;
    final detail = detailState.billerDetail;
    final bill = detailState.billResponse;
    final customerParamsInput = detailState.customerParamsInput ?? {};
    final inputControllers = <String, TextEditingController>{};
    final billAmountController = useTextEditingController();
    final selectedAmountType = useState(_PaymentAmountType.totalOutstanding);

    ref.listen<BillerDetailState>(billerDetailControllerProvider,
        (previous, next) {
      final message = next.errorMessage;
      if (message != null && message.isNotEmpty) {
        if (previous?.errorMessage != message) {
          AppSnackbar.show(
            message,
            behavior: SnackBarBehavior.fixed,
          );
        }
      }
    });

    final totalOutstanding =
        bill == null ? null : _resolveTotalOutstanding(bill);
    final minimumDue = bill == null ? null : _resolveMinimumDue(bill);

    // Set bill amount when fetched
    useEffect(() {
      if (bill != null) {
        selectedAmountType.value = _PaymentAmountType.totalOutstanding;
        final amount = totalOutstanding ?? bill.amountInRupees;
        billAmountController.text = amount.toStringAsFixed(2);
      }
      return null;
    }, [bill, totalOutstanding]);

    // Create controllers for each customer param
    if (detail != null) {
      for (final param in detail.customerParams) {
        if (param.visibility) {
          inputControllers.putIfAbsent(
            param.paramName,
            () => useTextEditingController(),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            controller.reset();
            context.pop();
          },
        ),
        title: Text(
          'Fetch Your Provider',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: AppColors.textPrimary.withOpacity(0.6),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: biller == null
          ? const Center(child: Text('No provider selected'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Provider card
                        _ProviderCard(
                          billerName: biller.billerName,
                          onChangeTap: () {
                            controller.reset();
                            context.pop();
                          },
                        ),
                        const SizedBox(height: 24),

                        // --- Loading detail ---
                        if (detailState.isFetchingDetail)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          )

                        // --- Input form (no bill yet) ---
                        else if (detail != null && bill == null) ...[
                          ...detail.customerParams
                              .where((p) => p.visibility)
                              .map((param) {
                            final tc = inputControllers[param.paramName];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Enter Your ${param.paramName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: tc,
                                    keyboardType: param.dataType == 'NUMERIC'
                                        ? TextInputType.number
                                        : TextInputType.text,
                                    maxLength: param.maxLength,
                                    decoration: InputDecoration(
                                      hintText: _buildHintText(param.maxLength),
                                      counterText: '',
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.lightBorder),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.lightBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ]

                        // --- Compact bill view ---
                        else if (bill != null &&
                            !detailState.showFullDetails) ...[
                          _CompactBillSection(
                            bill: bill,
                            customerParams: customerParamsInput,
                            billAmountController: billAmountController,
                            onToggle: controller.toggleFullDetails,
                            selectedAmountType: selectedAmountType.value,
                            onAmountTypeChanged: (next) {
                              selectedAmountType.value = next;
                              if (next == _PaymentAmountType.totalOutstanding) {
                                final amount =
                                    totalOutstanding ?? bill.amountInRupees;
                                billAmountController.text =
                                    amount.toStringAsFixed(2);
                              } else if (next ==
                                  _PaymentAmountType.minimumDue) {
                                final amount = minimumDue ??
                                    totalOutstanding ??
                                    bill.amountInRupees;
                                billAmountController.text =
                                    amount.toStringAsFixed(2);
                              }
                            },
                            totalOutstanding: totalOutstanding,
                            minimumDue: minimumDue,
                          ),
                        ]

                        // --- Full details view ---
                        else if (bill != null &&
                            detailState.showFullDetails) ...[
                          _FullDetailsSection(
                            bill: bill,
                            customerParams: customerParamsInput,
                            onToggle: controller.toggleFullDetails,
                          ),
                        ],

                        // Loading bill spinner
                        if (detailState.isFetchingBill)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                if (detail != null &&
                    !detailState.isFetchingDetail &&
                    !detailState.isFetchingBill)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: CustomElevatedButton(
                      onPressed: () {
                        if (bill == null) {
                          // Fetch bill
                          final visibleParams = detail.customerParams
                              .where((p) => p.visibility)
                              .toList();
                          if (visibleParams.isEmpty) return;

                          final values = <String, String>{};
                          for (final param in visibleParams) {
                            final value = inputControllers[param.paramName]
                                    ?.text
                                    .trim() ??
                                '';
                            if (!param.optional && value.isEmpty) {
                              AppSnackbar.show(
                                'Please enter ${param.paramName}.',
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              return;
                            }
                            if (value.isNotEmpty) {
                              values[param.paramName] = value;
                            }
                          }

                          if (values.isNotEmpty) {
                            controller.fetchBill(customerParams: values);
                          }
                        } else if (!detailState.showFullDetails) {
                          // Show full details
                          controller.toggleFullDetails();
                        } else {
                          // Open payment bottom sheet
                          final enteredAmount =
                              _parseEnteredAmount(billAmountController.text);
                          final amountToPay =
                              enteredAmount ?? bill.amountInRupees;
                          _showPaymentSheet(
                            context,
                            amountToPay,
                          );
                        }
                      },
                      label: bill != null
                          ? 'Pay \u20B9${(_parseEnteredAmount(billAmountController.text) ?? bill.amountInRupees).toStringAsFixed(0)}'
                          : 'Proceed',
                      showArrow: false,
                      uppercaseLabel: false,
                    ),
                  ),
              ],
            ),
    );
  }

  void _showPaymentSheet(BuildContext context, double amount) {
    KDialog.instance.openSheet(
      dialog: PaymentBottomSheet(amount: amount),
    );
  }

  String _buildHintText(int? maxLength) {
    if (maxLength != null) {
      return List.generate(maxLength, (i) => (i + 1) % 10).join();
    }
    return '';
  }
}

double? _parseEnteredAmount(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

// ─── Provider Card ───────────────────────────────────────────────────────────

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.billerName,
    required this.onChangeTap,
  });

  final String billerName;
  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gradientStart.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.bolt, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              billerName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onChangeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Change',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compact Bill Section ────────────────────────────────────────────────────

class _CompactBillSection extends StatelessWidget {
  const _CompactBillSection({
    required this.bill,
    required this.customerParams,
    required this.billAmountController,
    required this.onToggle,
    required this.selectedAmountType,
    required this.onAmountTypeChanged,
    required this.totalOutstanding,
    required this.minimumDue,
  });

  final BillResponse bill;
  final Map<String, String> customerParams;
  final TextEditingController billAmountController;
  final VoidCallback onToggle;
  final _PaymentAmountType selectedAmountType;
  final ValueChanged<_PaymentAmountType> onAmountTypeChanged;
  final double? totalOutstanding;
  final double? minimumDue;

  @override
  Widget build(BuildContext context) {
    // Pick "Early Payment Date" from additionalParams if available
    final earlyPayDate = bill.additionalParams['Early Payment Date'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grey info card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              ...customerParams.entries.map(
                (entry) => _InfoRow(label: entry.key, value: entry.value),
              ),
              if (earlyPayDate.isNotEmpty)
                _InfoRow(
                  label: 'Early Payment Date',
                  value: earlyPayDate,
                ),
            ],
          ),
        ),

        // Toggle arrow (down)
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _ToggleArrowButton(
              isExpanded: false,
              onTap: onToggle,
            ),
          ),
        ),

        // Amount card (orange border)
        _AmountDisplayCard(bill: bill),

        const SizedBox(height: 16),

        // Late payment warning
        if (bill.latePaymentFormatted.isNotEmpty) ...[
          Text(
            'Payments made after ${bill.dueDate} will incur an additional charge of ${_additionalCharge()}.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.7),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 20),
        ],

        const SizedBox(height: 8),

        _AmountTypeSelector(
          selected: selectedAmountType,
          totalOutstanding: totalOutstanding ?? bill.amountInRupees,
          minimumDue: minimumDue,
          onChanged: onAmountTypeChanged,
        ),

        const SizedBox(height: 14),

        // Bill Amount field
        Text(
          'Bill Amount',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: billAmountController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (selectedAmountType != _PaymentAmountType.custom) {
              onAmountTypeChanged(_PaymentAmountType.custom);
            }
          },
          decoration: InputDecoration(
            prefixText: '\u20B9  ',
            prefixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  String _additionalCharge() {
    // late payment amount – bill amount
    final late =
        (int.tryParse(bill.otherDetails['Late Payment Amount'] ?? '') ?? 0) /
            100;
    final base = bill.amountInRupees;
    final diff = late - base;
    if (diff > 0) {
      return '\u20B9${diff.toStringAsFixed(0)}';
    }
    return bill.latePaymentFormatted;
  }
}

// ─── Amount Display Card ─────────────────────────────────────────────────────

class _AmountDisplayCard extends StatelessWidget {
  const _AmountDisplayCard({required this.bill});

  final BillResponse bill;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: bill period chip + due date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (bill.billPeriod.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Bill for ${_formatBillPeriod(bill.billPeriod)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              if (bill.dueDate.isNotEmpty)
                Text(
                  'Due on: ${bill.dueDate}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Amount
          Text(
            bill.formattedAmount,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  /// Turn "2509" → "Sep '25", or return as-is
  String _formatBillPeriod(String period) {
    if (period.length == 4) {
      final yy = period.substring(0, 2);
      final mm = int.tryParse(period.substring(2));
      if (mm != null && mm >= 1 && mm <= 12) {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return "${months[mm - 1]} '$yy";
      }
    }
    return period;
  }
}

// ─── Full Details Section ────────────────────────────────────────────────────

class _FullDetailsSection extends StatelessWidget {
  const _FullDetailsSection({
    required this.bill,
    required this.customerParams,
    required this.onToggle,
  });

  final BillResponse bill;
  final Map<String, String> customerParams;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // White details card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Customer params
              ...customerParams.entries.map(
                (entry) => _InfoRow(label: entry.key, value: entry.value),
              ),

              // All additional params
              ...bill.additionalParams.entries.map(
                (e) => _InfoRow(label: e.key, value: e.value),
              ),

              // Account holder / Customer Name
              if (bill.accountHolderName.isNotEmpty)
                _InfoRow(
                  label: 'Customer Name',
                  value: bill.accountHolderName,
                ),

              // Due Date
              if (bill.dueDate.isNotEmpty)
                _InfoRow(label: 'Due Date', value: bill.dueDate),

              // Early payment date & amount
              if (bill.earlyPaymentFormatted.isNotEmpty)
                _InfoRow(
                  label: 'Early payment date & amount',
                  value: _earlyPaymentText(),
                ),

              // Due payment date & amount
              if (bill.dueDate.isNotEmpty)
                _InfoRow(
                  label: 'Due payment date & amount',
                  value: _duePaymentText(),
                ),

              // Late payment date & amount
              if (bill.latePaymentFormatted.isNotEmpty)
                _InfoRow(
                  label: 'Late payment date & amount',
                  value: _latePaymentText(),
                ),
            ],
          ),
        ),

        // Toggle arrow (up)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: _ToggleArrowButton(
              isExpanded: true,
              onTap: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  String _earlyPaymentText() {
    final earlyDate = bill.additionalParams['Early Payment Date'] ?? '';
    if (earlyDate.isNotEmpty) {
      return 'Before $earlyDate - ${bill.earlyPaymentFormatted}';
    }
    return bill.earlyPaymentFormatted;
  }

  String _duePaymentText() {
    final earlyDate = bill.additionalParams['Early Payment Date'] ?? '';
    final dueDate = bill.dueDate;
    final amount = bill.earlyPaymentFormatted.isNotEmpty
        ? bill.earlyPaymentFormatted
        : bill.formattedAmount;
    if (earlyDate.isNotEmpty && dueDate.isNotEmpty) {
      return '$earlyDate to $dueDate - $amount';
    }
    return '$dueDate - $amount';
  }

  String _latePaymentText() {
    final dueDate = bill.dueDate;
    if (dueDate.isNotEmpty) {
      return 'After $dueDate - ${bill.latePaymentFormatted}';
    }
    return bill.latePaymentFormatted;
  }
}

// ─── Toggle Arrow Button ─────────────────────────────────────────────────────

class _ToggleArrowButton extends StatelessWidget {
  const _ToggleArrowButton({
    required this.isExpanded,
    required this.onTap,
  });

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// ─── Info Row ────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PaymentAmountType {
  totalOutstanding,
  minimumDue,
  custom,
}

class _AmountTypeSelector extends StatelessWidget {
  const _AmountTypeSelector({
    required this.selected,
    required this.totalOutstanding,
    required this.minimumDue,
    required this.onChanged,
  });

  final _PaymentAmountType selected;
  final double totalOutstanding;
  final double? minimumDue;
  final ValueChanged<_PaymentAmountType> onChanged;

  @override
  Widget build(BuildContext context) {
    final resolvedMinimum = minimumDue;
    return Column(
      children: [
        _AmountChoiceTile(
          title: 'Total outstanding',
          subtitle: '\u20B9 ${totalOutstanding.toStringAsFixed(2)}',
          value: _PaymentAmountType.totalOutstanding,
          groupValue: selected,
          onChanged: onChanged,
        ),
        _AmountChoiceTile(
          title: 'Minimum amount due',
          subtitle: resolvedMinimum == null
              ? 'Not available'
              : '\u20B9 ${resolvedMinimum.toStringAsFixed(2)}',
          value: _PaymentAmountType.minimumDue,
          groupValue: selected,
          onChanged: resolvedMinimum == null ? null : onChanged,
        ),
        _AmountChoiceTile(
          title: 'Custom amount',
          subtitle: 'Enter any amount',
          value: _PaymentAmountType.custom,
          groupValue: selected,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _AmountChoiceTile extends StatelessWidget {
  const _AmountChoiceTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final _PaymentAmountType value;
  final _PaymentAmountType groupValue;
  final ValueChanged<_PaymentAmountType>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final isDisabled = onChanged == null;
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDisabled
              ? AppColors.textPrimary.withOpacity(0.4)
              : AppColors.textPrimary,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDisabled
              ? AppColors.textPrimary.withOpacity(0.35)
              : AppColors.textPrimary.withOpacity(0.65),
        );

    return InkWell(
      onTap: isDisabled ? null : () => onChanged?.call(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Radio<_PaymentAmountType>(
              value: value,
              groupValue: groupValue,
              activeColor: AppColors.primary,
              onChanged: isDisabled ? null : (next) => onChanged?.call(next!),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: subtitleStyle),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

double _resolveTotalOutstanding(BillResponse bill) {
  final amount = _extractAmountFromDetails(
    bill,
    const [
      'Total Outstanding',
      'Total Outstanding Amount',
      'Total Amount Due',
      'Total Due',
      'Outstanding Amount',
      'Total Amount',
    ],
  );
  return amount ?? bill.amountInRupees;
}

double? _resolveMinimumDue(BillResponse bill) {
  return _extractAmountFromDetails(
    bill,
    const [
      'Minimum Amount Due',
      'MinimumDueAmount',
      'Minimum Due',
      'Minimum Payment',
      'Min Amount Due',
      'Min Due',
    ],
  );
}

double? _extractAmountFromDetails(BillResponse bill, List<String> keys) {
  double? scanMap(Map<String, String> source) {
    for (final key in keys) {
      final direct = source[key];
      final parsed = _parseAmountMaybe(direct);
      if (parsed != null) return parsed;
    }
    for (final entry in source.entries) {
      final normalized = entry.key.trim().toLowerCase();
      for (final key in keys) {
        if (normalized == key.toLowerCase()) {
          final parsed = _parseAmountMaybe(entry.value);
          if (parsed != null) return parsed;
        }
      }
    }
    return null;
  }

  final fromOther = scanMap(bill.otherDetails);
  if (fromOther != null) return fromOther;

  final fromAdditional = scanMap(bill.additionalParams);
  if (fromAdditional != null) return fromAdditional;

  return null;
}

double? _parseAmountMaybe(String? raw) {
  if (raw == null) return null;
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null) return null;
  if (raw.contains('.')) return value;
  if (cleaned.length > 4) return value / 100;
  return value;
}

// ─── Error Section ───────────────────────────────────────────────────────────

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.red.shade700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
