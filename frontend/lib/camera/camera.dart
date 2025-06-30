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
import 'widgets/camera_preview_widget.dart';
import 'widgets/camera_controls_widget.dart';
import 'widgets/photo_animation_widget.dart';
import 'widgets/camera_service.dart';
import 'widgets/camera_lines.dart';
import 'widgets/camera_hint.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final VoidCallback? onSwitchToAlbum;

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
    _initializeCamera();
    _fetchLatestPhoto();
  }

  void _initializeCamera() {
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _fetchLatestPhoto() async {
    final photoData = await CameraService.fetchLatestPhoto();
    if (photoData != null) {
      setState(() {
        _latestAsset = photoData.asset;
        _latestThumbnail = photoData.thumbnail;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await CameraService.requestPermissions();
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

    final result = await CameraService.takePictureAndSave(controller);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );

    if (result.success) {
      // 重新獲取最新照片
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchLatestPhoto();
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
          // 相機預覽

          CameraPreviewWidget(
            key: previewKey,
            controller: controller,
          ),
          const CompositionLines(composition: "center"),
          const CameraHintText(),
          // 控制按鈕
          CameraControlsWidget(
            latestThumbnail: _latestThumbnail,
            onTakePicture: _takePictureAndSave,
            onSwitchToAlbum: widget.onSwitchToAlbum,
            onShowFilter: () => showFilterMenu(context),
            onShowAction: () => showActionMenu(context),
            onShowComposition: () => showCompositionMenu(context),
          ),

          // 拍照動畫
          if (_showAnimation && _capturedBytes != null)
            PhotoAnimationWidget(
              capturedBytes: _capturedBytes!,
              imageSize: _imageSize,
              left: _left,
              top: _top,
            ),
        ],
      ),
    );
  }
}