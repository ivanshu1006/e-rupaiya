import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromCamera() async {
    final granted = await _requestCameraPermission();
    if (!granted) return null;
    final file = await _picker.pickImage(source: ImageSource.camera);
    return file == null ? null : File(file.path);
  }

  static Future<File?> pickFromGallery() async {
    final granted = await _requestGalleryPermission();
    if (!granted) return null;
    final file = await _picker.pickImage(source: ImageSource.gallery);
    return file == null ? null : File(file.path);
  }

  static Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return status.isGranted;
  }

  static Future<bool> _requestGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return status.isGranted;
    }
    final photos = await Permission.photos.request();
    if (photos.isGranted) return true;
    if (photos.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    final storage = await Permission.storage.request();
    if (storage.isPermanentlyDenied) {
      await openAppSettings();
    }
    return storage.isGranted;
  }
}
