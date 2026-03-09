// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:e_rupaiya/constants/file_constants.dart';
import 'package:e_rupaiya/features/mobile_prepaid/models/mobile_prepaid_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../services/permission_service.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/screen_wrapper.dart';
import '../../../widgets/search_textfield.dart';
import '../components/payment_bottom_sheet.dart';
import '../components/plan_card.dart';
import '../controllers/contacts_cache_controller.dart';
import '../controllers/mobile_prepaid_controller.dart';
import '../controllers/prepaid_meta_controller.dart';
import '../models/operator_option.dart';
import '../models/plan_item.dart';
import '../models/recharge_quick_action_payload.dart';
import '../models/region_option.dart';

List<int> _filterContactIndices(Map<String, dynamic> payload) {
  final rawEntries = payload['entries'] as List<dynamic>? ?? const [];
  final query = (payload['query'] as String? ?? '').toLowerCase();
  if (rawEntries.isEmpty) return const [];
  if (query.isEmpty) {
    return List<int>.generate(rawEntries.length, (index) => index);
  }
  final matches = <int>[];
  for (var i = 0; i < rawEntries.length; i++) {
    final entry = rawEntries[i] as Map;
    final name = (entry['name'] as String? ?? '');
    final phone = (entry['phone'] as String? ?? '');
    if (name.contains(query) || phone.contains(query)) {
      matches.add(i);
    }
  }
  return matches;
}

String _normalizeMobile(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length > 10 && digits.startsWith('91')) {
    return digits.substring(digits.length - 10);
  }
  return digits;
}

class MobilePrepaidView extends HookConsumerWidget {
  const MobilePrepaidView({super.key, this.quickAction});

