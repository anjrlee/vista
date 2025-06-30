import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'menu_item.dart';

void showCompositionMenu(BuildContext context) {
  final compositionItems = [
    const MenuItem(imagePath: 'assets/filters/black_white.png', label: 'none', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/black_white.png', label: '黑白', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/nostalgic.png', label: '懷舊', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/hdr.png', label: 'HDR', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/filters/japanese.png', label: '日系', shape: ImageShape.square),
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    builder: (_) {
      return BottomBar(
        title: '構圖選擇',
        items: compositionItems,
      );
    },
  );
}
