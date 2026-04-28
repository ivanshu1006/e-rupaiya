import 'operator_info.dart';
import 'plan_item.dart';

class MobilePrepaidState {
  const MobilePrepaidState({
    this.isFetching = false,
    this.isRecharging = false,
    this.mobile = '',
    this.operatorInfo,
    this.plansByCategory = const {},
    this.selectedCategory = '',
    this.planSearchQuery = '',
    this.selectedPlan,
    this.errorMessage,
    this.rechargeMessage,
    this.rechargeStatus,
    this.rechargeTransactionId,
    this.rechargeDateTime,
  });

  final bool isFetching;
  final bool isRecharging;
  final String mobile;
  final OperatorInfo? operatorInfo;
  final Map<String, List<PlanItem>> plansByCategory;
  final String selectedCategory;
  final String planSearchQuery;
  final PlanItem? selectedPlan;
  final String? errorMessage;
  final String? rechargeMessage;
  final String? rechargeStatus;
  final String? rechargeTransactionId;
  final String? rechargeDateTime;

  List<String> get categories => plansByCategory.keys.toList();

  List<PlanItem> get currentPlans =>
      plansByCategory[selectedCategory] ?? const <PlanItem>[];

  List<PlanItem> get filteredPlans {
    if (planSearchQuery.isEmpty) return currentPlans;
    final query = planSearchQuery.toLowerCase();
    return currentPlans.where((plan) {
      return plan.amount.toString().contains(query) ||
          plan.validity.toLowerCase().contains(query) ||
          plan.description.toLowerCase().contains(query);
    }).toList();
  }

  static const _sentinel = Object();

  MobilePrepaidState copyWith({
    bool? isFetching,
    bool? isRecharging,
    String? mobile,
    OperatorInfo? operatorInfo,
    Map<String, List<PlanItem>>? plansByCategory,
    String? selectedCategory,
    String? planSearchQuery,
    PlanItem? selectedPlan,
    Object? errorMessage = _sentinel,
    Object? rechargeMessage = _sentinel,
    Object? rechargeStatus = _sentinel,
    Object? rechargeTransactionId = _sentinel,
    Object? rechargeDateTime = _sentinel,
  }) {
    return MobilePrepaidState(
      isFetching: isFetching ?? this.isFetching,
      isRecharging: isRecharging ?? this.isRecharging,
      mobile: mobile ?? this.mobile,
      operatorInfo: operatorInfo ?? this.operatorInfo,
      plansByCategory: plansByCategory ?? this.plansByCategory,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      planSearchQuery: planSearchQuery ?? this.planSearchQuery,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      rechargeMessage: rechargeMessage == _sentinel
          ? this.rechargeMessage
          : rechargeMessage as String?,
      rechargeStatus: rechargeStatus == _sentinel
          ? this.rechargeStatus
          : rechargeStatus as String?,
      rechargeTransactionId: rechargeTransactionId == _sentinel
          ? this.rechargeTransactionId
          : rechargeTransactionId as String?,
      rechargeDateTime: rechargeDateTime == _sentinel
          ? this.rechargeDateTime
          : rechargeDateTime as String?,
    );
  }
}
