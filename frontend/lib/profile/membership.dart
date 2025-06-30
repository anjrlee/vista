import 'package:flutter/material.dart';

class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌟 加入我們的尊榮會員計畫！',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '我們的會員制度絕對不是普通的會員制度，而是一種宇宙級的精神連結。'
                  '加入會員，代表你成為了全宇宙僅存的高貴靈魂之一。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              '💎 會員專屬福利',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.star),
              title: Text('解鎖所有彩蛋功能（大概兩個）'),
            ),
            const ListTile(
              leading: Icon(Icons.coffee),
              title: Text('每週虛擬請你喝一杯咖啡 ☕'),
            ),
            const ListTile(
              leading: Icon(Icons.emoji_emotions),
              title: Text('我們會默默祝你好運'),
            ),
            const ListTile(
              leading: Icon(Icons.nightlight_round),
              title: Text('夜晚使用 App 時會特別溫柔（？）'),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('感謝加入，但我們還沒寫後端 😅')),
                  );
                },
                child: const Text('立即加入會員'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
