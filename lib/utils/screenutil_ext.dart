import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ScreenUtilSpacing on num {
  SizedBox get hs => SizedBox(height: h);
  SizedBox get vs => SizedBox(width: w);
}
