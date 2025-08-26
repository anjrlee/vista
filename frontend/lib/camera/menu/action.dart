import 'package:flutter/material.dart';
import './bottom_bar.dart';
import './menu_item.dart';

Future<String?> showActionMenu(BuildContext context, {String? selectedLabel}) {
  final ActionItems = [
    const MenuItem(
      imagePath: 'assets/pose_black/none.png', // 你可以放一張空白圖或特殊圖
      label: 'none',
      shape: ImageShape.square,
    ),
    ...List.generate(1681 - 1658 + 1, (index) {
      final number = 1658 + index;
      final fileName = 'IMG_${number}-removebg-preview.png';
      return MenuItem(
        imagePath: 'assets/pose_black/$fileName',
        label: 'pose${index + 1}',
        shape: ImageShape.square,
      );
    }),
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
