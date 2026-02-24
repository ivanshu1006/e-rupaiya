import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/logger_service.dart';
import '../models/spin_options_state.dart';
import '../repositories/spin_repository.dart';

final spinRepositoryProvider = Provider<SpinRepository>(
  (ref) => SpinRepository(),
);

final spinOptionsControllerProvider =
    StateNotifierProvider<SpinOptionsController, SpinOptionsState>(
  (ref) => SpinOptionsController(
    repository: ref.watch(spinRepositoryProvider),
  ),
);

class SpinOptionsController extends StateNotifier<SpinOptionsState> {
  SpinOptionsController({required SpinRepository repository})
      : _repository = repository,
        super(const SpinOptionsState());

  final SpinRepository _repository;

  Future<void> fetchSpinOptions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final options = await _repository.fetchSpinOptions();
      state = state.copyWith(
        isLoading: false,
        options: options,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch spin options',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load spin options.',
      );
    }
  }
}
