import 'package:flutter/material.dart';
import './bottom_bar.dart';
import './menu_item.dart';


Future<String?> showCompositionMenu(BuildContext context, {String? selectedLabel}) {
  final compositionItems = [
    const MenuItem(imagePath: 'assets/composition/none.png', label: 'none', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/composition/center.png', label: 'center', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/composition/diagonal.png', label: 'diagonal', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/composition/horizontal.png', label: 'horizontal', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/composition/symmetric.png', label: 'symmetric', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/composition/rule_of_thirds.png', label: 'rule_of_thirds', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/composition/vertical.png', label: 'vertical', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/composition/triangle.png', label: 'triangle', shape: ImageShape.square),
    const MenuItem(imagePath: 'assets/composition/vanishing_point.png', label: 'vanishing_point', shape: ImageShape.square),
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
