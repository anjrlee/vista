import 'package:flutter/material.dart';
import 'featureCard.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> items = [
    {
      'title': '新增我的動作',
      'imageUrls': ['assets/featureCard/pose.png',],
      'isMultiPhoto': false,
    },
    {
      'title': '本日推薦',
      'imageUrls': ['assets/featureCard/google_logo.png',],
      'isMultiPhoto': true,
    },
    {
      'title': 'Tutorial',
      'imageUrls': [
        'assets/featureCard/tutorial.jpg',
      ],
      'isMultiPhoto': false,
    },
    {
      'title': '上傳照片分析',
      'imageUrls': [
        'assets/featureCard/photoAnalyze.png',
      ],
      'isMultiPhoto': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Text(
                '歡迎使用',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: items.map((item) {
                  return FeatureCard(
                    imageUrls: item['imageUrls'],
                    title: item['title'],
                    isMultiPhoto: item['isMultiPhoto'],
                    showLock: item['title'] != '本日推薦',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item['title']} 尚未解鎖')),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
