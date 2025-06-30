import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('歡迎，${account.displayName}!')),
        );
        // TODO: 導向首頁或儲存登入狀態
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登入失敗: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text(
              '登入你的帳號',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '''
              使用 Google 帳號快速登入，
              體驗完整功能與個人化設定。
              ''',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: const BorderSide(color: Colors.black12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _handleSignIn,
              icon: Image.asset(
                'assets/photo_icon/google_logo.png',
                height: 24,
              ),
              label: const Text('用 Google 登入'),
            ),
            const SizedBox(height: 60),
            const Text('登入代表你同意我們的 使用條款 與 隱私政策。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}