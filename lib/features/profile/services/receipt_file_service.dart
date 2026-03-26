import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptFileService {
  ReceiptFileService._();

  static const Duration _androidTimeout = Duration(seconds: 45);
  static const Duration _defaultTimeout = Duration(seconds: 20);

  static Future<Uint8List> buildPdfBytesFromHtml(String html) async {
    final timeout = Platform.isAndroid ? _androidTimeout : _defaultTimeout;
    Future<Uint8List> attempt() {
      return Printing.convertHtml(html: html).timeout(
        timeout,
        onTimeout: () {
          throw Exception(
            'Receipt rendering timed out. Please update Android System WebView and try again.',
          );
        },
      );
    }

    try {
      return await attempt();
    } catch (_) {
      if (!Platform.isAndroid) rethrow;
      await Future.delayed(const Duration(milliseconds: 400));
      try {
        return await attempt();
      } catch (_) {
        return _buildFallbackPdf(html);
      }
    }
  }

  static Future<Uint8List> buildSimplePdfFromHtml(String html) async {
    return _buildFallbackPdf(html);
  }

  static Future<Uint8List> _buildFallbackPdf(String html) async {
    final txId = _extractValue(html, 'Transaction ID') ?? '—';
    final amount = _extractValue(html, 'Amount') ?? '—';
    final status = _extractValue(html, 'Status') ?? '—';
    final date = _extractValue(html, 'Date') ?? '—';
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Payment Receipt',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              _row('Transaction ID', txId),
              _divider(),
              _row('Amount', amount),
              _divider(),
              _row('Status', status),
              _divider(),
              _row('Date', date),
              _divider(),
              pw.SizedBox(height: 18),
              pw.Text(
                'Generated on device because WebView rendering was unavailable.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );
    return await doc.save();
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _divider() {
    return pw.Container(
      height: 1,
      color: PdfColors.grey300,
    );
  }

  static String? _extractValue(String html, String label) {
    final pattern = RegExp(
      '<span>\\s*${RegExp.escape(label)}\\s*</span>\\s*<span>(.*?)</span>',
      caseSensitive: false,
      dotAll: true,
    );
    final match = pattern.firstMatch(html);
    if (match == null) return null;
    return match.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim();
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

  static Future<File> saveHtmlToTemp({
    required String html,
    required String transactionId,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/receipt_$transactionId.html');
    return file.writeAsString(html, flush: true);
  }
}
