import 'package:flutter/material.dart';

enum DigitalMetal { gold, silver }

enum GoldTradeMode { buy, sell }

class DigitalMetalTheme {
  const DigitalMetalTheme({
    required this.metal,
    required this.label,
    required this.buyTitle,
    required this.sellTitle,
    required this.lockerTitle,
    required this.balanceLabel,
    required this.providerSubtitle,
    required this.buyGradient,
    required this.balanceCardColor,
    required this.buyCardColor,
    required this.valueCardGradient,
    required this.pageBackground,
    required this.currentValueBadge,
    required this.quickChipGradient,
    required this.toggleActiveColor,
    required this.successTitleColor,
    required this.successAccentColor,
    required this.successButtonGradient,
    required this.taxBadgeColor,
    required this.designTopTint,
  });

  final DigitalMetal metal;
  final String label;
  final String buyTitle;
  final String sellTitle;
  final String lockerTitle;
  final String balanceLabel;
  final String providerSubtitle;
  final LinearGradient buyGradient;
  final Color balanceCardColor;
  final Color buyCardColor;
  final LinearGradient valueCardGradient;
  final Color pageBackground;
  final Color currentValueBadge;
  final LinearGradient quickChipGradient;
  final Color toggleActiveColor;
  final Color successTitleColor;
  final Color successAccentColor;
  final LinearGradient successButtonGradient;
  final Color taxBadgeColor;
  final Color designTopTint;

  static DigitalMetalTheme of(DigitalMetal metal) {
    switch (metal) {
      case DigitalMetal.silver:
        return const DigitalMetalTheme(
          metal: DigitalMetal.silver,
          label: 'Silver',
          buyTitle: 'Silver Buy',
          sellTitle: 'Silver Sell',
          lockerTitle: 'Silver Locker',
          balanceLabel: 'My Silver',
          providerSubtitle: '99.99% Pure 24K Silver',
          buyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F0F0),
              Color(0xFFFFFFFF),
            ],
          ),
          balanceCardColor: Color(0xFFB3B3B3),
          buyCardColor: Color(0xFFD6D6D6),
          valueCardGradient: LinearGradient(
            colors: [Color(0xFFF1F1F1), Color(0xFFE0E0E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          pageBackground: Color(0xFFF5F5F5),
          currentValueBadge: Color(0xFF9B9B9B),
          quickChipGradient: LinearGradient(
            colors: [Color(0xFFC2C2C2), Color(0xFF8F8F8F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          toggleActiveColor: Color(0xFF6B6B6B),
          successTitleColor: Color(0xFF4A4A4A),
          successAccentColor: Color(0xFF4A4A4A),
          successButtonGradient: LinearGradient(
            colors: [
              Color.fromRGBO(216, 216, 216, 0.9),
              Color.fromRGBO(131, 131, 131, 0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          taxBadgeColor: Color(0xFF7D7D7D),
          designTopTint: Color(0xFFA5A5A5),
        );
      case DigitalMetal.gold:
      default:
        return const DigitalMetalTheme(
          metal: DigitalMetal.gold,
          label: 'Gold',
          buyTitle: 'Gold Buy',
          sellTitle: 'Gold Sell',
          lockerTitle: 'Gold Locker',
          balanceLabel: 'My Gold',
          providerSubtitle: '99.99% Pure 24K Gold',
          buyGradient: LinearGradient(
            begin: Alignment(0, -0.02),
            end: Alignment(0, 1.03),
            colors: [
              Color(0xFFFED36B),
              Color(0x00FFFFFF),
            ],
          ),
          balanceCardColor: Color(0xFFC9A06F),
          buyCardColor: Color(0xFFD9B482),
          valueCardGradient: LinearGradient(
            colors: [Color(0xFFF6DFC2), Color(0xFFF0CFA8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          pageBackground: Color(0xFFFFF6EA),
          currentValueBadge: Color(0xFFB7773D),
          quickChipGradient: LinearGradient(
            colors: [Color(0xFFE0A65D), Color(0xFFB56F23)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          toggleActiveColor: Color(0xFFDD5428),
          successTitleColor: Color(0xFF8A4D18),
          successAccentColor: Color(0xFF8A4D18),
          successButtonGradient: LinearGradient(
            colors: [Color(0xFFFCC486), Color(0xFFFCC486)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          taxBadgeColor: Color(0xFFB7773D),
          designTopTint: Color(0xFFE1AB5F),
        );
    }
  }

  static DigitalMetal fromQuery(String? value) {
    if (value?.toLowerCase() == 'silver') return DigitalMetal.silver;
    return DigitalMetal.gold;
  }

  String get queryValue => metal == DigitalMetal.silver ? 'silver' : 'gold';
}