  final RechargeQuickActionPayload? quickAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mobilePrepaidControllerProvider);
    final controller = ref.read(mobilePrepaidControllerProvider.notifier);
    final quickActionPayload = quickAction;

    final permissionService = useMemoized(() => const PermissionService());
    final hasPermission = useState(false);
    final contactsState = ref.watch(contactsCacheControllerProvider);
    final contactsController =
        ref.read(contactsCacheControllerProvider.notifier);
    final filteredContacts = useState<List<Contact>>([]);
    final contactQuery = useState('');
    final contactSearchController = useTextEditingController();
    final isMounted = useIsMounted();
    final filterToken = useRef(0);

    final manualMobileController = useTextEditingController();
    final planSearchController =
        useTextEditingController(text: state.planSearchQuery);

    final showPlans = state.mobile.isNotEmpty || state.operatorInfo != null;

    useEffect(() {
      return () {
        controller.reset();
      };
    }, const []);

    Future<void> loadContacts() async {
      await contactsController.fetchIfNeeded();
    }

    useEffect(() {
      Future.microtask(() async {
        final granted = await permissionService.hasContactsPermission();
        if (!isMounted()) return;
        hasPermission.value = granted;
        if (granted) {
          await loadContacts();
        }
      });
      return null;
    }, const []);

    useEffect(() {
      if (quickActionPayload == null) return null;
      Future.microtask(() async {
        final phone = _normalizeMobile(quickActionPayload.phone.trim());
        if (phone.isEmpty) return;
        manualMobileController.text = phone;
        await controller.fetchOperatorAndPlans(phone);
        if (quickActionPayload.amount > 0) {
          controller.updatePlanSearch(
            quickActionPayload.amount.toString(),
          );
        }
      });
      return null;
    }, [quickActionPayload]);

    Future<void> handleRequestPermission() async {
      final granted = await permissionService.requestContacts();
      if (!isMounted()) return;
      hasPermission.value = granted;
      if (granted) {
        await contactsController.reload();
      }
    }

    useEffect(() {
      if (planSearchController.text != state.planSearchQuery) {
        planSearchController.text = state.planSearchQuery;
      }
      return null;
    }, [state.planSearchQuery]);

    useEffect(() {
      if (contactSearchController.text != contactQuery.value) {
        contactSearchController.text = contactQuery.value;
      }
      return null;
    }, [contactQuery.value]);

    Future<void> rebuildFilteredContacts() async {
      final entries = contactsState.searchIndex;
      if (entries.isEmpty) {
        filteredContacts.value = [];
        return;
      }
      final token = ++filterToken.value;
      final query = contactQuery.value.trim().toLowerCase();
      final indices = await compute(
        _filterContactIndices,
        <String, dynamic>{
          'entries': entries,
          'query': query,
        },
      );
      if (!isMounted() || token != filterToken.value) return;
      filteredContacts.value = [
        for (final i in indices)
          if (i >= 0 && i < contactsState.contacts.length)
            contactsState.contacts[i],
      ];
    }

    useEffect(() {
      Future.microtask(rebuildFilteredContacts);
      return null;
    }, [contactQuery.value, contactsState.searchIndex]);

    final lastError = useRef<String?>(null);
    final lastMessage = useRef<String?>(null);

    useEffect(() {
      if (state.errorMessage != null && state.errorMessage != lastError.value) {
        lastError.value = state.errorMessage;
        final message = state.errorMessage?.trim().toLowerCase() ?? '';
        if (message == 'unable to process recharge') {
          return null;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade400,
            ),
          );
        });
      }
      return null;
    }, [state.errorMessage]);

    useEffect(() {
      if (state.rechargeMessage != null &&
          state.rechargeMessage != lastMessage.value) {
        lastMessage.value = state.rechargeMessage;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.rechargeMessage!),
              backgroundColor: AppColors.primary,
            ),
          );
        });
      }
      return null;
    }, [state.rechargeMessage]);

    final hasPlanSelected = showPlans && state.selectedPlan != null;
    final showOperatorCard = showPlans || hasPlanSelected;
    final isOpeningOperatorSheet = useState(false);

    Future<void> handleChange() async {
      if (isOpeningOperatorSheet.value) return;
      isOpeningOperatorSheet.value = true;
      try {
        await _openOperatorSheet(
          ref,
          mobile: state.mobile,
          onSelected: (operator, region) async {
            await controller.fetchPlansForSelection(
              mobileInput: state.mobile,
              operatorName: operator.name,
              circleName: region.name,
              circleCode: region.code,
              iconUrl: operator.iconUrl,
            );
          },
        );
      } finally {
        isOpeningOperatorSheet.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App bar + overlapping operator card
          Stack(
            clipBehavior: Clip.none,
            children: [
              MyAppBar(
                title: hasPlanSelected ? 'Pay Now' : 'Select A Recharge Plan',
                onBack: () {
                  if (hasPlanSelected) {
                    controller.deselectPlan();
                    return;
                  }
                  if (showPlans) {
                    controller.reset();
                    manualMobileController.clear();
                    planSearchController.clear();
                    contactQuery.value = '';
                    return;
                  }
                  Navigator.of(context).maybePop();
                },
              ),
              if (showOperatorCard)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: -38.h,
                  height: 72.h,
                  child: _QuickActionHeaderCard(
                    mobileNumber: state.mobile,
                    operatorName: state.operatorInfo?.operatorName,
                    circleName: state.operatorInfo?.circle,
                    operatorIconUrl: state.operatorInfo?.iconUrl,
                    onChange: handleChange,
                  ),
                ),
            ],
          ),
          SizedBox(height: showOperatorCard ? 20.h : 16.h),
          // Space for the overlapping card
          if (showOperatorCard) const SizedBox(height: 36),
          // Main content
          Expanded(
            child: !hasPermission.value
                ? _PermissionEmptyState(onAllow: handleRequestPermission)
                : hasPlanSelected
                    ? _PayNowSection(
                        state: state,
                        controller: controller,
                      )
                    : showPlans
                        ? _PlanSection(
                            state: state,
                            controller: controller,
                            planSearchController: planSearchController,
                          )
                        : _ContactsSection(
                            isLoading: contactsState.isLoading,
                            contacts: filteredContacts.value,
                            contactSearchController: contactSearchController,
                            onQueryChange: (value) =>
                                contactQuery.value = value,
                            onReload: loadContacts,
                            onSelect: (mobile) {
                              controller.fetchOperatorAndPlans(
                                _normalizeMobile(mobile),
                              );
                            },
                            manualMobileController: manualMobileController,
                            onManualSubmit: () => controller
                                .fetchOperatorAndPlans(_normalizeMobile(
                              manualMobileController.text,
                            )),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ContactsSection extends StatelessWidget {
  const _ContactsSection({
    required this.isLoading,
    required this.contacts,
    required this.contactSearchController,
    required this.onQueryChange,
    required this.onReload,
    required this.onSelect,
    required this.manualMobileController,
    required this.onManualSubmit,
  });

  final bool isLoading;
  final List<Contact> contacts;
  final TextEditingController contactSearchController;
  final ValueChanged<String> onQueryChange;
  final VoidCallback onReload;
  final ValueChanged<String> onSelect;
  final TextEditingController manualMobileController;
  final VoidCallback onManualSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Enter Mobile Number',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: manualMobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter mobile number',
                  hintStyle: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.45),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.lightBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => onManualSubmit(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: onManualSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Get Plans'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Contacts',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onReload,
              child: Text(
                'Refresh',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SearchTextfield(
          hintText: 'Search contacts',
          controller: contactSearchController,
          onChange: onQueryChange,
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: SpinKitCircle(
              color: AppColors.primary,
              size: 48,
            ),
          )
        else if (contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No contacts found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
              ),
            ),
          )
        else
          _ContactsList(contacts: contacts, onSelect: onSelect),
      ],
    );
  }
}

