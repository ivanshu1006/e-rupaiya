import 'biller_model.dart';

class BillerListingState {
  const BillerListingState({
    this.isFetching = false,
    this.billers = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  final bool isFetching;
  final List<Biller> billers;
  final String searchQuery;
  final String? errorMessage;

  List<Biller> get filteredBillers {
    if (searchQuery.isEmpty) return billers;
    final query = searchQuery.toLowerCase();
    return billers
        .where((b) => b.billerName.toLowerCase().contains(query))
        .toList();
  }

  static const _sentinel = Object();

  BillerListingState copyWith({
    bool? isFetching,
    List<Biller>? billers,
    String? searchQuery,
    Object? errorMessage = _sentinel,
  }) {
    return BillerListingState(
      isFetching: isFetching ?? this.isFetching,
      billers: billers ?? this.billers,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
