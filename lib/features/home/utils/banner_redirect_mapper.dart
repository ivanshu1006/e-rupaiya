import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/routes_constant.dart';

class BannerRedirectMapper {
  const BannerRedirectMapper._();

  static void handle(BuildContext context, String? redirectUrl) {
    final value = redirectUrl?.trim();
    if (value == null || value.isEmpty) return;

    switch (value) {
      case 'invite':
        context.push(RouteConstants.referAndEarn);
        return;
      case 'gold':
        context.push('${RouteConstants.digitalGold}?entry=explore');
        return;
    }
  }
}
