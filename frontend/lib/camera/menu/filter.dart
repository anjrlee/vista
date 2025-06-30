import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'menu_item.dart';

void showFilterMenu(BuildContext context) {
  final filterItems = [
    const MenuItem(imagePath: 'assets/filters/black_white.png', label: 'none', shape: ImageShape.circle),
    const MenuItem(imagePath: 'assets/filters/black_white.png', label: '黑白', shape: ImageShape.circle),
    const MenuItem(imagePath: 'assets/filters/nostalgic.png', label: '懷舊', shape: ImageShape.circle),
    const MenuItem(imagePath: 'assets/filters/hdr.png', label: 'HDR', shape: ImageShape.circle),
    const MenuItem(imagePath: 'assets/filters/japanese.png', label: '日系', shape: ImageShape.circle),
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    builder: (_) {
      return BottomBar(
        title: '濾鏡選擇',
        items: filterItems,
      );
    },
  );
}
