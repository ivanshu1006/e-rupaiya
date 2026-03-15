import 'package:flutter/material.dart';

import '../constants/size_constants.dart';

class CustomLoading extends StatelessWidget {
  final bool isCentered;
  final String loadingText;
  const CustomLoading({
    super.key,
    this.isCentered = false,
    required this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        SizedBox(height: SizeConstants.smBetweenItemsSpacing),
        Text(
          loadingText,
          textAlign: TextAlign.center,
        ),
      ],
    );

    return isCentered ? Center(child: loadingWidget) : loadingWidget;
  }
}
