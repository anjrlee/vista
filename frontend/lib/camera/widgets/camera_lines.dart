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
      // 繪製中心十字線
        canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
        canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
        break;

      case 'diagonal':
      // 繪製兩條對角線
        canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
        canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
        break;

      case 'rule_of_thirds':

        final thirdWidth = size.width / 3;
        final thirdHeight = size.height / 3;

        // 垂直九宮格線
        canvas.drawLine(Offset(thirdWidth, 0), Offset(thirdWidth, size.height), paint);
        canvas.drawLine(Offset(thirdWidth * 2, 0), Offset(thirdWidth * 2, size.height), paint);

        // 水平九宮格線
        canvas.drawLine(Offset(0, thirdHeight), Offset(size.width, thirdHeight), paint);
        canvas.drawLine(Offset(0, thirdHeight * 2), Offset(size.width, thirdHeight * 2), paint);

        // 斜線（對角線）
        canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
        canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
        break;

    }
  }

  @override
  bool shouldRepaint(covariant _CompositionPainter oldDelegate) {
    return oldDelegate.composition != composition;
  }
}
