import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants/app_colors.dart';

class ScreenWrapper extends StatelessWidget {
  const ScreenWrapper({
    super.key,
    required this.isFetching,
    required this.isEmpty,
    required this.emptyMessage,
    required this.child,
    this.errorMessage,
    this.description,
    this.actions,
    this.imageAsset,
    this.height,
  });

  final bool isFetching;
  final bool isEmpty;
  final String emptyMessage;
  final String? errorMessage;
  final String? description;
  final List<Widget>? actions;
  final String? imageAsset;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return SizedBox(
        height: height,
        child: const Center(
          child: SpinKitCircle(
            color: AppColors.primary,
            size: 48,
          ),
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return _StateMessage(
        height: height,
        title: errorMessage!,
        description: description,
        actions: actions,
        imageAsset: imageAsset,
      );
    }

    if (isEmpty) {
      return _StateMessage(
        height: height,
        title: emptyMessage,
        description: description,
        actions: actions,
        imageAsset: imageAsset,
      );
    }

    return child;
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    this.description,
    this.actions,
    this.imageAsset,
    this.height,
  });

  final String title;
  final String? description;
  final List<Widget>? actions;
  final String? imageAsset;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageAsset != null) ...[
              Image.asset(imageAsset!, height: 72),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: 260,
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                ),
              ),
            ],
            if ((actions ?? []).isNotEmpty) ...[
              const SizedBox(height: 16),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}
