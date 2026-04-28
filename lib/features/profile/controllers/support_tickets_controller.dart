import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/support_ticket.dart';
import '../repositories/support_tickets_repository.dart';

class SupportTicketsState {
  const SupportTicketsState({
    this.isLoading = false,
    this.errorMessage,
    this.tickets = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<SupportTicket> tickets;

  SupportTicketsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SupportTicket>? tickets,
  }) {
    return SupportTicketsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      tickets: tickets ?? this.tickets,
    );
  }
}

final supportTicketsRepositoryProvider = Provider<SupportTicketsRepository>(
  (ref) => SupportTicketsRepository(),
);

final supportTicketsControllerProvider =
    StateNotifierProvider<SupportTicketsController, SupportTicketsState>(
  (ref) => SupportTicketsController(
    repository: ref.watch(supportTicketsRepositoryProvider),
  ),
);

class SupportTicketsController extends StateNotifier<SupportTicketsState> {
  SupportTicketsController({required SupportTicketsRepository repository})
      : _repository = repository,
        super(const SupportTicketsState());

  final SupportTicketsRepository _repository;

  Future<void> fetchTickets() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tickets = await _repository.fetchTickets();
      state = state.copyWith(isLoading: false, tickets: tickets);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tickets. Please try again.',
      );
    }
  }
}
