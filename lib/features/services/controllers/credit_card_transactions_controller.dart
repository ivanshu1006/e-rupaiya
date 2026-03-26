import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/credit_card_transaction.dart';
import '../repositories/credit_card_transactions_repository.dart';

final creditCardTransactionsRepositoryProvider =
    Provider<CreditCardTransactionsRepository>(
  (ref) => CreditCardTransactionsRepository(),
);

final creditCardTransactionsControllerProvider = StateNotifierProvider<
    CreditCardTransactionsController, CreditCardTransactionsState>(
  (ref) => CreditCardTransactionsController(
    repository: ref.watch(creditCardTransactionsRepositoryProvider),
  ),
);

class CreditCardTransactionsState {
  const CreditCardTransactionsState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalRecords = 0,
  });

  final bool isLoading;
  final List<CreditCardTransaction> items;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final int totalRecords;

  CreditCardTransactionsState copyWith({
    bool? isLoading,
    List<CreditCardTransaction>? items,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? totalRecords,
  }) {
    return CreditCardTransactionsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRecords: totalRecords ?? this.totalRecords,
    );
  }
}

class CreditCardTransactionsController
    extends StateNotifier<CreditCardTransactionsState> {
  CreditCardTransactionsController({required CreditCardTransactionsRepository repository})
      : _repository = repository,
        super(const CreditCardTransactionsState());

  final CreditCardTransactionsRepository _repository;

  Future<void> fetchTransactions({
    required String maskedIdentifier,
    int page = 1,
    int limit = 10,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _repository.fetchTransactions(
        maskedIdentifier: maskedIdentifier,
        page: page,
        limit: limit,
      );
      state = state.copyWith(
        isLoading: false,
        items: response.items,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        totalRecords: response.totalRecords,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch transactions. Please try again.',
      );
    }
  }
}
