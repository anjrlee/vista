// camera_page.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/rendering.dart';
import 'package:http_parser/http_parser.dart';
import 'menu/composition.dart';
import 'menu/action.dart';
import 'menu/filter.dart';

import 'widgets/camera_lines.dart';
import 'widgets/camera_hint.dart';
import 'widgets/camera_preview_widget.dart';
import 'widgets/camera_controls_widget.dart';
import 'widgets/photo_animation_widget.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

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
  String _composition = "none";
  String _action = "none";
  String _filter = "none";
  Uint8List? _poseImageBytes;
  String predictedComposition = "";
  bool isAlignmentMode = false;
  int lineIndex = 0;
  List<double> scores = [];
  bool checkPose = false;

  final hint = {
    "hasText": false,
    "hasButton": true,
    "buttonText": "點擊獲取構圖推薦",
    "textText": "",
  };

  final poseHint = {
    "hasText": false,
    "hasButton": true,
    "buttonText": "點擊獲取姿勢建議",
    "textText": "",
  };

  // --- 1. 新增 zoom 變數 ---
  double _baseZoomLevel = 1.0;
  double _tmpZoomLevel=1.0;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 0.5;
  double _maxZoomLevel = 2;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) async {
      if (!mounted) return;

      // --- 2. 初始化時取得最大最小 zoom level ---
      _minZoomLevel = await controller.getMinZoomLevel();
      _maxZoomLevel = await controller.getMaxZoomLevel();

      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  ColorFilter? _getColorFilterForSelected(String filter) {
    switch (filter) {
      case '黑白':
        return const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case '復古':
        return const ColorFilter.matrix(<double>[
          0.9, 0.5, 0.1, 0, 0,
          0.3, 0.7, 0.2, 0, 0,
          0.2, 0.3, 0.5, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 'HDR':
        return const ColorFilter.matrix(<double>[
          1.3, 0, 0, 0, 0,
          0, 1.3, 0, 0, 0,
          0, 0, 1.3, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case '日系':
        return const ColorFilter.matrix(<double>[
          1.1, 0.1, 0.1, 0, 10,
          0.0, 1.0, 0.0, 0, 0,
          0.0, 0.0, 0.9, 0, -10,
          0, 0, 0, 1, 0,
        ]);
      default:
        return null;
    }
  }



  Future<void> _handleShowAction() async {
    final selected = await showActionMenu(
      context,
      selectedLabel: _action,
    );

    if (selected != null && mounted) {
      setState(() {
        _action = selected;
        print(_action);
      });

      final fileName = 'IMG_${_action}-removebg-preview.png';
      final imagePath = 'assets/pose_black/$fileName';

      try {
        final bytes = await rootBundle.load(imagePath);
        setState(() {
          _poseImageBytes = bytes.buffer.asUint8List();
          checkPose=true;

        });
      } catch (e) {
        print("❌ Error loading image: $e");
      }
    }
  }



  Future<void> _handleShowFilter() async {
    final selected = await showFilterMenu(context, selectedLabel: _filter);
    if (selected != null && mounted) {
      setState(() {
        _filter = selected;
      });
    }
  }

  Future<void> _handleShowComposition() async {
    final selected = await showCompositionMenu(context, selectedLabel: _composition);
    if (selected != null && mounted) {
      setState(() {
        _composition = selected;
      });
    }
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

    final XFile file = await controller.takePicture();

    // ✅ 儲存到相簿
    final AssetEntity? savedImage = await PhotoManager.editor.saveImageWithPath(file.path);

    if (savedImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📸 照片已儲存到相簿')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ 儲存失敗')),
      );
    }

    // 顯示動畫（可選）
    final bytes = await file.readAsBytes();
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

  Future<void> getComposition() async {
    try {
      if (!controller.value.isInitialized) return;

      final XFile file = await controller.takePicture();

      final apiUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/compositionDetection');

      var request = http.MultipartRequest('POST', apiUrl);
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        contentType: MediaType('image', 'jpeg'), // 若確定是 jpeg，沒有也行
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        // 讀回應字串
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);

        setState(() {
          _tmpZoomLevel=_currentZoomLevel*data['crop_percentage'];
          hint["hasText"] = true;
          hint["hasButton"] = true;
          hint["buttonText"] = "套用";
          hint["textText"] = "推薦構圖: ${data['composition'] ?? ''}";
          predictedComposition = data['composition'];
          // _poseImageBytes = base64Decode(data['poseIMG']);
        }
        );

      } else {
        print('伺服器回傳錯誤，狀態碼: ${response.statusCode}');
      }
    } catch (e) {
      print('例外錯誤: $e');
    }
  }

  Future<double?> takePictureAndGetScoreForLine(int lineIdx) async {
    if (!controller.value.isInitialized) return null;

    try {
      final XFile file = await controller.takePicture();
      final apiUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/aestheticScoreFunction');

      var request = http.MultipartRequest('POST', apiUrl);

      // 加入圖片檔，field 名稱 "image"
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        contentType: MediaType('image', 'jpeg'), // 如果是 jpeg
      ));

      request.fields['line_index'] = lineIdx.toString();

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();

        final score = double.tryParse(respStr);
        print("score= $score");
        return score;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> getPoseImage() async {
    try {
      if (!controller.value.isInitialized) return;

      final XFile file = await controller.takePicture();

      final apiUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/poseDetectionFunction');

      var request = http.MultipartRequest('POST', apiUrl);
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        contentType: MediaType('image', 'jpeg'), // 若確定是 jpeg，沒有也行
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        // 讀回應字串
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        final newPoseImageBytes = base64Decode(data['poseIMG']);

        setState(() {
          poseHint["hasText"] = false;
          poseHint["hasButton"] = true;
          poseHint["buttonText"] = "點擊獲取姿勢建議";
          poseHint["textText"] = "";
          _poseImageBytes = newPoseImageBytes;
          checkPose = true;
          hint["hasButton"] = true;
        });

      } else {
        print('伺服器回傳錯誤123，狀態碼: ${response.statusCode}');
      }
    } catch (e) {
      print('例外錯誤: $e');
    }
  }

  int totalLinesForComposition(String composition) {
    switch (composition) {
      case 'vertical':
      case 'horizontal':
        return 2;
      case 'rule_of_thirds':
        return 4;
      default:
        return 1;
    }
  }

  void startAlignmentMode() {
    if (predictedComposition.isEmpty) return;
    setState(() {
      _composition = predictedComposition;

      isAlignmentMode = true;
      lineIndex = 0;
      scores = [];
      _currentZoomLevel=_tmpZoomLevel;
      hint["hasText"] = true;
      hint["buttonText"] = "我對好了";
      hint["hasButton"]=true;
      hint["textText"] = "請將背景主體對準紅色線/框框";
    });
    controller.setZoomLevel(_currentZoomLevel);
  }

  Future<void> onUserConfirmLine() async {
    double? score = await takePictureAndGetScoreForLine(lineIndex);
    if (score == null) return;
    scores.add(score);
    int totalLines = totalLinesForComposition(_composition);
    if (lineIndex + 1 >= totalLines) {
      int bestLineIndex = 0;
      double bestScore = scores[0];
      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > bestScore) {
          bestScore = scores[i];
          bestLineIndex = i;
        }
      }

      setState(() {
        lineIndex = bestLineIndex;
        hint["textText"] = "背景主體對準第 ${bestLineIndex + 1} 條線，正在自動調整曝光...";
        hint["hasButton"] = false;
      });
      await findBestExposureForCurrentLine();

      setState(() {
        lineIndex = bestLineIndex;
        hint["textText"] = "背景主體對準第 ${bestLineIndex + 1} 條線，請按快門拍照";
        hint["hasButton"]=true;
        hint["buttonText"] = "拍照";
      });
    } else {
      setState(() {
        lineIndex++;
        hint["textText"] = "請將背景主體對準第 ${lineIndex + 1} 條線";
      });
    }
  }

  Future<void> onFinalCapture() async {
    await _takePictureAndSave();
    setState(() {
      hint["textText"] = "";
      hint["buttonText"] = "點擊獲取構圖推薦";
      predictedComposition = "";
      _composition = "none";
    });
  }

  Future<void> findBestExposureForCurrentLine() async {
    if (!controller.value.isInitialized) return;

    try {
      // 取得相機支持的曝光補償範圍
      final minExposure = await controller.getMinExposureOffset();
      final maxExposure = await controller.getMaxExposureOffset();

      double bestScore = double.negativeInfinity;
      double bestExposure = 0.0;

      // 這裡先測幾個等間距值
      List<double> exposureValues = List.generate(5, (i) {
        return minExposure + i * (maxExposure - minExposure) / 4;
      });

      for (double exposure in exposureValues) {
        await controller.setExposureOffset(exposure);
        await Future.delayed(const Duration(milliseconds: 300));
        final XFile file = await controller.takePicture();
        final apiUrl = Uri.parse('${dotenv.env['API_BASE_URL']}/exposureScoreFunction');
        var request = http.MultipartRequest('POST', apiUrl);
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
        request.fields['exposure_value'] = exposure.toString();
        final response = await request.send();

        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final score = double.tryParse(respStr) ?? double.negativeInfinity;
          if (score > bestScore) {
            bestScore = score;
            bestExposure = exposure;
          }
        }
      }

      // 套用最佳曝光
      await controller.setExposureOffset(bestExposure);
      print("最佳曝光值: $bestExposure, 分數: $bestScore");

    } catch (e) {
      print("自動曝光調整失敗: $e");
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
            child: RepaintBoundary(
              key: previewKey,
              child: ColorFiltered(
                colorFilter: _getColorFilterForSelected(_filter) ??
                    const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                child: GestureDetector(
                  onScaleStart: (details) {
                    _baseZoomLevel = _currentZoomLevel;
                  },
                  onScaleUpdate: (details) async {
                    double newZoom = (_baseZoomLevel * details.scale)
                        .clamp(_minZoomLevel, _maxZoomLevel);
                    setState(() {
                      _currentZoomLevel = newZoom;
                    });
                    await controller.setZoomLevel(newZoom);
                  },
                  child: CameraPreviewWidget(controller: controller),
                ),
              ),
            ),
          ),
          // 🔍 底部顯示當前倍率的小黑框
          Positioned(
            bottom: 100,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${_currentZoomLevel.toStringAsFixed(1)}x",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          if (_poseImageBytes != null && checkPose == true)
            Positioned.fill(
              child: Image.memory(
                _poseImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          CompositionLines(
            composition: _composition,
            highlightIndex: isAlignmentMode ? lineIndex : null,
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 150,
              child: CameraHintText(
                hasButton: poseHint["hasButton"] == true,
                hasText: poseHint["hasText"] == true,
                textText: poseHint['textText']?.toString() ?? '',
                buttonText: poseHint['buttonText']?.toString() ?? '',
                onButtonTap: (value) async {
                  if (value == "點擊獲取姿勢建議") {
                    setState(() {
                      poseHint["hasButton"] = false;
                      poseHint["hasText"] = true;
                      poseHint["textText"] = "正在獲取姿勢建議，請稍後";
                      hint["hasButton"] = false;
                      checkPose = false;
                      _poseImageBytes = null;
                    });
                    await getPoseImage();
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              width: 150,
              child: CameraHintText(
                hasButton: hint["hasButton"] == true,
                hasText: hint["hasText"] == true,
                textText: hint['textText']?.toString() ?? '',
                buttonText: hint['buttonText']?.toString() ?? '',
                  onButtonTap: (value) async {
                    if (value == "點擊獲取構圖推薦") {
                      setState(() {
                        hint["hasButton"] = false;
                        hint["hasText"] = true;
                        poseHint["hasButton"] = false;
                        hint["textText"] = "正在獲取最佳構圖，請稍後";
                      });

                      await getComposition();
                    } else if (value == "套用") {
                      startAlignmentMode();
                    } else if (value == "我對好了") {
                      await onUserConfirmLine();
                      setState(() {
                        poseHint["hasButton"] = true;
                      });
                    } else if (value == "拍照") {
                      await onFinalCapture();
                    }
                  },
                ),
            ),
          ),
          CameraControlsWidget(
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
