


import 'package:flutter/material.dart';
import './bottom_bar.dart';
import './menu_item.dart';

Future<String?> showFilterMenu(BuildContext context, {String? selectedLabel}) {
  final filterItems = [
    const MenuItem(imagePath: 'assets/filters/black_white.png', label: 'none', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/black_white.png', label: '黑白', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/nostalgic.png', label: 'vintage', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/hdr.png', label: 'HDR', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/japanese.png', label: '日系', shape: ImageShape.square),
  ];

  int selectedIndex = 0;
  if (selectedLabel != null) {
    final index = filterItems.indexWhere((item) => item.label == selectedLabel);
    if (index != -1) selectedIndex = index;
  }

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    builder: (_) {
      return BottomBar(
        title: '濾鏡選擇',
        items: filterItems,
        selectedIndex: selectedIndex,
      );
    },
  );
}
