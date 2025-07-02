import 'package:flutter/material.dart';

class CompositionLines extends StatelessWidget {
  final String composition;
  final int? highlightIndex; // 新增：指定要高亮（紅色）的線條索引

  const CompositionLines({
    super.key,
    required this.composition,
    this.highlightIndex,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _CompositionPainter(composition, highlightIndex),
      ),
    );
  }
}

class _CompositionPainter extends CustomPainter {
  final String composition;
  final int? highlightIndex;

  _CompositionPainter(this.composition, this.highlightIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1;

    final highlightPaint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..strokeWidth = 2;

    // 依據線條索引決定要用哪個 Paint
    Paint linePaint(int idx) {
      return (highlightIndex != null && highlightIndex == idx) ? highlightPaint : basePaint;
    }

    switch (composition) {
      case 'center':
      // 中心十字線，兩條線，索引0跟1
        canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), linePaint(0));
        canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint(1));
        break;

      case 'diagonal':
      // 對角線，兩條線，索引0跟1
        canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), linePaint(0));
        canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), linePaint(1));
        break;

      case 'rule_of_thirds':
      // 四條線，0、1為垂直，2、3為水平
        final thirdWidth = size.width / 3;
        final thirdHeight = size.height / 3;

        canvas.drawLine(Offset(thirdWidth, 0), Offset(thirdWidth, size.height), linePaint(0));
        canvas.drawLine(Offset(thirdWidth * 2, 0), Offset(thirdWidth * 2, size.height), linePaint(1));

        canvas.drawLine(Offset(0, thirdHeight), Offset(size.width, thirdHeight), linePaint(2));
        canvas.drawLine(Offset(0, thirdHeight * 2), Offset(size.width, thirdHeight * 2), linePaint(3));

        // 這裡不高亮對角線，保持白色
        final diagPaint = basePaint;
        canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), diagPaint);
        canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), diagPaint);
        break;

      case 'vertical':
      // 兩條線，索引0、1
        final x1 = size.width / 3;
        final x2 = size.width * 2 / 3;
        canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), linePaint(0));
        canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), linePaint(1));
        break;

      case 'horizontal':
      // 兩條線，索引0、1
        final y1 = size.height / 3;
        final y2 = size.height * 2 / 3;
        canvas.drawLine(Offset(0, y1), Offset(size.width, y1), linePaint(0));
        canvas.drawLine(Offset(0, y2), Offset(size.width, y2), linePaint(1));
        break;

      case 'symmetric':
      // 四條線，左右兩條 0、1，上下兩條 2、3
        final quarterWidth = size.width / 4;
        final quarterHeight = size.height / 4;

        canvas.drawLine(Offset(quarterWidth, 0), Offset(quarterWidth, size.height), linePaint(0));
        canvas.drawLine(Offset(quarterWidth * 3, 0), Offset(quarterWidth * 3, size.height), linePaint(1));

        canvas.drawLine(Offset(0, quarterHeight), Offset(size.width, quarterHeight), linePaint(2));
        canvas.drawLine(Offset(0, quarterHeight * 3), Offset(size.width, quarterHeight * 3), linePaint(3));
        break;

      case 'triangle':
      // 三個圓圈沒有線條索引，全部同色
        final radius = 20.0;
        final point1 = Offset(size.width * 0.5, size.height * 0.25);
        final point2 = Offset(size.width * 0.25, size.height * 0.75);
        final point3 = Offset(size.width * 0.75, size.height * 0.75);

        canvas.drawCircle(point1, radius, basePaint);
        canvas.drawCircle(point2, radius, basePaint);
        canvas.drawCircle(point3, radius, basePaint);
        break;

      case 'vanishing_point':
      // 多條線，索引依序 0-7（8條線）
        final center = Offset(size.width / 2, size.height / 2);

        final points = [
          Offset(0, 0),
          Offset(size.width, 0),
          Offset(0, size.height),
          Offset(size.width, size.height),
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
        ];

        for (int i = 0; i < points.length; i++) {
          canvas.drawLine(points[i], center, linePaint(i));
        }
        break;

      default:
      // 不支援的構圖，不畫線
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CompositionPainter oldDelegate) {
    return oldDelegate.composition != composition || oldDelegate.highlightIndex != highlightIndex;
  }
}
