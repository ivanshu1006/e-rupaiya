import 'package:flutter/foundation.dart';

class DigitalGoldController extends ChangeNotifier {
  bool _isBuyingInRupees = true;

  bool get isBuyingInRupees => _isBuyingInRupees;

  void toggleUnit(bool buyInRupees) {
    if (_isBuyingInRupees == buyInRupees) return;
    _isBuyingInRupees = buyInRupees;
    notifyListeners();
  }
}