class _PlanSection extends StatelessWidget {
  const _PlanSection({
    required this.state,
    required this.controller,
    required this.planSearchController,
  });

  final MobilePrepaidState state;
  final MobilePrepaidController controller;
  final TextEditingController planSearchController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        SearchTextfield(
          hintText: 'Search a plan, eg 299, 5g, etc.',
          controller: planSearchController,
          onChange: controller.updatePlanSearch,
        ),
        const SizedBox(height: 18),
        Text(
          'Suggested Plans',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 14),
        if (!state.isFetching && state.currentPlans.isNotEmpty)
          _SuggestedPlanCards(
            plans: state.currentPlans,
            onSelect: controller.selectPlan,
          ),
        if (!state.isFetching && state.currentPlans.isNotEmpty)
          const SizedBox(height: 12),
        _CategoryTabs(
          categories: state.categories,
          selected: state.selectedCategory,
          onSelected: controller.selectCategory,
        ),
        const SizedBox(height: 10),
        if (state.isFetching)
          const Center(
            child: SpinKitCircle(
              color: AppColors.primary,
              size: 48,
            ),
          )
        else if (state.filteredPlans.isEmpty)
          _EmptyPlansState(query: state.planSearchQuery)
        else
          _PlanList(
            plans: state.filteredPlans,
            selectedPlan: state.selectedPlan,
            onSelect: controller.selectPlan,
          ),
      ],
    );
  }
}

class _PayNowSection extends StatelessWidget {
  const _PayNowSection({
    required this.state,
    required this.controller,
  });

  final MobilePrepaidState state;
  final MobilePrepaidController controller;

  @override
  Widget build(BuildContext context) {
    final plan = state.selectedPlan!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Plan details card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 12,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Price + E-Coins badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹ ${plan.amount}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  fontSize: 28,
                                ),
                          ),
                          const Spacer(),
                          if (plan.eCoins > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B3554),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Get Assured ${plan.eCoins} E-Coins',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Row 2: Validity | Data | Benefit images
                      _buildInfoRow(context, plan),
                      const SizedBox(height: 14),
                      // Description
                      Text(
                        plan.description.isEmpty
                            ? 'No description available.'
                            : plan.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary.withOpacity(0.7),
                              height: 1.4,
                              fontSize: 13,
                            ),
                      ),
                      const SizedBox(height: 18),
                      // Category name + Change Plan row
                      Row(
                        children: [
                          if (state.selectedCategory.isNotEmpty)
                            Text(
                              state.selectedCategory,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                            ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => controller.deselectPlan(),
                            icon: const Icon(
                              Icons.sync,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text('Change Plan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B3554),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Proceed To Pay button
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.isRecharging
                  ? null
                  : () => KDialog.instance.openSheet(
                        dialog: PrepaidPaymentBottomSheet(
                          amount: plan.amount,
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: state.isRecharging
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: SpinKitCircle(
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : Text(
                      'Proceed To Pay',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, PlanItem plan) {
    final hasValidity = plan.validity.isNotEmpty;
    final hasData = plan.data.isNotEmpty;
    final hasBenefitImages = plan.benefitImages.isNotEmpty;

    if (!hasValidity && !hasData && !hasBenefitImages) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (hasValidity)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Validity',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.5),
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                plan.validity,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        if (hasValidity && hasData)
          Container(
            width: 1,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.grey.shade300,
          ),
        if (hasData)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.5),
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                plan.data,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        if ((hasValidity || hasData) && hasBenefitImages) const Spacer(),
        if (hasBenefitImages) _buildBenefitImages(context, plan),
      ],
    );
  }

  Widget _buildBenefitImages(BuildContext context, PlanItem plan) {
    const maxVisible = 3;
    final images = plan.benefitImages;
    final visibleImages = images.take(maxVisible).toList();
    final remaining = images.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: (visibleImages.length * 26.0) + 10,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < visibleImages.length; i++)
                Positioned(
                  left: i * 26.0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        visibleImages[i],
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (remaining > 0)
          Text(
            '+$remaining',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
          ),
      ],
    );
  }
}

class _QuickActionHeaderCard extends StatelessWidget {
  const _QuickActionHeaderCard({
    required this.mobileNumber,
    required this.operatorName,
    required this.circleName,
    required this.operatorIconUrl,
    required this.onChange,
  });

  final String mobileNumber;
  final String? operatorName;
  final String? circleName;
  final String? operatorIconUrl;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final operator = operatorName ?? 'Operator';
    final circle = circleName ?? 'Circle';
    final iconUrl = (operatorIconUrl ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12.w, top: 8.h, bottom: 8.h),
            child: CircleAvatar(
              radius: 26.r,
              backgroundColor: AppColors.primary.withOpacity(0.12),
              child: iconUrl.isNotEmpty
                  ? _OperatorIcon(url: iconUrl)
                  : Text(
                      operator.isNotEmpty ? operator[0].toUpperCase() : 'S',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+91 $mobileNumber',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 13.sp,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$operator • $circle',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.65),
                          fontSize: 11.sp,
                        ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: onChange,
            child: SizedBox(
              width: 88.w,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onChange,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        FileConstants.quickAction,
                        fit: BoxFit.fill,
                      ),
                      Center(
                        child: Text(
                          'Change',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    fontSize: 11.sp,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperatorIcon extends StatelessWidget {
  // ignore: unused_element_parameter
  const _OperatorIcon({required this.url, this.size = 34});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isSvg = url.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return SvgPicture.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: null,
        placeholderBuilder: (_) => _fallbackPlaceholder(context),
      );
    }
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallbackPlaceholder(context),
    );
  }

  Widget _fallbackPlaceholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.primary.withOpacity(0.08),
      child: Icon(
        Icons.wifi_calling_3_outlined,
        color: AppColors.primary.withOpacity(0.6),
        size: 24,
      ),
    );
  }
}

