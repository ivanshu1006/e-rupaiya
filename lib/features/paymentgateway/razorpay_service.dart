import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef RazorpaySuccessCallback = void Function(String paymentId);
typedef RazorpayFailureCallback = void Function(String message);
typedef RazorpayExternalWalletCallback = void Function(String walletName);

class RazorpayService {
  RazorpayService._();

  static final RazorpayService instance = RazorpayService._();

  Razorpay? _razorpay;

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }

  Future<void> openCheckout({
    required double amount,
    required String name,
    String? description,
    RazorpaySuccessCallback? onSuccess,
    RazorpayFailureCallback? onFailure,
    RazorpayExternalWalletCallback? onExternalWallet,
    Map<String, String>? prefill,
  }) async {
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: '.env');
    }

    final key = dotenv.env['RAZORPAY_KEY'] ?? '';
    if (key.isEmpty) {
      onFailure?.call('Razorpay key is missing.');
      return;
    }

    _razorpay?.clear();
    _razorpay = Razorpay();

    _razorpay!.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) {
        onSuccess?.call(response.paymentId ?? '');
      },
    );
    _razorpay!.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (PaymentFailureResponse response) {
        onFailure?.call(response.message ?? 'Payment failed.');
      },
    );
    _razorpay!.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (ExternalWalletResponse response) {
        onExternalWallet?.call(response.walletName ?? '');
      },
    );

    final options = <String, Object?>{
      'key': key,
      'amount': (amount * 100).round(),
      'name': name,
      if (description != null) 'description': description,
      if (prefill != null && prefill.isNotEmpty) 'prefill': prefill,
      'theme': {
        'color': '#F37021',
      },
    };

    _razorpay!.open(options);
  }
}
