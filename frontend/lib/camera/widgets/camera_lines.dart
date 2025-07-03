import 'package:flutter/material.dart';

class CompositionLines extends StatelessWidget {
  final String composition;
  final int? highlightIndex;

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

    // 箱框樣式
    final boxPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Paint linePaint(int idx) {
      return (highlightIndex != null && highlightIndex == idx)
          ? highlightPaint
          : basePaint;
    }

    switch (composition) {
      case 'center':
        canvas.drawLine(Offset(size.width / 2, 0),
            Offset(size.width / 2, size.height), linePaint(0));
        canvas.drawLine(Offset(0, size.height / 2),
            Offset(size.width, size.height / 2), linePaint(1));

        if (highlightIndex == 0) {
          final boxWidth = size.width / 3;
          final boxHeight = size.height / 3;
          final rect = Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: boxWidth,
            height: boxHeight,
          );
          canvas.drawRect(rect, boxPaint);
        }
        break;

      case 'diagonal':
        canvas.drawLine(
            Offset(0, 0), Offset(size.width, size.height), linePaint(0));
        canvas.drawLine(
            Offset(size.width, 0), Offset(0, size.height), linePaint(1));
        break;

      case 'rule_of_thirds':
        final thirdWidth = size.width / 3;
        final thirdHeight = size.height / 3;

        canvas.drawLine(Offset(thirdWidth, 0),
            Offset(thirdWidth, size.height), linePaint(0));
        canvas.drawLine(Offset(thirdWidth * 2, 0),
            Offset(thirdWidth * 2, size.height), linePaint(1));

        canvas.drawLine(Offset(0, thirdHeight),
            Offset(size.width, thirdHeight), linePaint(2));
        canvas.drawLine(Offset(0, thirdHeight * 2),
            Offset(size.width, thirdHeight * 2), linePaint(3));

        final diagPaint = basePaint;
        canvas.drawLine(
            Offset(0, 0), Offset(size.width, size.height), diagPaint);
        canvas.drawLine(
            Offset(size.width, 0), Offset(0, size.height), diagPaint);

        final crossPoints = [
          Offset(thirdWidth, thirdHeight),
          Offset(thirdWidth * 2, thirdHeight),
          Offset(thirdWidth, thirdHeight * 2),
          Offset(thirdWidth * 2, thirdHeight * 2),
        ];

        if (highlightIndex != null &&
            highlightIndex! >= 0 &&
            highlightIndex! < crossPoints.length) {
          final point = crossPoints[highlightIndex!];
          final boxSize = 40.0;
          final rect =
          Rect.fromCenter(center: point, width: boxSize, height: boxSize);
          canvas.drawRect(rect, boxPaint);
        }
        break;

      case 'vertical':
        final x1 = size.width / 3;
        final x2 = size.width * 2 / 3;
        canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), linePaint(0));
        canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), linePaint(1));

        final centers = [
          Offset(x1, size.height / 2),
          Offset(x2, size.height / 2),
        ];

        if (highlightIndex != null && highlightIndex! < centers.length) {
          final rect = Rect.fromCenter(
              center: centers[highlightIndex!], width: 60, height: 120);
          canvas.drawRect(rect, boxPaint);
        }
        break;

      case 'horizontal':
        final y1 = size.height / 3;
        final y2 = size.height * 2 / 3;
        canvas.drawLine(Offset(0, y1), Offset(size.width, y1), linePaint(0));
        canvas.drawLine(Offset(0, y2), Offset(size.width, y2), linePaint(1));

        final centers = [
          Offset(size.width / 2, y1),
          Offset(size.width / 2, y2),
        ];

        if (highlightIndex != null && highlightIndex! < centers.length) {
          final rect = Rect.fromCenter(
              center: centers[highlightIndex!], width: 120, height: 60);
          canvas.drawRect(rect, boxPaint);
        }
        break;

      case 'symmetric':
        final quarterWidth = size.width / 4;
        final quarterHeight = size.height / 4;

        canvas.drawLine(Offset(quarterWidth, 0),
            Offset(quarterWidth, size.height), linePaint(0));
        canvas.drawLine(Offset(quarterWidth * 3, 0),
            Offset(quarterWidth * 3, size.height), linePaint(1));

        canvas.drawLine(Offset(0, quarterHeight),
            Offset(size.width, quarterHeight), linePaint(2));
        canvas.drawLine(Offset(0, quarterHeight * 3),
            Offset(size.width, quarterHeight * 3), linePaint(3));
        break;

      case 'triangle':
        final radius = 20.0;
        final point1 = Offset(size.width * 0.5, size.height * 0.25);
        final point2 = Offset(size.width * 0.25, size.height * 0.75);
        final point3 = Offset(size.width * 0.75, size.height * 0.75);

        canvas.drawCircle(point1, radius, basePaint);
        canvas.drawCircle(point2, radius, basePaint);
        canvas.drawCircle(point3, radius, basePaint);
        break;

      case 'vanishing_point':
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
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CompositionPainter oldDelegate) {
    return oldDelegate.composition != composition ||
        oldDelegate.highlightIndex != highlightIndex;
  }
}