Future<void> _openOperatorSheet(
  WidgetRef ref, {
  required String mobile,
  required Future<void> Function(OperatorOption operator, RegionOption region)
      onSelected,
}) async {
  final metaController = ref.read(prepaidMetaControllerProvider.notifier);
  KDialog.instance.openDialog(
    dialog: const ScreenWrapper(
      isFetching: true,
      isEmpty: false,
      emptyMessage: '',
      child: SizedBox.shrink(),
    ),
    barrierDismissible: false,
  );
  await metaController.loadOperatorsIfNeeded();
  if (navigatorKey.currentContext != null) {
    Navigator.of(navigatorKey.currentContext!).pop();
  }
  KDialog.instance.openConstraintsSheet(
    dialog: _OperatorSelectSheet(
      onSelected: (operator) async {
        KDialog.instance.openDialog(
          dialog: const ScreenWrapper(
            isFetching: true,
            isEmpty: false,
            emptyMessage: '',
            child: SizedBox.shrink(),
          ),
          barrierDismissible: false,
        );
        await metaController.loadRegionsIfNeeded();
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).pop();
        }
        KDialog.instance.openConstraintsSheet(
          dialog: _RegionSelectSheet(
            onSelected: (region) async {
              if (mobile.trim().isEmpty) return;
              await onSelected(operator, region);
            },
          ),
          maxHeight:
              MediaQuery.of(navigatorKey.currentContext!).size.height * 0.65,
        );
      },
    ),
    maxHeight: MediaQuery.of(navigatorKey.currentContext!).size.height * 0.6,
  );
}

class _OperatorSelectSheet extends ConsumerWidget {
  const _OperatorSelectSheet({required this.onSelected});

