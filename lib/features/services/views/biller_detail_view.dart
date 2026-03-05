// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:e_rupaiya/features/services/models/biller_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../services/permission_service.dart';
import '../../../utils/date_format_helper.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/bill_sample_terms_card.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/date_picker_field.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/param_dropdown_field.dart';
import '../../../widgets/search_textfield.dart';
import '../../home/components/quick_action_card.dart';
import '../../mobile_prepaid/components/payment_bottom_sheet.dart';
import '../controllers/biller_detail_controller.dart';
import '../models/bill_response_model.dart';
import '../models/biller_detail_args.dart';
import '../models/biller_detail_model.dart';

class BillerDetailView extends HookConsumerWidget {
  const BillerDetailView({super.key, this.args});

  final BillerDetailArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(billerDetailControllerProvider);
    final controller = ref.read(billerDetailControllerProvider.notifier);
    final biller = detailState.selectedBiller ?? args?.biller;
    final detail = detailState.billerDetail;
    final bill = detailState.billResponse;
    final customerParamsInput = detailState.customerParamsInput ?? {};
    final inputControllers = <String, TextEditingController>{};
    final billAmountController = useTextEditingController();
    final selectedAmountType = useState(_PaymentAmountType.totalOutstanding);
    final permissionService = useMemoized(() => const PermissionService());
    final isCreditCardFlow = args?.isCreditCard ?? false;
    final isGasCylinder = useMemoized(
      () => _isGasCylinderBiller(biller?.billerName ?? ''),
      [biller?.billerName],
    );
    final showBillSample = useState(false);
    final fieldErrors = useState<Map<String, String?>>({});

