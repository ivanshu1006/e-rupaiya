// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/k_dialog.dart';
import '../repositories/receipt_repository.dart';
import '../services/receipt_file_service.dart';
import '../utils/receipt_html_renderer.dart';
import '../views/receipt_html_viewer_screen.dart';
import '../views/receipt_viewer_screen.dart';

enum ReceiptAction { share, download }

class ReceiptActions {
  ReceiptActions._();

  static String resolveReceiptTransactionId({
    required String refId,
    required String txnId,
  }) {
    if (refId.trim().isNotEmpty) return refId.trim();
    return txnId.trim();
  }

  static Future<void> handleReceiptAction(
    BuildContext context, {
    required String transactionId,
    required ReceiptAction action,
  }) async {
    if (transactionId.trim().isEmpty) {
      AppSnackbar.show('Missing transaction id.');
      return;
    }

    BuildContext? dialogContext;
    try {
      dialogContext = navigatorKey.currentContext;
      if (dialogContext != null) {
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: SpinKitCircle(
              color: AppColors.primary,
              size: 48,
            ),
          ),
        );
      }

      if (Platform.isAndroid) {
        log('[Receipt] Android flow start: $transactionId');
        final html = await _fetchReceiptHtml(transactionId);
        log('[Receipt] HTML fetched (${html.length} chars)');
        _hideLoading(dialogContext);
        if (action == ReceiptAction.share) {
          log('[Receipt] Converting HTML to PDF for sharing');
          File pdfFile;
          try {
            pdfFile = await ReceiptFileService.buildPdfFileFromHtmlViaWebView(
              html: html,
              transactionId: transactionId,
            );
          } catch (e) {
            log('[Receipt] Native WebView PDF failed: $e');
            final shareResult = await _buildSharePdfBytes(html);
            final pdfBytes = shareResult.bytes;
            if (shareResult.usedFallback) {
              AppSnackbar.show(
                'Using a basic receipt because full rendering is unavailable.',
              );
            }
            pdfFile = await ReceiptFileService.savePdfToTemp(
              pdfBytes: pdfBytes,
              transactionId: transactionId,
            );
          }
          log('[Receipt] PDF saved: ${pdfFile.path}');
          await Share.shareXFiles(
            [
              XFile(
                pdfFile.path,
                mimeType: 'application/pdf',
                name: 'receipt_$transactionId.pdf',
              ),
            ],
            text: 'Payment Receipt',
          );
          log('[Receipt] Share sheet invoked');
        } else {
          final pdfBytes = await ReceiptFileService.buildPdfBytesFromHtml(html);
          log('[Receipt] PDF bytes generated (${pdfBytes.length} bytes)');
          final file = await ReceiptFileService.savePdfToDownloads(
            pdfBytes: pdfBytes,
            transactionId: transactionId,
          );
          AppSnackbar.show('Receipt saved to ${file.path}');
        }
        return;
      }

