import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/transaction_history_entry.dart';
import '../repositories/transaction_history_repository.dart';

class TransactionHistoryState {
  const TransactionHistoryState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
    this.selectedDays = 30,
    this.selectedLastYears,
    this.selectedRange,
  });

  final bool isLoading;
  final List<TransactionHistoryEntry> items;
  final String? errorMessage;
  final int selectedDays;
  final int? selectedLastYears;
  final DateTimeRange? selectedRange;

  TransactionHistoryState copyWith({
    bool? isLoading,
    List<TransactionHistoryEntry>? items,
    String? errorMessage,
    int? selectedDays,
    int? selectedLastYears,
    DateTimeRange? selectedRange,
  }) {
    return TransactionHistoryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
      selectedDays: selectedDays ?? this.selectedDays,
      selectedLastYears: selectedLastYears ?? this.selectedLastYears,
      selectedRange: selectedRange,
    );
  }
}

final transactionHistoryRepositoryProvider =
    Provider<TransactionHistoryRepository>(
  (ref) => TransactionHistoryRepository(),
);

final transactionHistoryControllerProvider =
    StateNotifierProvider<TransactionHistoryController, TransactionHistoryState>(
  (ref) => TransactionHistoryController(
    repository: ref.watch(transactionHistoryRepositoryProvider),
  ),
);

class TransactionHistoryController
    extends StateNotifier<TransactionHistoryState> {
  TransactionHistoryController({required TransactionHistoryRepository repository})
      : _repository = repository,
        super(const TransactionHistoryState());

  final TransactionHistoryRepository _repository;

  Future<void> fetchHistory({
    int? days,
    DateTimeRange? range,
    int? lastYears,
  }) async {
    final resolvedDays = days ?? state.selectedDays;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.fetchHistory(
        days: lastYears == null && range == null ? resolvedDays : null,
        fromDate: range?.start,
        toDate: range?.end,
        lastYears: lastYears,
      );
      state = state.copyWith(
        isLoading: false,
        items: items,
        selectedDays: resolvedDays,
        selectedLastYears: lastYears,
        selectedRange: range,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load transactions. Please try again.',
      );
    }
  }

  Future<void> applyDaysFilter(int days) async {
    await fetchHistory(days: days, range: null, lastYears: null);
  }

  Future<void> applyDateRange(DateTimeRange range) async {
    await fetchHistory(range: range, lastYears: null);
  }

  Future<void> applyLastYears(int years) async {
    await fetchHistory(lastYears: years, range: null);
  }
}