    useEffect(() {
      final argBiller = args?.biller;
      if (argBiller != null &&
          detailState.selectedBiller?.billerId != argBiller.billerId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          controller.selectBiller(argBiller);
        });
      }
      return null;
    }, [args?.biller.billerId]);

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
        final amount = _resolveDateBasedAmount(bill);
        billAmountController.text = amount.toStringAsFixed(2);
      }
      return null;
    }, [bill]);

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

    return PopScope(
      canPop: detailState.billResponse == null,
      onPopInvoked: (didPop) {
        if (didPop) return;
        controller.clearBill();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: MyAppBar(
            title: 'Fetch Your Provider',
            showHelp: true,
            onBack: () {
              if (detailState.billResponse != null) {
                controller.clearBill();
              } else {
                controller.reset();
                context.pop();
              }
            },
            onHelp: () {},
          ),
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
                          QuickActionCard(
                            title: biller.billerName,
                            subtitle: '',
                            amount: 'Change',
                            buttonLabel: '',
                            imageUrl: biller.iconUrl,
                            showTail: true,
                            showLeadingImage: true,
                            onTap: () {
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
                            if (isGasCylinder) ...[
                              BillSampleTermsCard(
                                isExpanded: showBillSample.value,
                                onToggle: () => showBillSample.value =
                                    !showBillSample.value,
                              ),
                              const SizedBox(height: 16),
                            ],
                            ...detail.customerParams
                                .where((p) => p.visibility)
                                .map((param) {
                              final tc = inputControllers[param.paramName];
                              final isLastFour =
                                  _isLastFourParam(param.paramName);
                              final isMobile = _isMobileParam(param.paramName);
                              final isDate =
                                  DateFormatHelper.isDateParam(param.paramName);
                              final dateFormat = isDate
                                  ? DateFormatHelper.extractFormat(
                                      param.paramName)
                                  : null;
                              final errorText =
                                  fieldErrors.value[param.paramName];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Enter Your ${param.paramName}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        if (param.optional)
                                          Text(
                                            ' (Optional)',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.textPrimary
                                                      .withOpacity(0.5),
                                                ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (isDate)
                                      DatePickerField(
                                        controller: tc!,
                                        dateFormat: dateFormat!,
                                        errorText: errorText,
                                        onDatePicked: () {
                                          if (fieldErrors.value
                                              .containsKey(param.paramName)) {
                                            fieldErrors.value =
                                                Map.from(fieldErrors.value)
                                                  ..remove(param.paramName);
                                          }
                                        },
                                      )
                                    else if (param.hasDropdown)
                                      ParamDropdownField(
                                        controller: tc!,
                                        items: param.values,
                                        hintText: 'Select ${param.paramName}',
                                        errorText: errorText,
                                        onChanged: (_) {
                                          if (fieldErrors.value
                                              .containsKey(param.paramName)) {
                                            fieldErrors.value =
                                                Map.from(fieldErrors.value)
                                                  ..remove(param.paramName);
                                          }
                                        },
                                      )
                                    else
                                      TextField(
                                        controller: tc,
                                        keyboardType:
                                            param.dataType == 'NUMERIC'
                                                ? TextInputType.number
                                                : TextInputType.text,
                                        maxLength:
                                            isLastFour ? 4 : param.maxLength,
                                        onChanged: (_) {
                                          if (fieldErrors.value
                                              .containsKey(param.paramName)) {
                                            fieldErrors.value =
                                                Map.from(fieldErrors.value)
                                                  ..remove(param.paramName);
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: _buildParamHint(param),
                                          errorText: errorText,
                                          counterText: '',
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          prefixIcon: isLastFour
                                              ? _MaskedPrefix()
                                              : null,
                                          suffixIcon: isMobile
                                              ? IconButton(
                                                  icon: const Icon(
                                                    Icons.contact_phone,
                                                    color: AppColors.primary,
                                                  ),
                                                  onPressed: () async {
                                                    final picked =
                                                        await _pickContactNumber(
                                                      context,
                                                      permissionService,
                                                    );
                                                    if (picked != null &&
                                                        picked.isNotEmpty) {
                                                      tc?.text = picked;
                                                    }
                                                  },
                                                )
                                              : null,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: AppColors.lightBorder),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: AppColors.lightBorder),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: AppColors.primary),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Colors.red),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: Colors.red),
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
                                if (next ==
                                    _PaymentAmountType.totalOutstanding) {
                                  final amount = _resolveDateBasedAmount(bill);
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
                              isCreditCardFlow: isCreditCardFlow,
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

                          if (detail != null && bill == null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.lightBorder.withOpacity(0.7),
                                ),
                              ),
                              child: Text(
                                'By proceeding further, you allow E-Rupaiya to store your bill details, fetch current and future bills, and send you reminders.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textPrimary
                                          .withOpacity(0.7),
                                      height: 1.5,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
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
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: billAmountController,
                            builder: (context, value, _) {
                              final payLabel = bill != null
                                  // ? 'Pay \u20B9${_resolvedPayAmount(billAmountController, bill).toStringAsFixed(0)}'
                                  ? 'Proceed to Pay'
                                  : 'Confirm';
                              final enteredAmount =
                                  _parseEnteredAmount(value.text);
                              final shouldDisablePay =
                                  bill != null && (enteredAmount ?? 0) <= 0;
                              return CustomElevatedButton(
                                onPressed: shouldDisablePay
                                    ? null
                                    : () {
                                        if (bill == null) {
                                          // Validate all visible params
                                          final visibleParams = detail
                                              .customerParams
                                              .where((p) => p.visibility)
                                              .toList();
                                          if (visibleParams.isEmpty) return;

                                          final errors = <String, String?>{};
                                          final values = <String, String>{};
                                          for (final param in visibleParams) {
                                            final value = inputControllers[
                                                        param.paramName]
                                                    ?.text
                                                    .trim() ??
                                                '';
                                            final error =
                                                _validateParam(param, value);
                                            if (error != null) {
                                              errors[param.paramName] = error;
                                            } else if (value.isNotEmpty) {
                                              values[param.paramName] = value;
                                            }
                                          }

                                          if (errors.isNotEmpty) {
                                            fieldErrors.value = errors;
                                            return;
                                          }
                                          fieldErrors.value = {};

                                          if (values.isNotEmpty) {
                                            controller.fetchBill(
                                                customerParams: values);
                                          }
                                        } else if (!detailState
                                            .showFullDetails) {
                                          // Show full details
                                          controller.toggleFullDetails();
                                        } else {
                                          // Open payment bottom sheet
                                          final amountToPay = enteredAmount ??
                                              bill.amountInRupees;
                                          _showPaymentSheet(
                                            context,
                                            amountToPay,
                                          );
                                        }
                                      },
                                label: payLabel,
                                showArrow: false,
                                uppercaseLabel: false,
                              );
                            },
                          ),
                          if (bill == null) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Powered by',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textPrimary
                                            .withOpacity(0.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  FileConstants.bharatConnectColor,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, double amount) {
    KDialog.instance.openSheet(
      dialog: PaymentBottomSheet(amount: amount),
    );
  }

  String _buildParamHint(BillerCustomerParam param) {
    return '';
  }

  String? _validateParam(BillerCustomerParam param, String value) {
    if (value.isEmpty) {
      return param.optional ? null : 'Please enter ${param.paramName}';
    }
    final min = param.minLength;
    final max = param.maxLength;
    if (min != null && value.length < min) {
      return max != null && min == max
          ? '${param.paramName} must be $min characters'
          : '${param.paramName} must be at least $min characters';
    }
    final regexStr = param.regex?.trim();
    if (regexStr != null && regexStr.isNotEmpty) {
      try {
        if (!RegExp(regexStr).hasMatch(value)) {
          if (min != null && max != null) {
            return 'Enter a valid ${param.paramName.toLowerCase()} ($min–$max characters)';
          }
          return 'Invalid ${param.paramName.toLowerCase()}';
        }
      } catch (_) {
        // Skip malformed regex
      }
    }
    return null;
  }
}

bool _isGasCylinderBiller(String name) {
  final value = name.toLowerCase();
  return value.contains('gas') ||
      value.contains('lpg') ||
      value.contains('cylinder');
}

class _MaskedPrefix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              letterSpacing: 1.2,
              color: AppColors.textPrimary.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

bool _isLastFourParam(String name) {
  final normalized = name.toLowerCase();
  return normalized.contains('last 4') ||
      normalized.contains('last4') ||
      normalized.contains('last four') ||
      normalized.contains('last digits');
}

bool _isMobileParam(String name) {
  final normalized = name.toLowerCase();
  return normalized.contains('mobile') ||
      normalized.contains('phone') ||
      normalized.contains('contact');
}

String _sanitizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length > 10) {
    return digits.substring(digits.length - 10);
  }
  return digits;
}

Future<String?> _pickContactNumber(
  BuildContext context,
  PermissionService permissionService,
) async {
  final status = await Permission.contacts.status;
  if (status.isPermanentlyDenied) {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contacts permission'),
          content: const Text(
            'Contacts permission is required to pick a number.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
    if (openSettings == true) {
      await openAppSettings();
    }
    return null;
  }

  final granted = status.isGranted || await permissionService.requestContacts();
  if (!granted) {
    AppSnackbar.show(
      'Contacts permission is required.',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return null;
  }

  try {
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    if (contacts.isEmpty) {
      AppSnackbar.show(
        'No contacts found.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return null;
    }

    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _ContactPickerSheet(contacts: contacts);
      },
    );
  } catch (_) {
    AppSnackbar.show(
      'Unable to access contacts.',
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return null;
  }
}

// double _resolvedPayAmount(
//   TextEditingController controller,
//   BillResponse bill,
// ) {
//   final entered = _parseEnteredAmount(controller.text);
//   if (entered != null && entered > 0) return entered;
//   return bill.amountInRupees;
// }

double? _parseEnteredAmount(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

class _ContactPickerSheet extends StatefulWidget {
  const _ContactPickerSheet({required this.contacts});

  final List<Contact> contacts;

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = widget.contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phone =
          contact.phones.isNotEmpty ? contact.phones.first.number : '';
      return name.contains(query) || phone.contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select Contact',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          SearchTextfield(
            hintText: 'Search contacts',
            controller: _searchController,
            onChange: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No contacts found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.6),
                          ),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.textPrimary.withOpacity(0.1),
                    ),
                    itemBuilder: (context, index) {
                      final contact = filtered[index];
                      final phone = contact.phones.isNotEmpty
                          ? contact.phones.first.number
                          : '';
                      return ListTile(
                        title: Text(contact.displayName),
                        subtitle: Text(phone),
                        onTap: phone.isEmpty
                            ? null
                            : () => Navigator.of(context)
                                .pop(_sanitizePhone(phone)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Provider Card ───────────────────────────────────────────────────────────

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
    required this.isCreditCardFlow,
  });

  final BillResponse bill;
  final Map<String, String> customerParams;
  final TextEditingController billAmountController;
  final VoidCallback onToggle;
  final _PaymentAmountType selectedAmountType;
  final ValueChanged<_PaymentAmountType> onAmountTypeChanged;
  final double? totalOutstanding;
  final double? minimumDue;
  final bool isCreditCardFlow;

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

        if (isCreditCardFlow) ...[
          Text(
            'Pay Bill (As per your convenience)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          _CreditCardAmountSelector(
            selected: selectedAmountType,
            totalOutstanding: totalOutstanding ?? bill.amountInRupees,
            minimumDue: minimumDue,
            onChanged: onAmountTypeChanged,
          ),
          const SizedBox(height: 16),
        ],

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
          readOnly: !isCreditCardFlow,
          onChanged: (value) {
            if (selectedAmountType != _PaymentAmountType.custom) {
              onAmountTypeChanged(_PaymentAmountType.custom);
            }
            if (billAmountController.text != value) {
              billAmountController.text = value;
            }
          },
          onEditingComplete: () {
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
              if (_hasValidBillPeriod(bill.billPeriod))
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
                  'Due on: ${DateFormatHelper.formatDisplayDate(bill.dueDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Amount
          Text(
            _resolvedAmountText(),
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

  bool _hasValidBillPeriod(String period) {
    final value = period.trim().toLowerCase();
    if (value.isEmpty) return false;
    if (value == 'na' || value == 'n/a' || value == 'null') return false;
    if (value == '-' || value == '--') return false;
    return true;
  }

  String _resolvedAmountText() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final earlyDate = _parseDueDate(
      bill.additionalParams['Early Payment Date'] ?? '',
    );
    final dueDate = _parseDueDate(bill.dueDate);

    // On or before early payment date → show early payment amount
    final earlyAmount =
        _parseAmountMaybe(bill.otherDetails['Early Payment Amount']);
    if (earlyDate != null &&
        earlyAmount != null &&
        !todayDate.isAfter(earlyDate)) {
      return _formatRupees(earlyAmount);
    }

    // After due date → show late payment amount
    final lateAmount =
        _parseAmountMaybe(bill.otherDetails['Late Payment Amount']);
    if (dueDate != null && lateAmount != null && todayDate.isAfter(dueDate)) {
      return _formatRupees(lateAmount);
    }

    // Between early payment date and due date → regular amount
    return bill.formattedAmount;
  }

  DateTime? _parseDueDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final iso = DateTime.tryParse(value);
    if (iso != null) {
      return iso.isUtc ? iso.toLocal() : iso;
    }

    final numeric = RegExp(r'^(\\d{1,2})[./-](\\d{1,2})[./-](\\d{2,4})$');
    final match = numeric.firstMatch(value);
    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '');
      final month = int.tryParse(match.group(2) ?? '');
      var year = int.tryParse(match.group(3) ?? '');
      if (day == null || month == null || year == null) return null;
      if (year < 100) year += 2000;
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;
      return DateTime(year, month, day);
    }
    return null;
  }

  String _formatRupees(double amount) {
    return '\u20B9${amount.toStringAsFixed(2)}';
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

class _CreditCardAmountSelector extends StatelessWidget {
  const _CreditCardAmountSelector({
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
    return Row(
      children: [
        Expanded(
          child: _CreditCardAmountCard(
            title: 'Total Due Amount',
            amount: '\u20B9${totalOutstanding.toStringAsFixed(0)}',
            isSelected: selected == _PaymentAmountType.totalOutstanding,
            onTap: () => onChanged(_PaymentAmountType.totalOutstanding),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CreditCardAmountCard(
            title: 'Min. Payable Amount',
            amount: resolvedMinimum == null
                ? '\u20B90'
                : '\u20B9${resolvedMinimum.toStringAsFixed(0)}',
            isSelected: selected == _PaymentAmountType.minimumDue,
            onTap: resolvedMinimum == null
                ? null
                : () => onChanged(_PaymentAmountType.minimumDue),
          ),
        ),
      ],
    );
  }
}

class _CreditCardAmountCard extends StatelessWidget {
  const _CreditCardAmountCard({
    required this.title,
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String amount;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : AppColors.lightBorder;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            SizedBox(
              height: 92.h,
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderColor, width: 1.2.w),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
            if (onTap != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Image.asset(
                  FileConstants.ellipse7,
                  width: 60.w,
                  height: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
            if (onTap != null)
              Positioned(
                right: 22.w,
                bottom: 22.w,
                child: Icon(
                  Icons.arrow_forward,
                  size: 20.sp,
                  color: Colors.white,
                ),
              ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      amount,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _AmountTypeSelector extends StatelessWidget {
//   const _AmountTypeSelector({
//     required this.selected,
//     required this.totalOutstanding,
//     required this.minimumDue,
//     required this.onChanged,
//   });

//   final _PaymentAmountType selected;
//   final double totalOutstanding;
//   final double? minimumDue;
//   final ValueChanged<_PaymentAmountType> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     final resolvedMinimum = minimumDue;
//     return Column(
//       children: [
//         _AmountChoiceTile(
//           title: 'Total outstanding',
//           subtitle: '\u20B9 ${totalOutstanding.toStringAsFixed(2)}',
//           value: _PaymentAmountType.totalOutstanding,
//           groupValue: selected,
//           onChanged: onChanged,
//         ),
//         if (resolvedMinimum != null)
//           _AmountChoiceTile(
//             title: 'Minimum amount due',
//             subtitle: '\u20B9 ${resolvedMinimum.toStringAsFixed(2)}',
//             value: _PaymentAmountType.minimumDue,
//             groupValue: selected,
//             onChanged: onChanged,
//           ),
//         _AmountChoiceTile(
//           title: 'Custom amount',
//           subtitle: 'Enter any amount',
//           value: _PaymentAmountType.custom,
//           groupValue: selected,
//           onChanged: onChanged,
//         ),
//       ],
//     );
//   }
// }

// class _AmountChoiceTile extends StatelessWidget {
//   const _AmountChoiceTile({
//     required this.title,
//     required this.subtitle,
//     required this.value,
//     required this.groupValue,
//     required this.onChanged,
//   });

//   final String title;
//   final String subtitle;
//   final _PaymentAmountType value;
//   final _PaymentAmountType groupValue;
//   final ValueChanged<_PaymentAmountType>? onChanged;

//   @override
//   Widget build(BuildContext context) {
//     final isSelected = value == groupValue;
//     final isDisabled = onChanged == null;
//     final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
//           fontWeight: FontWeight.w600,
//           color: isDisabled
//               ? AppColors.textPrimary.withOpacity(0.4)
//               : AppColors.textPrimary,
//         );
//     final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
//           color: isDisabled
//               ? AppColors.textPrimary.withOpacity(0.35)
//               : AppColors.textPrimary.withOpacity(0.65),
//         );

//     return InkWell(
//       onTap: isDisabled ? null : () => onChanged?.call(value),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6),
//         child: Row(
//           children: [
//             Radio<_PaymentAmountType>(
//               value: value,
//               groupValue: groupValue,
//               activeColor: AppColors.primary,
//               onChanged: isDisabled ? null : (next) => onChanged?.call(next!),
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title, style: titleStyle),
//                   const SizedBox(height: 2),
//                   Text(subtitle, style: subtitleStyle),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               const Icon(
//                 Icons.check_circle,
//                 color: AppColors.primary,
//                 size: 18,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// Returns the amount to display/pay based on today's date vs early/due dates.
double _resolveDateBasedAmount(BillResponse bill) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  final earlyDate = _parseDateString(
    bill.additionalParams['Early Payment Date'] ?? '',
  );
  final dueDate = _parseDateString(bill.dueDate);

  final earlyAmount =
      _parseAmountMaybe(bill.otherDetails['Early Payment Amount']);
  if (earlyDate != null &&
      earlyAmount != null &&
      !todayDate.isAfter(earlyDate)) {
    return earlyAmount;
  }

  final lateAmount =
      _parseAmountMaybe(bill.otherDetails['Late Payment Amount']);
  if (dueDate != null && lateAmount != null && todayDate.isAfter(dueDate)) {
    return lateAmount;
  }

  return bill.amountInRupees;
}

DateTime? _parseDateString(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;
  final iso = DateTime.tryParse(value);
  if (iso != null) return iso.isUtc ? iso.toLocal() : iso;
  final numeric = RegExp(r'^(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})$');
  final match = numeric.firstMatch(value);
  if (match != null) {
    final day = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    var year = int.tryParse(match.group(3) ?? '');
    if (day == null || month == null || year == null) return null;
    if (year < 100) year += 2000;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }
  return null;
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
