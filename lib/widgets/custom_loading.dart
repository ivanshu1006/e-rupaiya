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
    Widget loadingWidget = Padding(
      padding: EdgeInsets.all(SizeConstants.mdSectionPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(width: SizeConstants.mdBetweenItemsSpacing),
          Text(loadingText),
        ],
      ),
    );

    return isCentered ? Center(child: loadingWidget) : loadingWidget;
  }
}
