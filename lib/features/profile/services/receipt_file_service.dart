import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class ReceiptFileService {
  ReceiptFileService._();

  static Future<Uint8List> buildPdfBytesFromHtml(String html) {
    return Printing.convertHtml(html: html).timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        throw Exception(
          'Receipt rendering timed out. Please update Android System WebView and try again.',
        );
      },
    );
  }

  static Future<File> savePdfToDownloads({
    required Uint8List pdfBytes,
    required String transactionId,
  }) async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final resolvedDir = directory ?? await getApplicationDocumentsDirectory();
    final file = File('${resolvedDir.path}/receipt_$transactionId.pdf');
    return file.writeAsBytes(pdfBytes, flush: true);
  }

  static Future<File> savePdfToTemp({
    required Uint8List pdfBytes,
    required String transactionId,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/receipt_$transactionId.pdf');
    return file.writeAsBytes(pdfBytes, flush: true);
  }

  static Future<File> savePngFromPdfBytes({
    required Uint8List pdfBytes,
    required String transactionId,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/receipt_$transactionId.png');
    final raster = await Printing.raster(pdfBytes, pages: const [0]).first;
    final pngBytes = await raster.toPng();
    return file.writeAsBytes(pngBytes, flush: true);
  }
}
