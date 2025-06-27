import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MaterialApp(home: CameraApp()));
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  GlobalKey previewKey = GlobalKey();

  Uint8List? _capturedBytes;
  bool _showAnimation = false;
  double _imageSize = 0;
  double _left = 0;
  double _top = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
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
    await _takeScreenshot(); // 開始動畫

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
          RepaintBoundary(
            key: previewKey,
            child: CameraPreview(controller),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _takePictureAndSave,
                child: const Icon(Icons.camera_alt),
              ),
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