      log('[Receipt] Non-Android flow start: $transactionId');
      final pdfBytes = await _fetchReceiptPdfBytes(transactionId);
      log('[Receipt] PDF bytes generated (${pdfBytes.length} bytes)');
      _hideLoading(dialogContext);
      if (action == ReceiptAction.share) {
        final pdfFile = await ReceiptFileService.savePdfToTemp(
          pdfBytes: pdfBytes,
          transactionId: transactionId,
        );
        log('[Receipt] PDF saved: ${pdfFile.path}');
        await Share.shareXFiles(
          [
            XFile(
              pdfFile.path,
              mimeType: 'application/pdf',
              name: 'receipt_$transactionId.pdf',
            ),
          ],
          text: 'Payment Receipt',
        );
        log('[Receipt] Share sheet invoked');
      } else {
        final file = await _saveReceiptPdf(
          bytes: pdfBytes,
          transactionId: transactionId,
        );
        AppSnackbar.show('Receipt saved to ${file.path}');
      }
    } catch (e, t) {
      log('Receipt generation error: $e');
      // ignore: avoid_print
      print(t);
      _hideLoading(dialogContext);
      AppSnackbar.show(e.toString());
    }
  }

  static Future<void> openReceiptViewer(
    BuildContext context, {
    required String transactionId,
  }) async {
    if (transactionId.trim().isEmpty) {
      AppSnackbar.show('Missing transaction id.');
      return;
    }

    BuildContext? dialogContext;
    try {
      dialogContext = navigatorKey.currentContext;
      if (dialogContext != null) {
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: SpinKitCircle(
              color: AppColors.primary,
              size: 48,
            ),
          ),
        );
      }

      if (Platform.isAndroid) {
        final html = await _fetchReceiptHtml(transactionId);
        _hideLoading(dialogContext);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReceiptHtmlViewerScreen(
              html: html,
              transactionId: transactionId,
            ),
          ),
        );
        return;
      }

      final pdfBytes = await _fetchReceiptPdfBytes(transactionId);
      _hideLoading(dialogContext);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceiptViewerScreen(
            pdfBytes: pdfBytes,
            transactionId: transactionId,
          ),
        ),
      );
    } catch (e, t) {
      log('Receipt view error: $e');
      // ignore: avoid_print
      print(t);
      _hideLoading(dialogContext);
      AppSnackbar.show(e.toString());
    }
  }

  static const Duration _shareRenderTimeout = Duration(seconds: 15);

  static Future<_SharePdfResult> _buildSharePdfBytes(String html) async {
    var usedFallback = false;
    final startedAt = DateTime.now();
    log('[Receipt] Share render start');
    try {
      final renderFuture = ReceiptFileService.buildPdfBytesFromHtml(html);
      final fallbackFuture = Future<Uint8List>.delayed(
        _shareRenderTimeout,
        () async {
          usedFallback = true;
          log(
            '[Receipt] Share render timed out after ${_shareRenderTimeout.inSeconds}s, using fallback',
          );
          return ReceiptFileService.buildSimplePdfFromHtml(html);
        },
      );
      final bytes = await Future.any<Uint8List>([
        renderFuture,
        fallbackFuture,
      ]);
      final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
      log(
        '[Receipt] Share render completed in ${elapsedMs}ms (fallback=$usedFallback, bytes=${bytes.length})',
      );
      return _SharePdfResult(bytes: bytes, usedFallback: usedFallback);
    } catch (e, stackTrace) {
      final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
      log(
        '[Receipt] Share render failed after ${elapsedMs}ms: $e',
        stackTrace: stackTrace,
      );
      final bytes = await ReceiptFileService.buildSimplePdfFromHtml(html);
      return _SharePdfResult(bytes: bytes, usedFallback: true);
    }
  }

  static Future<Uint8List> _fetchReceiptPdfBytes(String transactionId) async {
    final repo = ReceiptRepository();
    final html = await repo.fetchReceiptHtml(transactionId: transactionId);
    if (html.trim().isEmpty) {
      throw Exception('Empty receipt content.');
    }
    return ReceiptHtmlRenderer.toPdfBytes(html);
  }

  static Future<String> _fetchReceiptHtml(String transactionId) async {
    final repo = ReceiptRepository();
    final html = await repo.fetchReceiptHtml(transactionId: transactionId);
    if (html.trim().isEmpty) {
      throw Exception('Empty receipt content.');
    }
    return html;
  }

  static Future<File> _saveReceiptPdf({
    required List<int> bytes,
    required String transactionId,
  }) async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final resolvedDir = directory ?? await getApplicationDocumentsDirectory();
    final file = File('${resolvedDir.path}/receipt_$transactionId.pdf');
    return file.writeAsBytes(bytes, flush: true);
  }

  static void _hideLoading(BuildContext? dialogContext) {
    if (dialogContext == null) return;
    if (Navigator.of(dialogContext).canPop()) {
      Navigator.of(dialogContext).pop();
    }
  }
}

class _SharePdfResult {
  const _SharePdfResult({required this.bytes, required this.usedFallback});

  final Uint8List bytes;
  final bool usedFallback;
}
