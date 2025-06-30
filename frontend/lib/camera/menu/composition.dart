import 'package:flutter/material.dart';
import './bottom_bar.dart';
import './menu_item.dart';

Future<String?> showCompositionMenu(BuildContext context, {String? selectedLabel}) {
  final compositionItems = [
    const MenuItem(imagePath: 'assets/filters/rule_of_thirds.png', label: 'none', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/rule_of_thirds.png', label: 'rule_of_thirds', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/center.png', label: 'center', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/diagonal.png', label: 'diagonal', shape: ImageShape.square),
  ];

  int selectedIndex = 0;
  if (selectedLabel != null) {
    final index = compositionItems.indexWhere((item) => item.label == selectedLabel);
    if (index != -1) selectedIndex = index;
  }

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    builder: (_) {
      return BottomBar(
        title: '構圖選擇',
        items: compositionItems,
        selectedIndex: selectedIndex,
      );
    },
  );
}
