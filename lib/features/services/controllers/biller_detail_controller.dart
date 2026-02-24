import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../services/logger_service.dart';
import '../models/bill_pay_response_model.dart';
import '../models/biller_detail_state.dart';
import '../models/biller_model.dart';
import '../repositories/biller_repository.dart';

final billerDetailControllerProvider =
    StateNotifierProvider<BillerDetailController, BillerDetailState>(
  (ref) => BillerDetailController(
    repository: ref.watch(
      Provider<BillerRepository>((ref) => BillerRepository()),
    ),
  ),
);

class BillerDetailController extends StateNotifier<BillerDetailState> {
  BillerDetailController({required BillerRepository repository})
      : _repository = repository,
        super(const BillerDetailState());

  final BillerRepository _repository;

  void selectBiller(Biller biller) {
    state = const BillerDetailState().copyWith(selectedBiller: biller);
    _fetchBillerDetail(biller.billerId);
  }

  Future<void> _fetchBillerDetail(String billerId) async {
    state = state.copyWith(isFetchingDetail: true, errorMessage: null);
    try {
      final detail = await _repository.fetchBillerDetails(billerId: billerId);
      state = state.copyWith(
        isFetchingDetail: false,
        billerDetail: detail,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch biller detail',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetchingDetail: false,
        errorMessage: 'Failed to fetch provider details.',
      );
    }
  }

  Future<void> fetchBill({
    required Map<String, String> customerParams,
  }) async {
    final biller = state.selectedBiller;
    final detail = state.billerDetail;
    if (biller == null || detail == null) return;

    state = state.copyWith(
      isFetchingBill: true,
      errorMessage: null,
      customerParamsInput: customerParams,
    );
    try {
      final bill = await _repository.fetchBill(
        billerId: biller.billerId,
        customerParams: customerParams,
        planMdmRequirement: detail.planMdmRequirement.isNotEmpty
            ? detail.planMdmRequirement
            : 'NOT_SUPPORTED',
      );
      state = state.copyWith(
        isFetchingBill: false,
        billResponse: bill,
        errorMessage: null,
      );
    } on BillerApiException catch (e, stackTrace) {
      logger.error(
        'Failed to fetch bill',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetchingBill: false,
        errorMessage: e.message,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch bill',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isFetchingBill: false,
        errorMessage: 'Failed to fetch bill. Please try again.',
      );
    }
  }

  Future<bool> payBill({
    required double amount,
    String? refIdOverride,
  }) async {
    final biller = state.selectedBiller;
    final detail = state.billerDetail;
    final bill = state.billResponse;
    final customerParams = state.customerParamsInput ?? {};
    if (biller == null || detail == null || bill == null) return false;

    state = state.copyWith(
      isPayingBill: true,
      payErrorMessage: null,
      payResponse: null,
    );
    try {
      final response = await _repository.payBill(
        billerId: biller.billerId,
        customerParams: customerParams,
        amount: amount.toStringAsFixed(2),
        refId: refIdOverride ?? bill.refId,
        paymentModes: detail.paymentModes
            .map((mode) => mode.paymentMode)
            .where((mode) => mode.trim().isNotEmpty)
            .toList(),
      );
      final errorMessage =
          response.isSuccess ? null : _resolvePayErrorMessage(response);
      state = state.copyWith(
        isPayingBill: false,
        payResponse: response,
        payErrorMessage: errorMessage,
      );
      return response.isSuccess;
    } catch (e, stackTrace) {
      logger.error(
        'Failed to pay bill',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isPayingBill: false,
        payErrorMessage: 'Failed to pay bill. Please try again.',
      );
      return false;
    }
  }

  void toggleFullDetails() {
    state = state.copyWith(showFullDetails: !state.showFullDetails);
  }

  void reset() {
    state = const BillerDetailState();
  }

  String _resolvePayErrorMessage(BillPayResponse response) {
    final raw = response.message.trim();
    if (raw.isEmpty || RegExp(r'^\d{3}$').hasMatch(raw)) {
      return _fallbackMessageForCode(response.code);
    }
    return raw;
  }

  String _fallbackMessageForCode(int code) {
    switch (code) {
      case 400:
        return 'Payment request was invalid. Please verify the details.';
      case 401:
      case 403:
        return 'You are not authorized to complete this payment.';
      case 404:
        return 'Payment service is unavailable. Please try again shortly.';
      case 500:
        return 'Payment Failed due to server error. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Payment service is down. Please try again later.';
      default:
        return 'Payment failed. Please try again.';
    }
  }
}
