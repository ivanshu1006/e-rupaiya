import 'dart:io';

import 'package:e_rupaiya/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/logger_service.dart';
import '../../../widgets/app_snackbar.dart';
import '../repositories/referral_repository.dart';

class ReferralShareService {
  ReferralShareService._();

  static final ReferralRepository _repository = ReferralRepository();

  static Future<void> shareWhatsApp(BuildContext context) async {
    final text = await _resolveShareText(context);
    if (text == null) return;

    final url = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(text)}',
    );
    final launched = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      await Share.share(text);
    }
  }

  static Future<void> shareAny(BuildContext context) async {
    final text = await _resolveShareText(context);
    if (text == null) return;
    await Share.share(text);
  }

  static Future<void> shareSMS(
    BuildContext context, {
    String? phone,
  }) async {
    final text = await _resolveShareText(context);
    if (text == null) return;

    final uri = Uri.parse(
      'sms:${phone ?? ''}?body=${Uri.encodeComponent(text)}',
    );

    final launched = await launchUrl(uri);
    if (!launched) {
      AppSnackbar.show('Unable to open SMS');
    }
  }

  static Future<String?> _resolveShareText(BuildContext context) async {
    BuildContext? dialogContext = context;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: SpinKitCircle(
            color: AppColors.primary,
            size: 48,
          ),
        ),
      );
      final response = await _repository.generateLink();
      _hideLoading(dialogContext);
      if (!response.status || response.referralLink.isEmpty) {
        AppSnackbar.show('Failed to generate referral link.');
        return null;
      }
      final code = response.referralCode.trim();
      final link = response.referralLink.trim();
      final shareLink = _buildShareLink(link);
      if (code.isEmpty) {
        return 'Join me on E-Rupaiya: $shareLink';
      }
      return 'Join me on E-Rupaiya. Use my referral code $code: $shareLink';
    } catch (e, stackTrace) {
      _hideLoading(dialogContext);
      logger.error(
        'Referral share failed',
        error: e,
        stackTrace: stackTrace,
      );
      AppSnackbar.show('Failed to generate referral link.');
      return null;
    }
  }
}

void _hideLoading(BuildContext? dialogContext) {
  if (dialogContext == null) return;
  if (Navigator.of(dialogContext).canPop()) {
    Navigator.of(dialogContext).pop();
  }
}

String _buildShareLink(String link) {
  if (!Platform.isAndroid) return link;
  final uri = Uri.tryParse(link);
  if (uri == null) return link;
  if (uri.scheme != 'https' || uri.host != 'test.erupaiya.com') {
    return link;
  }
  const fallback =
      'https://play.google.com/store/apps/details?id=com.innoplix.erupiya';
  final fallbackEncoded = Uri.encodeComponent(fallback);
  return 'intent://${uri.host}${uri.path}'
      '?${uri.query}'
      '#Intent;scheme=https;package=com.innoplix.erupiya;'
      'S.browser_fallback_url=$fallbackEncoded;end';
}
