import 'biller_model.dart';

class BillerDetailArgs {
  const BillerDetailArgs({
    required this.biller,
    this.isCreditCard = false,
  });

  final Biller biller;
  final bool isCreditCard;
}
