import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/app_snackbar.dart';
import '../services/receipt_file_service.dart';

class ReceiptHtmlViewerScreen extends StatefulWidget {
  const ReceiptHtmlViewerScreen({
    super.key,
    required this.html,
    required this.transactionId,
  });

  final String html;
  final String transactionId;

  @override
  State<ReceiptHtmlViewerScreen> createState() =>
      _ReceiptHtmlViewerScreenState();
}

class _ReceiptHtmlViewerScreenState extends State<ReceiptHtmlViewerScreen> {
  late final WebViewController _controller;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(widget.html);
  }

  Future<void> _handleShare() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final pdfBytes =
          await ReceiptFileService.buildPdfBytesFromHtml(widget.html);
      final imageFile = await ReceiptFileService.savePngFromPdfBytes(
        pdfBytes: pdfBytes,
        transactionId: widget.transactionId,
      );
      await Share.shareXFiles([XFile(imageFile.path)]);
    } catch (e) {
      AppSnackbar.show(e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _handleDownload() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      final pdfBytes =
          await ReceiptFileService.buildPdfBytesFromHtml(widget.html);
      final file = await ReceiptFileService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        transactionId: widget.transactionId,
      );
      AppSnackbar.show('Receipt saved to ${file.path}');
    } catch (e) {
      AppSnackbar.show(e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Receipt',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _isBusy ? null : _handleShare,
            icon: Icon(
              Icons.share,
              color: _isBusy ? Colors.white54 : Colors.white,
            ),
          ),
          IconButton(
            onPressed: _isBusy ? null : _handleDownload,
            icon: Icon(
              Icons.download,
              color: _isBusy ? Colors.white54 : Colors.white,
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
