import 'package:flutter_screenutil/flutter_screenutil.dart';

class SizeConstants {
  // Screen Padding
  static double get smScreenPadding => 8.0.w;
  static double get mdScreenPadding => 16.0.w;

  // Section Padding
  static double get smSectionPadding => 8.0.h;
  static double get mdSectionPadding => 16.0.h;

  // Item Spacings
  static double get smBetweenItemsSpacing => 8.0.w;
  static double get mdBetweenItemsSpacing => 16.0.w;

  // Radius
  static double get smBorderRadius => 8.0.r;
  static double get mdBorderRadius => 16.0.r;

  // Additional responsive sizing methods
  static double responsiveWidth(double width) => width.w;
  static double responsiveHeight(double height) => height.h;
  static double responsiveRadius(double radius) => radius.r;
  static double responsiveSp(double fontSize) => fontSize.sp;

  // Adaptive spacing methods
  static double adaptiveWidth(double width) => width.w;
  static double adaptiveHeight(double height) => height.h;
}

