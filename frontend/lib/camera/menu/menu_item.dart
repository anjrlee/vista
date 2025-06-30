import 'package:flutter/material.dart';

enum ImageShape { circle, roundedRect, square }

class MenuItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final ImageShape shape;

  const MenuItem({
    Key? key,
    required this.imagePath,
    required this.label,
    this.shape = ImageShape.roundedRect, // 預設用圓角矩形
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    switch (shape) {
      case ImageShape.circle:
        imageWidget = ClipOval(
          child: Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
        break;
      case ImageShape.roundedRect:
        imageWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
        break;
      case ImageShape.square:
        imageWidget = Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
        break;
    }

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageWidget,
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
