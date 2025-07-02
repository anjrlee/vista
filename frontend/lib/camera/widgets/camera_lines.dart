import 'package:flutter/material.dart';

class CompositionLines extends StatelessWidget {
  final String composition;

  const CompositionLines({super.key, required this.composition});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _CompositionPainter(composition),
      ),
    );
  }
}

class _CompositionPainter extends CustomPainter {
  final String composition;
  _CompositionPainter(this.composition);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1;

    switch (composition) {
      case 'center':
      // 中心十字線
        canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
        canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
        break;

      case 'diagonal':
      // 對角線
        canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
        canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
        break;

      case 'rule_of_thirds':
        final thirdWidth = size.width / 3;
        final thirdHeight = size.height / 3;

        // 垂直線
        canvas.drawLine(Offset(thirdWidth, 0), Offset(thirdWidth, size.height), paint);
        canvas.drawLine(Offset(thirdWidth * 2, 0), Offset(thirdWidth * 2, size.height), paint);

        // 水平線
        canvas.drawLine(Offset(0, thirdHeight), Offset(size.width, thirdHeight), paint);
        canvas.drawLine(Offset(0, thirdHeight * 2), Offset(size.width, thirdHeight * 2), paint);

        // 對角線
        canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
        canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
        break;

      case 'vertical':
      // 垂直構圖：左1/3與右2/3
        final x1 = size.width / 3;
        final x2 = size.width * 2 / 3;
        canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), paint);
        canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), paint);
        break;

      case 'horizontal':
      // 水平構圖：上1/3與下2/3
        final y1 = size.height / 3;
        final y2 = size.height * 2 / 3;
        canvas.drawLine(Offset(0, y1), Offset(size.width, y1), paint);
        canvas.drawLine(Offset(0, y2), Offset(size.width, y2), paint);
        break;

      case 'symmetric':
      // 對稱構圖：上下左右各一條線（畫面四分）
        final quarterWidth = size.width / 4;
        final quarterHeight = size.height / 4;

        // 左右線
        canvas.drawLine(Offset(quarterWidth, 0), Offset(quarterWidth, size.height), paint);
        canvas.drawLine(Offset(quarterWidth * 3, 0), Offset(quarterWidth * 3, size.height), paint);

        // 上下線
        canvas.drawLine(Offset(0, quarterHeight), Offset(size.width, quarterHeight), paint);
        canvas.drawLine(Offset(0, quarterHeight * 3), Offset(size.width, quarterHeight * 3), paint);
        break;


      case 'triangle':
      // 三角形上的三個圓圈圈
        final radius = 20.0;
        final point1 = Offset(size.width * 0.5, size.height * 0.25); // 上中
        final point2 = Offset(size.width * 0.25, size.height * 0.75); // 左下
        final point3 = Offset(size.width * 0.75, size.height * 0.75); // 右下

        canvas.drawCircle(point1, radius, paint);
        canvas.drawCircle(point2, radius, paint);
        canvas.drawCircle(point3, radius, paint);
        break;

      case 'vanishing_point':
      // 消失點構圖：從畫面四邊向中心點畫線
        final center = Offset(size.width / 2, size.height / 2);

        // 邊角線
        canvas.drawLine(Offset(0, 0), center, paint);
        canvas.drawLine(Offset(size.width, 0), center, paint);
        canvas.drawLine(Offset(0, size.height), center, paint);
        canvas.drawLine(Offset(size.width, size.height), center, paint);

        // 邊線中點
        canvas.drawLine(Offset(size.width / 2, 0), center, paint); // 上中
        canvas.drawLine(Offset(size.width / 2, size.height), center, paint); // 下中
        canvas.drawLine(Offset(0, size.height / 2), center, paint); // 左中
        canvas.drawLine(Offset(size.width, size.height / 2), center, paint); // 右中
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CompositionPainter oldDelegate) {
    return oldDelegate.composition != composition;
  }
}