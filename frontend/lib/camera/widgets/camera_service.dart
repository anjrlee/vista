// services/camera_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:photo_manager/photo_manager.dart';

class CameraService {
  static Future<void> requestPermissions() async {
    await [
      Permission.camera,
      if (Platform.isAndroid) Permission.storage,
      if (Platform.isIOS) Permission.photos,
    ].request();
  }

  static Future<CameraSaveResult> takePictureAndSave(CameraController controller) async {
    if (!controller.value.isInitialized) {
      return CameraSaveResult(success: false, message: '相機未初始化');
    }

    try {
      final XFile file = await controller.takePicture();
      final result = await SaverGallery.saveFile(
        filePath: file.path,
        fileName: 'photo_${DateTime.now().millisecondsSinceEpoch}',
        skipIfExists: true,
      );

      if (result.isSuccess) {
        return CameraSaveResult(success: true, message: '✅ 照片已存入相簿！');
      } else {
        return CameraSaveResult(success: false, message: '❌ 儲存失敗：${result.errorMessage}');
      }
    } catch (e) {
      return CameraSaveResult(success: false, message: '錯誤：$e');
    }
  }

  static Future<PhotoData?> fetchLatestPhoto() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) return null;

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );

    if (albums.isEmpty) return null;

    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(start: 0, end: 1);

    if (recentAssets.isNotEmpty) {
      final latestAsset = recentAssets.first;
      final thumbData = await latestAsset.thumbnailDataWithSize(const ThumbnailSize(100, 100));
      if (thumbData != null) {
        return PhotoData(asset: latestAsset, thumbnail: thumbData);
      }
    }
    return null;
  }
}

class CameraSaveResult {
  final bool success;
  final String message;

  CameraSaveResult({required this.success, required this.message});
}

class PhotoData {
  final AssetEntity asset;
  final Uint8List thumbnail;

  PhotoData({required this.asset, required this.thumbnail});
}