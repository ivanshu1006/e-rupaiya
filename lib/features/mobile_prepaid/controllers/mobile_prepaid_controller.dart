import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/logger_service.dart';
import '../models/mobile_prepaid_state.dart';
import '../models/plan_item.dart';
import '../repositories/mobile_prepaid_repository.dart';

final mobilePrepaidRepositoryProvider = Provider<MobilePrepaidRepository>(
  (ref) => MobilePrepaidRepository(),
);

final mobilePrepaidControllerProvider =
    StateNotifierProvider<MobilePrepaidController, MobilePrepaidState>(
  (ref) => MobilePrepaidController(
    repository: ref.watch(mobilePrepaidRepositoryProvider),
  ),
);

class MobilePrepaidController extends StateNotifier<MobilePrepaidState> {
  MobilePrepaidController({required MobilePrepaidRepository repository})
      : _repository = repository,
        super(const MobilePrepaidState());

  final MobilePrepaidRepository _repository;

  void reset() {
    state = const MobilePrepaidState();
  }

  void updatePlanSearch(String query) {
    state = state.copyWith(planSearchQuery: query);
  }

  void selectCategory(String category) {
    state = state.copyWith(
      selectedCategory: category,
      selectedPlan: null,
    );
  }

  void selectPlan(PlanItem plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  void deselectPlan() {
    state = MobilePrepaidState(
      mobile: state.mobile,
      operatorInfo: state.operatorInfo,
      plansByCategory: state.plansByCategory,
      selectedCategory: state.selectedCategory,
      planSearchQuery: state.planSearchQuery,
    );
  }

  Future<void> fetchOperatorAndPlans(String mobileInput) async {
    final mobile = _sanitizeMobile(mobileInput);
    if (mobile.length < 10) {
      state = state.copyWith(
        errorMessage: 'Please enter a valid 10 digit mobile number.',
      );
      return;
    }
    state = state.copyWith(
      isFetching: true,
      errorMessage: null,
      rechargeMessage: null,
      mobile: mobile,
      operatorInfo: null,
      plansByCategory: const {},
      selectedCategory: '',
      selectedPlan: null,
      planSearchQuery: '',
    );
    try {
      final operatorInfo = await _repository.checkOperator(mobile: mobile);
      final plans = await _repository.fetchPlans(
        mobile: mobile,
        operatorName: operatorInfo.operatorName,
        circleCode: operatorInfo.circleCode,
      );
      final categories = plans.keys.toList();
      state = state.copyWith(
        isFetching: false,
        operatorInfo: operatorInfo,
        plansByCategory: plans,
        selectedCategory: categories.isNotEmpty ? categories.first : '',
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to load operator/plans',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetching: false,
        errorMessage: 'Failed to fetch plans. Please try again.',
      );
    }
  }

  Future<void> recharge({String? referenceId}) async {
    if (state.operatorInfo == null ||
        state.selectedPlan == null ||
        state.mobile.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please select a plan before proceeding.',
      );
      return;
    }

    state = state.copyWith(
      isRecharging: true,
      errorMessage: null,
      rechargeMessage: null,
    );
    try {
      final message = await _repository.recharge(
        mobile: state.mobile,
        amount: state.selectedPlan!.amount,
        operatorName: state.operatorInfo!.operatorName,
        referenceId: referenceId,
      );
      state = state.copyWith(
        isRecharging: false,
        rechargeMessage: message,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to recharge',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isRecharging: false,
        errorMessage: _errorMessageFromException(e),
      );
    }
  }

  String _sanitizeMobile(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }

  String _errorMessageFromException(Object error) {
    final raw = error.toString().trim();
    if (raw.isEmpty) {
      return 'Recharge failed. Please try again.';
    }
    if (raw.startsWith('Exception:')) {
      final message = raw.replaceFirst('Exception:', '').trim();
      if (message.isNotEmpty && !RegExp(r'^\d{3}$').hasMatch(message)) {
        return message;
      }
    }
    // If the message is just a status code, return a user-friendly fallback
    return 'Recharge failed. Please try again.';
  }
}
