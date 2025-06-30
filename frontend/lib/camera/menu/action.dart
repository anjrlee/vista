import 'package:flutter/material.dart';
import './bottom_bar.dart';
import './menu_item.dart';

Future<String?> showActionMenu(BuildContext context, {String? selectedLabel}) {
  final ActionItems = [
    const MenuItem(imagePath: 'assets/filters/rule_of_thirds.png', label: 'none', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/rule_of_thirds.png', label: 'fly', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/center.png', label: 'dance', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/diagonal.png', label: 'cry', shape: ImageShape.square),
  ];

  int selectedIndex = 0;
  if (selectedLabel != null) {
    final index = ActionItems.indexWhere((item) => item.label == selectedLabel);
    if (index != -1) selectedIndex = index;
  }

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    builder: (_) {
      return BottomBar(
        title: '姿勢選擇',
        items: ActionItems,
        selectedIndex: selectedIndex,
      );
    },
  );
}
