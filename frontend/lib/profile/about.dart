import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: const [
            Text(
              '關於我們',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '我們是一個由三隻貓、一個沒睡飽的大學生、和一杯美式咖啡組成的開發團隊，'
                  '致力於創造世界上最不無聊的 App。我們的使命是讓使用者感受到科技的溫暖，'
                  '即使他們只是點開來看兩秒就關掉。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              '版本資訊',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('App 版本：v0.0.1-beta（幾乎可以用了）'),
            Text('開發狀態：持續開發中，偶爾更新，常常喝咖啡'),
            SizedBox(height: 24),
            Text(
              '聯絡我們',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('如果你有任何建議、回饋或段子想分享，歡迎寫信給我們：'),
            Text('📮 email@example.com'),
            Text('📮 或直接大喊我們的名字，我們有時候會聽到'),
          ],
        ),
      ),
    );
  }
}
