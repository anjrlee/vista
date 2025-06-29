import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqList = [
      {
        'question': 'Q: 為什麼我打開 App 一片空白？',
        'answer': 'A: 請確保你有打開眼睛，或是打開手機螢幕。'
      },
      {
        'question': 'Q: 會員有什麼特別功能嗎？',
        'answer': 'A: 成為會員後，我們會對你微笑，並提供尊貴的虛擬擁抱。'
      },
      {
        'question': 'Q: 資料會不會外洩？',
        'answer': 'A: 除非你的貓會駭客技術，不然我們基本上守得住。'
      },
      {
        'question': 'Q: 怎麼聯絡你們？',
        'answer': 'A: 可以用意念呼喚我們，或者直接寄信到：fake@email.com'
      },
      {
        'question': 'Q: 為什麼叫這個名字？',
        'answer': 'A: 當初取名的時候是星期一早上，創意尚未甦醒，就這樣了。'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: ListView.builder(
        itemCount: faqList.length,
        itemBuilder: (context, index) {
          final item = faqList[index];
          return ExpansionTile(
            title: Text(item['question'] ?? ''),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(item['answer'] ?? ''),
              ),
            ],
          );
        },
      ),
    );
  }
}
