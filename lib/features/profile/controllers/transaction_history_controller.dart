import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/transaction_history_entry.dart';
import '../models/transaction_history_filter.dart';
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

  static const _sentinel = Object();

  TransactionHistoryState copyWith({
    bool? isLoading,
    List<TransactionHistoryEntry>? items,
    String? errorMessage,
    int? selectedDays,
    Object? selectedLastYears = _sentinel,
    Object? selectedRange = _sentinel,
  }) {
    return TransactionHistoryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
      selectedDays: selectedDays ?? this.selectedDays,
      selectedLastYears: selectedLastYears == _sentinel
          ? this.selectedLastYears
          : selectedLastYears as int?,
      selectedRange: selectedRange == _sentinel
          ? this.selectedRange
          : selectedRange as DateTimeRange?,
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
    TransactionHistoryFilter? filter,
  }) async {
    final resolvedDays = days ?? state.selectedDays;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.fetchHistory(
        days: filter == null && lastYears == null && range == null
            ? resolvedDays
            : null,
        fromDate: filter?.fromDate ?? range?.start,
        toDate: filter?.toDate ?? range?.end,
        lastYears: lastYears,
        month: filter?.month,
        status: filter?.status,
        service: filter?.service,
        paymentType: filter?.paymentType,
        minAmount: filter?.minAmount,
        maxAmount: filter?.maxAmount,
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

  Future<void> applyFilter(TransactionHistoryFilter filter) async {
    await fetchHistory(filter: filter, range: null, lastYears: null);
  }
}
