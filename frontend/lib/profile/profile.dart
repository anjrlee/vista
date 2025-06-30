import 'package:flutter/material.dart';
import 'login.dart';
import 'membership.dart';
import 'about.dart';
import 'FAQ.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final String? userName = null; // 模擬未登入，實際可用Provider等取得帳號資訊
  final String? avatarUrl = null; // 頭像可替換為網址或 assets 圖片

  void _onTap(BuildContext context, String title) {
    switch (title) {
      case 'Login':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
        break;
      case 'Get Membership':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MembershipPage()));
        break;
      case 'About':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
        break;
      case 'FAQ':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQPage()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped: $title')));
    }
  }


  @override
  Widget build(BuildContext context) {
    final isLoggedIn = userName != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () => _onTap(context, isLoggedIn ? 'Profile Info' : 'Login'),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : const AssetImage('assets/avatar_placeholder.png')
                    as ImageProvider,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, size: 32, color: Colors.white)
                        : null,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    userName ?? 'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLoggedIn ? Colors.black : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: const Text('Get Membership'),
            onTap: () => _onTap(context, 'Get Membership'),
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => _onTap(context, 'About'),
          ),

          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQ'),
            onTap: () => _onTap(context, 'FAQ'),
          ),

          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () => _onTap(context, 'Login'),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Color Theme'),
            onTap: () => _onTap(context, 'Color Theme'),
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () => _onTap(context, 'Language'),
          ),
        ],
      ),
    );
  }
}
