import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? message;
  bool loading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    postHello();
  }

  Future<void> postHello() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final url = Uri.parse('http://localhost:8000/hello');
      final response = await http.post(url, body: jsonEncode({}), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          message = data['message'] ?? 'No message in response';
        });
      } else {
        setState(() {
          error = '錯誤: HTTP ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = '錯誤: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error.isNotEmpty
            ? Text(error, style: TextStyle(color: Colors.red))
            : Text(
          message ?? '無資料',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
