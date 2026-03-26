import 'dart:typed_data';

import '../services/receipt_file_service.dart';

class ReceiptHtmlRenderer {
  const ReceiptHtmlRenderer._();

  static Future<Uint8List> toPdfBytes(String html) async {
    return ReceiptFileService.buildPdfBytesFromHtml(html);
  }
}
