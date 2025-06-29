import 'package:flutter/material.dart';
import 'menu_item.dart';

class BottomBar extends StatelessWidget {
  final String title;
  final List<MenuItem> items;

  const BottomBar({
    super.key,
    this.title = '',
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: items,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
