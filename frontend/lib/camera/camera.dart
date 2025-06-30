import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'widgets/camera_preview_widget.dart';
import 'widgets/camera_controls_widget.dart';
import 'widgets/photo_animation_widget.dart';
import 'widgets/camera_lines.dart';
import 'widgets/camera_hint.dart';

import 'menu/composition.dart';
import 'menu/action.dart';
import 'menu/filter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

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

  String _composition = "none"; // 預設構圖
  String _action = "none"; // 預設構圖
  String _filter = "none"; // 預設構圖
  String predictedComposition="";
  final hint = {
    "hasText": false,
    "hasButton": true,
    "buttonText": "點擊獲取構圖推薦",
    "textText": "jjj",
  };


  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
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

    await _takeScreenshot();

    // 模擬存檔成功
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('照片已儲存')),
    );
  }

  Future<void> _handleShowComposition() async {
    final selected = await showCompositionMenu(context, selectedLabel: _composition);
    if (selected != null && mounted) {
      setState(() {
        _composition = selected;
        print(_composition);
      });
    }
  }

  Future<void> _handleShowAction() async {
    final selected = await showActionMenu(context, selectedLabel: _action);
    if (selected != null && mounted) {
      setState(() {
        _action = selected;
        print(_action);
      });
    }
  }

  Future<void> _handleShowFilter() async {
    final selected = await showFilterMenu(context, selectedLabel: _filter);
    if (selected != null && mounted) {
      setState(() {
        _filter = selected;
        print(_filter);
      });
    }
  }



  Future<void> getComposition() async {
    try {
      if (!controller.value.isInitialized) {
        print('Camera not initialized');
        return;
      }

      // 1. 拍照，但不顯示動畫
      final XFile file = await controller.takePicture();

      // 2. 讀檔案成 bytes
      final bytes = await file.readAsBytes();

      // 3. 將 bytes 編碼成 base64
      final base64Image = base64Encode(bytes);

      // 4. 組裝 POST 請求的 JSON body
      final body = jsonEncode({
        'image': base64Image,
      });

      // 5. 從環境變數取得 API url
      final apiUrl = '${dotenv.env['API_BASE_URL']}/compositionDetection';
      print("apiURL=$apiUrl");

      // 6. 發送 POST 請求
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // 7. 印出後端回傳
      if (response.statusCode == 200) {
        print('後端回傳: ${response.body}');
        final data = jsonDecode(response.body); // 轉 Map

        setState(() {
          hint["hasText"] = true;
          hint["buttonText"] = "套用";
          hint["textText"] = "推薦構圖: ${data['composition'] ?? ''}";
          predictedComposition=data['composition'];
        });
      } else {
        print('錯誤: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('例外錯誤: $e');
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
          CameraPreviewWidget(
            key: previewKey,
            controller: controller,
          ),
          CompositionLines(composition: _composition),
          CameraHintText(
            hasButton: hint["hasButton"] == true,
            hasText: hint["hasText"] == true,
            textText: hint['textText']?.toString() ?? '',
            buttonText: hint['buttonText']?.toString() ?? '',
            onButtonTap: (value) async {
              print('按鈕點擊，傳回：$value');
              if (value == "點擊獲取構圖推薦") {
                await getComposition();
              }else if (value == "套用") {
                setState(() {
                   _composition = predictedComposition;
                });
              }
            },
          ),
          CameraControlsWidget(
            latestThumbnail: null,
            onTakePicture: _takePictureAndSave,
            onSwitchToAlbum: widget.onSwitchToAlbum,
            onShowFilter: _handleShowFilter,
            onShowAction: _handleShowAction,
            onShowComposition: _handleShowComposition,
          ),
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
