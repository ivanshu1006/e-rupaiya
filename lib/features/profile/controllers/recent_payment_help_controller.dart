import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/support_faq_item.dart';
import '../repositories/support_faq_repository.dart';

class RecentPaymentHelpState {
  const RecentPaymentHelpState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<SupportFaqItem> items;
  final String? errorMessage;

  RecentPaymentHelpState copyWith({
    bool? isLoading,
    List<SupportFaqItem>? items,
    String? errorMessage,
  }) {
    return RecentPaymentHelpState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

final supportFaqRepositoryProvider = Provider<SupportFaqRepository>(
  (ref) => SupportFaqRepository(),
);

final recentPaymentHelpControllerProvider = StateNotifierProvider.family<
    RecentPaymentHelpController, RecentPaymentHelpState, String>(
  (ref, category) => RecentPaymentHelpController(
    repository: ref.watch(supportFaqRepositoryProvider),
    category: category,
  )..fetch(),
);

class RecentPaymentHelpController extends StateNotifier<RecentPaymentHelpState> {
  RecentPaymentHelpController({
    required SupportFaqRepository repository,
    required String category,
  })  : _repository = repository,
        _category = category,
        super(const RecentPaymentHelpState());

  final SupportFaqRepository _repository;
  final String _category;

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.fetchFaqs(category: _category);
      state = state.copyWith(isLoading: false, items: items);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load FAQs. Please try again.',
      );
    }
  }
}

