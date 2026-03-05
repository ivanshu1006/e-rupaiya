import 'package:e_rupaiya/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/logger_service.dart';
import '../models/home_state.dart';
import '../repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepository(),
);

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(
    repository: ref.watch(homeRepositoryProvider),
  ),
);

class HomeController extends StateNotifier<HomeState> {
  HomeController({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState());

  final HomeRepository _repository;

  Future<void> fetchQuickActions() async {
    state = state.copyWith(isFetching: true, errorMessage: null);
    try {
      final data = await _repository.fetchQuickActions();
      state = state.copyWith(
        isFetching: false,
        quickActions: data,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch quick actions',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetching: false,
        errorMessage: 'Failed to fetch services. Please try again.',
      );
    }
  }

  Future<void> fetchAllQuickActions() async {
    state = state.copyWith(isFetching: true, errorMessage: null);
    try {
      final userId = await Utils.getUserId() ?? '';
      final data = await _repository.fetchAllQuickAction(userId);
      state = state.copyWith(
        isFetching: false,
        allQuickActions: data.data,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch all quick actions',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetching: false,
        errorMessage: 'Failed to fetch services. Please try again.',
      );
    }
  }

  Future<void> fetchCreditCardActions() async {
    state = state.copyWith(
      isFetchingCreditCards: true,
      creditCardActions: null,
    );
    try {
      final userId = await Utils.getUserId() ?? '';
      final data = await _repository.fetchCreditCardActions(userId);
      state = state.copyWith(
        isFetchingCreditCards: false,
        creditCardActions: data,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch credit card actions',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetchingCreditCards: false,
        creditCardActions: [],
      );
    }
  }

  Future<void> fetchRechargeActions() async {
    state = state.copyWith(
      isFetchingRecharge: true,
      rechargeActions: null,
    );
    try {
      final userId = await Utils.getUserId() ?? '';
      final data = await _repository.fetchRechargeActions(userId);
      state = state.copyWith(
        isFetchingRecharge: false,
        rechargeActions: data,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch recharge actions',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetchingRecharge: false,
        rechargeActions: [],
      );
    }
  }
}
