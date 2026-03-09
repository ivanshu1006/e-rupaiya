import 'biller_model.dart';

class BillerDetailArgs {
  const BillerDetailArgs({
    required this.biller,
    this.isCreditCard = false,
    this.paymentType,
  });

  final Biller biller;
  final bool isCreditCard;
  final String? paymentType;
}
