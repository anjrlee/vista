import 'package:flutter/material.dart';
import 'featureCard.dart';
import 'photoScore.dart';


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
      'showLock':true,
      'onTap':''
    },
    {
      'title': '本日推薦',
      'imageUrls': [
        'assets/featureCard/recommendation1.jpg',
        'assets/featureCard/recommendation2.jpg',
        'assets/featureCard/recommendation3.jpg',
        'assets/featureCard/recommendation4.jpg',
      ],
      'isMultiPhoto': true,
      'showLock':false,
      'onTap':''
    },
    {
      'title': 'Tutorial',
      'imageUrls': [
        'assets/featureCard/tutorial.jpg',
      ],
      'isMultiPhoto': false,
      'showLock':true,
      'onTap':''
    },
    {
      'title': '上傳照片分析',
      'imageUrls': [
        'assets/featureCard/photoAnalyze.png',
      ],
      'isMultiPhoto': false,
      'showLock':false,
      'onTap':() => const PhotoScore()
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
                    showLock: item['showLock'],
                      onTap: () {
                        if (item['onTap'] == '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item['title']} 尚未解鎖')),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => item['onTap'](), // 呼叫函數產生 widget
                            ),
                          );
                        }
                      }

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
