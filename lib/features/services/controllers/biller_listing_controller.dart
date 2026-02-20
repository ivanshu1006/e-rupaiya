import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/logger_service.dart';
import '../models/biller_listing_state.dart';
import '../repositories/biller_repository.dart';

final billerRepositoryProvider = Provider<BillerRepository>(
  (ref) => BillerRepository(),
);

final billerListingControllerProvider =
    StateNotifierProvider<BillerListingController, BillerListingState>(
  (ref) => BillerListingController(
    repository: ref.watch(billerRepositoryProvider),
  ),
);

class BillerListingController extends StateNotifier<BillerListingState> {
  BillerListingController({required BillerRepository repository})
      : _repository = repository,
        super(const BillerListingState());

  final BillerRepository _repository;

  Future<void> fetchBillers({required String categoryName}) async {
    state = state.copyWith(isFetching: true, errorMessage: null);
    try {
      final billers =
          await _repository.fetchBillers(categoryName: categoryName);
      state = state.copyWith(
        isFetching: false,
        billers: billers,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch billers',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetching: false,
        errorMessage: 'Failed to fetch providers. Please try again.',
      );
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
