import 'dart:typed_data';

import 'package:printing/printing.dart';

class ReceiptHtmlRenderer {
  const ReceiptHtmlRenderer._();

  static Future<Uint8List> toPdfBytes(String html) async {
    return Printing.convertHtml(html: html).timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        throw Exception(
          'Receipt rendering timed out. Please update Android System WebView and try again.',
        );
      },
    );
  }
}
