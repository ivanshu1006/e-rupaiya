import 'package:flutter/foundation.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
//     as mlkit;
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanHelper {
  ScanHelper() {
    torchEnabled = ValueNotifier<bool>(false);
    isScanning = ValueNotifier<bool>(true);
    lastResult = ValueNotifier<String>('');
    // _scanner = mlkit.BarcodeScanner(
    //   formats: [mlkit.BarcodeFormat.qrCode],
    // );
  }

  late final ValueNotifier<bool> torchEnabled;
  late final ValueNotifier<bool> isScanning;
  late final ValueNotifier<String> lastResult;
  QRViewController? _controller;
  // late final mlkit.BarcodeScanner _scanner;

  void attachController(QRViewController controller) async {
    _controller = controller;
    final flash = await controller.getFlashStatus();
    torchEnabled.value = flash ?? false;
    controller.scannedDataStream.listen((scanData) {
      final code = scanData.code ?? '';
      if (code.isEmpty) return;
      lastResult.value = code;
      stopScan();
    });
  }

  Future<void> toggleTorch() async {
    if (_controller == null) return;
    await _controller?.toggleFlash();
    final flash = await _controller?.getFlashStatus();
    torchEnabled.value = flash ?? false;
  }

  Future<void> startScan() async {
    isScanning.value = true;
    await _controller?.resumeCamera();
  }

  Future<void> stopScan() async {
    isScanning.value = false;
    await _controller?.pauseCamera();
  }

  Future<void> scanFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    // final inputImage = mlkit.InputImage.fromFilePath(file.path);
    // final barcodes = await _scanner.processImage(inputImage);
    // if (barcodes.isNotEmpty) {
    //   final raw = barcodes.first.rawValue ?? '';
    //   if (raw.isNotEmpty) {
    //     lastResult.value = raw;
    //   }
    // }
  }

  void dispose() {
    _controller?.dispose();
    // _scanner.close();
    torchEnabled.dispose();
    isScanning.dispose();
    lastResult.dispose();
  }
}