  final ValueChanged<OperatorOption> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(prepaidMetaControllerProvider);
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Operator',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Divider(color: AppColors.lightBorder.withOpacity(0.7)),
          if (meta.isLoadingOperators)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: SpinKitCircle(
                color: AppColors.primary,
                size: 48,
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: meta.operators.length,
                separatorBuilder: (_, __) => Divider(
                  color: AppColors.lightBorder.withOpacity(0.7),
                  height: 1,
                ),
                itemBuilder: (_, index) {
                  final item = meta.operators[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelected(item);
                    },
                    leading: _OperatorLogo(iconUrl: item.iconUrl),
                    title: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RegionSelectSheet extends ConsumerStatefulWidget {
  const _RegionSelectSheet({required this.onSelected});

  final ValueChanged<RegionOption> onSelected;

  @override
  ConsumerState<_RegionSelectSheet> createState() => _RegionSelectSheetState();
}

class _RegionSelectSheetState extends ConsumerState<_RegionSelectSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(prepaidMetaControllerProvider);
    final query = _searchController.text.trim().toLowerCase();
    final regions = query.isEmpty
        ? meta.regions
        : meta.regions
            .where((r) => r.name.toLowerCase().contains(query))
            .toList();

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Your Circle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Divider(color: AppColors.lightBorder.withOpacity(0.7)),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search region',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            ),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 8.h),
          if (meta.isLoadingRegions)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: SpinKitCircle(
                color: AppColors.primary,
                size: 48,
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: regions.length,
                separatorBuilder: (_, __) => Divider(
                  color: AppColors.lightBorder.withOpacity(0.7),
                  height: 1,
                ),
                itemBuilder: (_, index) {
                  final item = regions[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onSelected(item);
                    },
                    title: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _OperatorLogo extends StatelessWidget {
  const _OperatorLogo({required this.iconUrl});

  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    if (iconUrl.isEmpty) {
      return CircleAvatar(
        radius: 20.r,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.sim_card, color: AppColors.primary),
      );
    }
    final isSvg = iconUrl.toLowerCase().endsWith('.svg');
    return CircleAvatar(
      radius: 20.r,
      backgroundColor: Colors.white,
      child: isSvg
          ? SvgPicture.network(
              iconUrl,
              width: 24.r,
              height: 24.r,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => _logoPlaceholder(),
            )
          : Image.network(
              iconUrl,
              width: 24.r,
              height: 24.r,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _logoPlaceholder(),
            ),
    );
  }

  Widget _logoPlaceholder() {
    return Icon(
      Icons.sim_card,
      size: 20.r,
      color: AppColors.primary,
    );
  }
}

class _PermissionEmptyState extends StatelessWidget {
  const _PermissionEmptyState({required this.onAllow});

  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.phone_in_talk_outlined,
              color: AppColors.primary,
              size: 64,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Recharging Is Easier When You',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Provide Access To Contacts',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onAllow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Allow Contact Access',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactsList extends StatelessWidget {
  const _ContactsList({required this.contacts, required this.onSelect});

  final List<Contact> contacts;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final phone =
            contact.phones.isNotEmpty ? contact.phones.first.number : '';
        final initials = contact.displayName.isNotEmpty
            ? contact.displayName
                .trim()
                .split(' ')
                .map((e) => e[0])
                .take(2)
                .join()
            : '';
        return InkWell(
          onTap: phone.isEmpty ? null : () => onSelect(_normalizeMobile(phone)),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.gradientStart.withOpacity(0.35),
                  child: Text(
                    initials.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone.isEmpty ? 'No number' : phone,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                if (phone.isNotEmpty)
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textPrimary.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuggestedPlanCards extends StatelessWidget {
  const _SuggestedPlanCards({
    required this.plans,
    required this.onSelect,
  });

  final List<PlanItem> plans;
  final ValueChanged<PlanItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final displayPlans = plans.take(5).toList();
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayPlans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final plan = displayPlans[index];
          return _SuggestedPlanCard(
            plan: plan,
            onTap: () => onSelect(plan),
          );
        },
      ),
    );
  }
}

class _SuggestedPlanCard extends StatelessWidget {
  const _SuggestedPlanCard({
    required this.plan,
    required this.onTap,
  });

  final PlanItem plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 70, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹ ${plan.amount}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.planName.isNotEmpty ? plan.planName : 'Data Pack',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      plan.description.isEmpty
                          ? 'No description available.'
                          : plan.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.6),
                            height: 1.4,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Orange circle arrow on the right
            Positioned(
              right: -6,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(
                      color: AppColors.gradientStart,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 28),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category == selected;
          return GestureDetector(
            onTap: () => onSelected(category),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textPrimary.withOpacity(0.5),
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.textPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.plans,
    required this.selectedPlan,
    required this.onSelect,
  });

  final List<PlanItem> plans;
  final PlanItem? selectedPlan;
  final ValueChanged<PlanItem> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final plan = plans[index];
        return PlanCard(
          plan: plan,
          isSelected: selectedPlan == plan,
          onTap: () => onSelect(plan),
        );
      },
    );
  }
}

class _EmptyPlansState extends StatelessWidget {
  const _EmptyPlansState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          query.isEmpty
              ? 'No plans available for this category.'
              : 'No plans match "$query".',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary.withOpacity(0.6),
              ),
        ),
      ),
    );
  }
}
