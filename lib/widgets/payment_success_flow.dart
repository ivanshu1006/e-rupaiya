// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/api_constants.dart';
import '../constants/app_colors.dart';
import '../constants/file_constants.dart';
import '../services/dio_service.dart';
import '../utils/screenutil_ext.dart';
import 'app_snackbar.dart';
import 'custom_elevated_button.dart';
import 'k_dialog.dart';

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

class _PaymentThankYouScreenState extends State<PaymentThankYouScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
        position: _slideAnimation,
        child: Scaffold(
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
        ));
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
    this.showRatingSheet = false,
    this.transactionId = '',
    this.ratingSheetDelay = const Duration(milliseconds: 300),
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
  final bool showRatingSheet;
  final String transactionId;
  final Duration ratingSheetDelay;

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  Timer? _ratingTimer;
  bool _ratingSheetOpened = false;

  @override
  void initState() {
    super.initState();
    if (widget.playSound) {
      _PaymentSoundController.play(asset: widget.soundAsset);
    }
    _scheduleRatingSheet();
  }

  @override
  void dispose() {
    _ratingTimer?.cancel();
    if (widget.stopSoundOnExit) {
      _PaymentSoundController.stop();
    }
    super.dispose();
  }

  void _scheduleRatingSheet() {
    if (!widget.showRatingSheet) return;
    if (widget.transactionId.trim().isEmpty) return;
    _ratingTimer?.cancel();
    _ratingTimer = Timer(widget.ratingSheetDelay, () {
      if (!mounted || _ratingSheetOpened) return;
      _ratingSheetOpened = true;
      KDialog.instance.openSheet(
        dialog: _RatingBottomSheet(transactionId: widget.transactionId),
      );
    });
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
                                    color: AppColors.textPrimary,
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

class _RatingBottomSheet extends StatefulWidget {
  const _RatingBottomSheet({required this.transactionId});

  final String transactionId;

  @override
  State<_RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<_RatingBottomSheet> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_isSubmitting) return;
    if (_rating == 0) {
      AppSnackbar.show(
        'Please select a rating.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final response = await DioService.instance.client.post(
        ApiConstants.ratingSubmitEndpoint,
        data: {
          'transaction_id': widget.transactionId,
          'rating': _rating,
          'review': _reviewController.text.trim(),
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final payload = response.data;
      final status = response.statusCode ?? 0;
      final success = status >= 200 &&
          status < 300 &&
          (payload is! Map ||
              payload['success'] == true ||
              payload['status']?.toString().toLowerCase() == 'success');
      if (success) {
        AppSnackbar.show(
          'Thanks for the feedback!',
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        );
        if (mounted) Navigator.of(context).pop();
      } else {
        AppSnackbar.show(
          'Failed to submit rating. Please try again.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (_) {
      AppSnackbar.show(
        'Failed to submit rating. Please try again.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStar(int index) {
    final isSelected = index <= _rating;
    return InkWell(
      onTap: () => setState(() => _rating = index),
      child: Icon(
        isSelected ? Icons.star_rounded : Icons.star_border_rounded,
        color: isSelected ? const Color(0xFFF5B301) : const Color(0xFFDADCE0),
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rate Us & Earn eCoins',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your experience and get rewarded\ninstantly',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.7),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => _buildStar(index + 1)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _reviewController,
                  minLines: 3,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Write your feedback',
                    hintStyle: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.35),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE4DFDA)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE4DFDA)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F1F1),
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Maybe Later'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          _isSubmitting ? 'Submitting...' : 'Claim 50 eCoins',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
