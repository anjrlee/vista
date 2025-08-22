import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';

class NewAction extends StatefulWidget {
  const NewAction({Key? key}) : super(key: key);

  @override
  _NewActionState createState() => _NewActionState();
}

class _NewActionState extends State<NewAction> {
  File? _selectedImage;
  Uint8List? _processedImageBytes;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _processedImageBytes = null; // 重置分析結果
      });
    }
  }

  Future<void> _analyzeAndUpload() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse("${dotenv.env['API_BASE_URL']}/analyzePose");
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // 後端接收的欄位名稱
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _processedImageBytes = response.bodyBytes;
        });

        // 顯示對話框
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("照片已新增"),
              content: _processedImageBytes != null
                  ? Image.memory(_processedImageBytes!, height: 200, fit: BoxFit.cover)
                  : const SizedBox.shrink(),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("確認"),
                ),
              ],
            );
          },
        );
      } else {
        debugPrint("Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Upload error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("上傳與分析照片")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 選取的原始照片
                if (_selectedImage != null)
                  Image.file(_selectedImage!, height: 200, fit: BoxFit.cover),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("選擇照片"),
                ),

                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _analyzeAndUpload,
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text("分析動作並新增"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
