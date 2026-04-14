// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/file_constants.dart';
import '../../../widgets/app_network_image.dart';

class HomeIconTile extends StatefulWidget {
  const HomeIconTile({
    super.key,
    required this.label,
    this.onTap,
    this.iconSize = 28,
    this.iconUrl,
    this.offer,
    this.labelSpacing,
    this.showHalfRing = false,
  });

  final String label;
  final VoidCallback? onTap;
  final double iconSize;
  final String? iconUrl;
  final int? offer;
  final double? labelSpacing;
  final bool showHalfRing;

  @override
  State<HomeIconTile> createState() => _HomeIconTileState();
}

class _HomeIconTileState extends State<HomeIconTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;
  bool _ringLoopActive = false;
  static const _ringDuration = Duration(milliseconds: 1000);
  static const _ringPause = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: _ringDuration,
    );
    if (widget.showHalfRing) {
      _startRingLoop();
    }
  }

  @override
  void didUpdateWidget(covariant HomeIconTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showHalfRing != widget.showHalfRing) {
      if (widget.showHalfRing) {
        _startRingLoop();
      } else {
        _ringLoopActive = false;
        _ringController.stop();
      }
    }
  }

  Future<void> _startRingLoop() async {
    if (_ringLoopActive) return;
    _ringLoopActive = true;
    while (mounted && widget.showHalfRing && _ringLoopActive) {
      await _ringController.forward(from: 0);
      await Future.delayed(_ringPause);
    }
  }

  @override
  void dispose() {
    _ringLoopActive = false;
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelTextStyle = AppTextStyles.bodySmallSemibold(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (widget.showHalfRing)
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _ringController.value * 2 * math.pi,
                      child: SizedBox(
                        height: 54.r,
                        width: 54.r,
                        child: CustomPaint(
                          painter: _HalfRingPainter(progress: 1),
                        ),
                      ),
                    );
                  },
                ),
              Container(
                height: 48.r,
                width: 48.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // border: Border.all(
                  //   color: AppColors.primary.withOpacity(0.4),
                  //   width: 1.4,
                  // ),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      Color(0xFFF9F9F9),
                      Color(0xFFF6F6F6),
                    ],
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: AppColors.cardShadow,
                  //     blurRadius: 10,
                  //     offset: Offset(0, 6),
                  //   ),
                  // ],
                ),
                child: Center(
                  child: AppNetworkImage(
                    url: widget.iconUrl,
                    width: widget.iconSize.r,
                    height: widget.iconSize.r,
                    fit: BoxFit.contain,
                    showShimmer: false,
                    errorWidget: Image.asset(
                      FileConstants.appLogo,
                      height: widget.iconSize.r,
                      width: widget.iconSize.r,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              if (widget.offer != null)
                Positioned(
                  top: -4.h,
                  right: 7.w,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '₹${widget.offer}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: widget.labelSpacing ?? 6.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              widget.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: labelTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _HalfRingPainter extends CustomPainter {
  _HalfRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 1.8.r;
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final startAngle = 0.75 * math.pi;
    final sweepAngle = math.pi * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _HalfRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
