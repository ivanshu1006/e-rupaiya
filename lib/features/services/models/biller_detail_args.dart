import 'biller_model.dart';

class BillerDetailArgs {
  const BillerDetailArgs({
    required this.biller,
    this.isCreditCard = false,
    this.paymentType,
    this.mobileNumber,
    this.cardLast4,
  });

  final Biller biller;
  final bool isCreditCard;
  final String? paymentType;
  final String? mobileNumber;
  final String? cardLast4;
}
