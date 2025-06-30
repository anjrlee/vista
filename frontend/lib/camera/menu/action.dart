import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'menu_item.dart';

void showActionMenu(BuildContext context) {
  final actionItems = [
    const MenuItem(imagePath: 'assets/filters/black_white.png', label: '黑白', shape: ImageShape.roundedRect),
    const MenuItem(imagePath: 'assets/filters/nostalgic.png', label: '懷舊', shape: ImageShape.roundedRect),
    const MenuItem(imagePath: 'assets/filters/hdr.png', label: 'HDR', shape: ImageShape.roundedRect),
    const MenuItem(imagePath: 'assets/filters/japanese.png', label: '日系', shape: ImageShape.roundedRect),
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    builder: (_) {
      return BottomBar(
        title: '動作選擇',
        items: actionItems,
      );
    },
  );
}
