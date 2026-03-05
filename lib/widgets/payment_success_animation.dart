// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

Future<void> showPaymentSuccessDialog(
  BuildContext context, {
  String title = 'Payment Successful',
  String subtitle = 'Your payment has been processed.',
  Duration autoDismiss = const Duration(seconds: 2),
  bool playSound = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: PaymentSuccessAnimation(
        title: title,
        subtitle: subtitle,
        autoDismiss: autoDismiss,
        playSound: playSound,
      ),
    ),
  );
}

class PaymentSuccessAnimation extends StatefulWidget {
  const PaymentSuccessAnimation({
    super.key,
    required this.title,
    required this.subtitle,
    this.autoDismiss = const Duration(seconds: 2),
    this.playSound = true,
  });

  final String title;
  final String subtitle;
  final Duration autoDismiss;
  final bool playSound;

  @override
  State<PaymentSuccessAnimation> createState() =>
      _PaymentSuccessAnimationState();
}

class _PaymentSuccessAnimationState extends State<PaymentSuccessAnimation> {
  AudioPlayer? _player;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.playSound) {
      _player = AudioPlayer()..play(AssetSource('sounds/payment_success.mp3'));
    }
    _timer = Timer(widget.autoDismiss, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/gif/success.gif',
            height: 140,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}
