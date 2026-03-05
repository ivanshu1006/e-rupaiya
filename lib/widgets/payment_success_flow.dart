// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/file_constants.dart';
import '../utils/screenutil_ext.dart';
import 'custom_elevated_button.dart';

class PaymentDetailItem {
  const PaymentDetailItem({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;
}

class PaymentThankYouScreen extends StatefulWidget {
  const PaymentThankYouScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.gifPath = 'assets/gif/success.gif',
    this.poweredByText = 'Powered by',
    this.poweredByLogo = '',
    this.autoNavigateAfter = const Duration(milliseconds: 1500),
    this.onAutoNavigate,
    this.playSound = true,
  });

  final String title;
  final String subtitle;
  final String gifPath;
  final String poweredByText;
  final String poweredByLogo;
  final Duration autoNavigateAfter;
  final FutureOr<void> Function(BuildContext context)? onAutoNavigate;
  final bool playSound;

  @override
  State<PaymentThankYouScreen> createState() => _PaymentThankYouScreenState();
}

class _PaymentThankYouScreenState extends State<PaymentThankYouScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.playSound) {
      _PaymentSoundController.play();
    }
    if (widget.onAutoNavigate != null) {
      _timer = Timer(widget.autoNavigateAfter, () {
        if (mounted) {
          widget.onAutoNavigate?.call(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EF),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Image.asset(
              widget.gifPath,
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.75),
                      height: 1.4,
                    ),
              ),
            ),
            const Spacer(flex: 3),
            Text(
              widget.poweredByText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.65),
                  ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              widget.poweredByLogo.isEmpty
                  ? FileConstants.bharatConnect
                  : widget.poweredByLogo,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class PaymentResultScreen extends StatefulWidget {
  const PaymentResultScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.details,
    this.detailsTitle = 'Transaction Details',
    this.onViewHistory,
    this.viewHistoryText = 'View Transaction History',
    this.onContinue,
    this.continueText = 'Continue to Home',
    this.showFailureActions = false,
    this.statusIcon = Icons.check,
    this.statusIconColor = Colors.white,
    this.statusIconBorderColor = Colors.white,
    this.headerGradientColors = const [Color(0xFF0D5C32), Color(0xFF0E7340)],
    this.headerImageAsset = '',
    this.emphasizeSubtitle = false,
    this.poweredByText = 'Powered by',
    this.poweredByLogo = '',
    this.playSound = true,
    this.soundAsset = 'sounds/payment_success.mp3',
    this.stopSoundOnExit = true,
  });

  final String title;
  final String subtitle;
  final List<PaymentDetailItem> details;
  final String detailsTitle;
  final FutureOr<void> Function(BuildContext context)? onViewHistory;
  final String viewHistoryText;
  final FutureOr<void> Function(BuildContext context)? onContinue;
  final String continueText;
  final bool showFailureActions;
  final IconData statusIcon;
  final Color statusIconColor;
  final Color statusIconBorderColor;
  final List<Color> headerGradientColors;
  final String headerImageAsset;
  final bool emphasizeSubtitle;
  final String poweredByText;
  final String poweredByLogo;
  final bool playSound;
  final String soundAsset;
  final bool stopSoundOnExit;

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.playSound) {
      _PaymentSoundController.play(asset: widget.soundAsset);
    }
  }

  @override
  void dispose() {
    if (widget.stopSoundOnExit) {
      _PaymentSoundController.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final headerHeight = height * 0.5;
          final cardTop = headerHeight * 0.82;

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: headerHeight,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.headerGradientColors,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          if (widget.headerImageAsset.isNotEmpty)
                            Image.asset(
                              widget.headerImageAsset,
                              fit: BoxFit.cover,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(
                    child: ColoredBox(color: Color(0xFFFFF4EF)),
                  ),
                ],
              ),
              Positioned(
                left: 24,
                right: 24,
                top: cardTop,
                child: _TransactionDetailsCard(
                  title: widget.detailsTitle,
                  details: widget.details,
                ),
              ),
              if (widget.showFailureActions)
                Positioned(
                  left: 24,
                  right: 24,
                  top: cardTop + 170,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.support_agent),
                          label: const Text('Contact Support'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(
                              color: AppColors.lightBorder.withOpacity(0.8),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(
                              color: AppColors.lightBorder.withOpacity(0.8),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Positioned(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).padding.top + 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.statusIconBorderColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        widget.statusIcon,
                        color: widget.statusIconColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.emphasizeSubtitle)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.95),
                                    height: 1.4,
                                  ),
                        ),
                      )
                    else
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onViewHistory != null) ...[
                          GestureDetector(
                            onTap: () => widget.onViewHistory?.call(context),
                            child: Text(
                              widget.viewHistoryText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          20.hs,
                        ],
                        CustomElevatedButton(
                          onPressed: widget.onContinue == null
                              ? null
                              : () => widget.onContinue?.call(context),
                          label: widget.continueText,
                          uppercaseLabel: false,
                          showArrow: false,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.poweredByText,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textPrimary.withOpacity(0.65),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Image.asset(
                          widget.poweredByLogo.isEmpty
                              ? FileConstants.bharatConnectColor
                              : widget.poweredByLogo,
                          height: 30.h,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentSoundController {
  static AudioPlayer? _player;
  static bool _isPlaying = false;

  static void play({String asset = 'sounds/payment_success.mp3'}) {
    if (_isPlaying) return;
    _player ??= AudioPlayer();
    _isPlaying = true;
    _player!.play(AssetSource(asset)).catchError((_) {
      _isPlaying = false;
    }).whenComplete(() {
      _isPlaying = false;
    });
  }

  static void stop() {
    _player?.stop();
    _isPlaying = false;
  }
}

class _TransactionDetailsCard extends StatelessWidget {
  const _TransactionDetailsCard({
    required this.title,
    required this.details,
  });

  final String title;
  final List<PaymentDetailItem> details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              shadows: const [],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.lightBorder.withOpacity(0.6)),
          const SizedBox(height: 8),
          ...details.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            item.value,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                          ),
                        ),
                        if (item.copyable) ...[
                          6.vs,
                          InkWell(
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: item.value),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaction ID copied.'),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
