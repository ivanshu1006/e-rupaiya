// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frappe_flutter_app/features/mobile_prepaid/models/mobile_prepaid_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/file_constants.dart';
import '../../../services/permission_service.dart';
import '../../../widgets/k_dialog.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/search_textfield.dart';
import '../components/payment_bottom_sheet.dart';
import '../components/plan_card.dart';
import '../controllers/mobile_prepaid_controller.dart';
import '../models/plan_item.dart';
import '../models/recharge_quick_action_payload.dart';

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
    final isContactsLoading = useState(false);
    final contacts = useState<List<Contact>>([]);
    final contactQuery = useState('');
    final contactSearchController = useTextEditingController();

    final manualMobileController = useTextEditingController();
    final planSearchController =
        useTextEditingController(text: state.planSearchQuery);

    final showPlans = state.mobile.isNotEmpty || state.operatorInfo != null;

    Future<void> loadContacts() async {
      isContactsLoading.value = true;
      try {
        final list = await FlutterContacts.getContacts(withProperties: true);
        contacts.value = list;
      } finally {
        isContactsLoading.value = false;
      }
    }

    useEffect(() {
      Future.microtask(() async {
        final granted = await permissionService.hasContactsPermission();
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
        final phone = quickActionPayload.phone.trim();
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
      hasPermission.value = granted;
      if (granted) {
        await loadContacts();
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

    final filteredContacts = contacts.value.where((c) {
      final name = c.displayName.toLowerCase();
      final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
      final q = contactQuery.value.toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();

    final hasPlanSelected = showPlans && state.selectedPlan != null;
    final showOperatorCard = showPlans || hasPlanSelected;

    void handleChange() {
      manualMobileController.clear();
      planSearchController.clear();
      controller.reset();
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
                onBack:
                    hasPlanSelected ? () => controller.deselectPlan() : null,
              ),
              if (showOperatorCard)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: -32,
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
          // Space for the overlapping card
          if (showOperatorCard) const SizedBox(height: 40),
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
                            isLoading: isContactsLoading.value,
                            contacts: filteredContacts,
                            contactSearchController: contactSearchController,
                            onQueryChange: (value) =>
                                contactQuery.value = value,
                            onReload: loadContacts,
                            onSelect: (mobile) {
                              controller.fetchOperatorAndPlans(mobile);
                            },
                            manualMobileController: manualMobileController,
                            onManualSubmit: () =>
                                controller.fetchOperatorAndPlans(
                                    manualMobileController.text),
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
          const Center(child: CircularProgressIndicator())
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
          const Center(child: CircularProgressIndicator())
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
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Proceed To Pay',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
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
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 14, bottom: 14),
            child: CircleAvatar(
              radius: 34,
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
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+91 $mobileNumber',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$operator • $circle',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.65),
                        ),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  FileConstants.quickAction,
                  height: 84,
                  fit: BoxFit.cover,
                ),
                TextButton(
                  onPressed: onChange,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  child: Text(
                    'Change',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
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

class _OperatorIcon extends StatelessWidget {
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

  Widget _rasterFallback(BuildContext context) {
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
          onTap: phone.isEmpty
              ? null
              : () => onSelect(phone.replaceAll(RegExp(r'\D'), '')),
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
