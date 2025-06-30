import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_manager/photo_manager.dart';

import 'menu/filter.dart';
import 'menu/action.dart';
import 'menu/composition.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final VoidCallback? onSwitchToAlbum;  // 新增callback參數

  const CameraPage({
    super.key,
    required this.cameras,
    this.onSwitchToAlbum,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  GlobalKey previewKey = GlobalKey();

  Uint8List? _capturedBytes;
  bool _showAnimation = false;
  double _imageSize = 0;
  double _left = 0;
  double _top = 0;

  AssetEntity? _latestAsset;
  Uint8List? _latestThumbnail;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });

    _fetchLatestPhoto();
  }

  Future<void> _fetchLatestPhoto() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      // 權限拒絕處理
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );

    if (albums.isEmpty) return;

    final recentAlbum = albums.first;
    final recentAssets = await recentAlbum.getAssetListRange(start: 0, end: 1);

    if (recentAssets.isNotEmpty) {
      _latestAsset = recentAssets.first;
      final thumbData = await _latestAsset!.thumbnailDataWithSize(const ThumbnailSize(100, 100));
      if (thumbData != null) {
        setState(() {
          _latestThumbnail = thumbData;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      if (Platform.isAndroid) Permission.storage,
      if (Platform.isIOS) Permission.photos,
    ].request();
  }

  Future<void> _takeScreenshot() async {
    final boundary = previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    setState(() {
      _capturedBytes = bytes;
      _showAnimation = true;
      _imageSize = MediaQuery.of(context).size.width;
      _left = 0;
      _top = 0;
    });

    await Future.delayed(const Duration(milliseconds: 50));
    setState(() {
      _imageSize = 60;
      _left = 20;
      _top = MediaQuery.of(context).size.height - 100;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _showAnimation = false;
    });
  }

  Future<void> _takePictureAndSave() async {
    if (!controller.value.isInitialized) return;

    await _requestPermissions();
    await _takeScreenshot();

    try {
      final XFile file = await controller.takePicture();
      final result = await SaverGallery.saveFile(
        filePath: file.path,
        fileName: 'photo_${DateTime.now().millisecondsSinceEpoch}',
        skipIfExists: true,
      );

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 照片已存入相簿！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 儲存失敗：${result.errorMessage}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('錯誤：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize!.height,
                height: controller.value.previewSize!.width,
                child: CameraPreview(controller),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 40,
                  icon: _latestThumbnail != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(
                      _latestThumbnail!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                      :const Icon(Icons.photo_library, size: 30, color: Colors.white),
                  onPressed: () {
                    if (widget.onSwitchToAlbum != null) {
                      widget.onSwitchToAlbum!();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.tonality, size: 30, color: Colors.white),
                  onPressed: () => showFilterMenu(context),
                ),
                GestureDetector(
                  onTap: _takePictureAndSave,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white70,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.accessibility_new, size: 30, color: Colors.white),
                  onPressed: () => showActionMenu(context),
                ),
                IconButton(
                  icon: const Icon(Icons.grid_on, size: 30, color: Colors.white),
                  onPressed: () => showCompositionMenu(context),
                ),
              ],
            ),
          ),
          if (_showAnimation && _capturedBytes != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              left: _left,
              top: _top,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: _imageSize,
                height: _imageSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(_capturedBytes!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

