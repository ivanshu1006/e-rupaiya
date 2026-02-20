import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/app_colors.dart';

class AuthBrandHeader extends StatefulWidget {
  const AuthBrandHeader({
    super.key,
    this.title = 'Turn Every\nPayment\ninto Points.',
    this.subtitle =
        'Earn points\nevery time you\npay.\nYour payments,\nyour power.',
  });

  final String title;
  final String subtitle;

  @override
  State<AuthBrandHeader> createState() => _AuthBrandHeaderState();
}

class _AuthBrandHeaderState extends State<AuthBrandHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroStyle = Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: 40.sp,
          fontWeight: FontWeight.w700,
          height: 1.15,
          fontStyle: FontStyle.italic,
        );

    final subtitleStyle = Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: 40.sp,
          fontWeight: FontWeight.w700,
          height: 1.15,
          fontStyle: FontStyle.italic,
        );

    return Padding(
      padding: EdgeInsets.only(top: 32.h, left: 20.w, right: 20.w),
      child: SizedBox(
        height: 350.h,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -_animation.value * 350.h,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),
                        _GradientText(
                          text: widget.title,
                          style: heroStyle,
                        ),
                        SizedBox(height: 16.h),
                        _GradientText(
                          text: widget.subtitle,
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: (1 - _animation.value) * 350.h,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),
                        _GradientText(
                          text: widget.title,
                          style: heroStyle,
                        ),
                        SizedBox(height: 16.h),
                        _GradientText(
                          text: widget.subtitle,
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100.h,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return AppColors.heroTextGradient
            .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: style?.copyWith(color: Colors.white),
      ),
    );
  }
}
