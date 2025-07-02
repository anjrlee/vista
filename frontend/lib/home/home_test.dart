import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = false;
  String error = '';
  String? message;

  @override
  void initState() {
    super.initState();
    fetchTestMessage(); // ✅ 一進來就自動抓 /test
  }

  Future<void> fetchTestMessage() async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      setState(() {
        error = '❌ 未設定 API_BASE_URL';
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
      message = null;
    });

    try {
      final url = Uri.parse('$baseUrl/test');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          message = data['message'] ?? '成功但沒有 message 欄位';
        });
      } else {
        setState(() {
          error = '❌ 錯誤代碼：${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = '❌ 發生例外：$e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> postTestFirebase() async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return;

    final url = Uri.parse('$baseUrl/testFirebase');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}), // 你可以加上資料
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 已成功寫入 Firebase')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 失敗：${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 發送錯誤：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const CircularProgressIndicator()
            else if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red))
            else
              Text(
                message ?? '無資料',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: postTestFirebase,
              child: const Text('testFirebase（寫入日期）'),
            ),
          ],
        ),
      ),
    );
  }
}