import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class PhotoScore extends StatefulWidget {
  const PhotoScore({Key? key}) : super(key: key);

  @override
  _PhotoScoreState createState() => _PhotoScoreState();
}

class _PhotoScoreState extends State<PhotoScore> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final String _uploadUrl = '${dotenv.env['API_BASE_URL']}/aestheticScoreFunction';

  final List<String> _comments = [
    "構圖上運用對角線引導視覺，光線均勻柔和，主體在背景中處於視覺核心，站位突出，效果非常傑出！",
    "構圖具備框架且光線充足，但主體偏右且靠近邊緣，影響視覺平衡，建議調整主體位置以符合三分法。",
    "構圖缺乏明確主體，整體光線不足且雜亂，未能清晰突出任何一個焦點，建議重新取景並確保充足光線。",
  ];

  // 分數縮放函數：將 4-6.5 映射到 0-10
  double _scaleScore(double originalScore) {
    double scaledScore = (originalScore - 4.0) * 4.0;
    return scaledScore.clamp(0.0, 10.0);
  }

  double _roundToHalfStar(double rating) {
    return (rating * 2).round() / 2.0;
  }

  // 將 0-10 分數轉換為 0-5 星級
  double _convertToStars(double scaledScore) {
    return (scaledScore / 10.0) * 5.0;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAndScore() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // 如需額外參數，可在此添加
      request.fields['line_index'] = '1';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final String body = response.body;
        final double originalScore = double.parse(body);
        
        // 縮放分數並轉換為星級
        final double scaledScore = _scaleScore(originalScore);
        final double starRating = _convertToStars(scaledScore);

        final String randomComment = _selectRandomComment(scaledScore);


        _showResult(originalScore, scaledScore, starRating, randomComment);
      } else {
        _showError('上傳失敗，狀態碼: ${response.statusCode}');
      }
    } catch (e) {
      _showError('錯誤: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

String _selectRandomComment(double scaledScore) {
    // 簡單邏輯：根據分數區間使用不同的評語或直接隨機
    final int index;
    if (scaledScore >= 7.8) { // 7.8-10 分 -> 第一條
      index = 0;
    } else if (scaledScore >= 5.5) { // 5.5-7.8 分 -> 第二條
      index = 1;
    } else { // 0-5.5 分 -> 第三條
      index = 2;
    }
    
    return _comments[index];
  }


  // 建立星星評分 Widget
  Widget _buildStarRating(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    double remainder = rating - fullStars;
    
    // 填滿的星星
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(
        Icons.star,
        color: Colors.amber,
        size: 32,
      ));
    }
    
    // 半顆星
    if (remainder >= 0.5) {
      stars.add(const Icon(
        Icons.star_half,
        color: Colors.amber,
        size: 32,
      ));
      fullStars++;
    }
    
    // 空心星星
    for (int i = fullStars; i < 5; i++) {
      stars.add(const Icon(
        Icons.star_border,
        color: Colors.amber,
        size: 32,
      ));
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }

  void _showResult(double originalScore, double scaledScore, double starRating, String randomComment) {
    // double decimalPart = starRating - starRating.truncate();
    // int firstDigit = (decimalPart * 10).toInt();

    // if (firstDigit >= 5) {
    //   starRating = starRating.truncateToDouble() + 0.5;
    // } else {
    //   starRating = starRating.truncateToDouble();
    // }
    final double displayStarRating = _roundToHalfStar(starRating);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('評分結果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStarRating(displayStarRating),
            const SizedBox(height: 8),
            Text(
              '評分: ${displayStarRating.toStringAsFixed(1)} / 5',
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              '評語:',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              randomComment,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('照片評分'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('點擊上傳照片'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _image != null ? _uploadAndScore : null,
              child: const Text('送出並評分'),
            ),
          ],
        ),
      ),
    );
  }
}