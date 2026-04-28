import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repositories/support_ticket_repository.dart';

class SupportTicketState {
  const SupportTicketState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  SupportTicketState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return SupportTicketState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final supportTicketRepositoryProvider = Provider<SupportTicketRepository>(
  (ref) => SupportTicketRepository(),
);

final supportTicketControllerProvider =
    StateNotifierProvider<SupportTicketController, SupportTicketState>(
  (ref) => SupportTicketController(
    repository: ref.watch(supportTicketRepositoryProvider),
  ),
);

class SupportTicketController extends StateNotifier<SupportTicketState> {
  SupportTicketController({required SupportTicketRepository repository})
      : _repository = repository,
        super(const SupportTicketState());

  final SupportTicketRepository _repository;

  Future<bool> submit({
    required String transactionId,
    required String service,
    required String issueType,
    required bool isTransactionRelated,
    required String description,
    File? screenshot,
  }) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final ok = await _repository.createTicket(
        transactionId: transactionId,
        service: service,
        issueType: issueType,
        isTransactionRelated: isTransactionRelated,
        description: description,
        screenshot: screenshot,
      );
      state = state.copyWith(isSubmitting: false, isSuccess: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create ticket. Please try again.',
      );
      return false;
    }
  }
}

