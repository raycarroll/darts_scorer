import 'dart:math';
import 'package:flutter/material.dart';

class DartboardPainter extends CustomPainter {
  static const List<int> dartboardSequence = [
    20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Radii for different zones
    final innerBullRadius = radius * 0.04;
    final outerBullRadius = radius * 0.08;
    final tripleInnerRadius = radius * 0.54;
    final tripleOuterRadius = radius * 0.62;
    final doubleInnerRadius = radius * 0.92;
    final doubleOuterRadius = radius;

    // Draw segments
    for (int i = 0; i < 20; i++) {
      // Adjust angle so 20 is at top (-90 degrees)
      final startAngle = (-99 + i * 18) * pi / 180; // -99 = -90 - 9 (start 9 degrees before center)
      final endAngle = (-81 + i * 18) * pi / 180;   // -81 = -90 + 9 (end 9 degrees after center)

      // Alternate colors (black/white for singles, red/green for scores)
      final isEven = i % 2 == 0;
      final scoreColor = isEven ? Colors.black : Colors.white;
      final altColor = isEven ? Colors.white : Colors.black;

      // Draw single zone
      _drawSegment(canvas, center, tripleOuterRadius, doubleInnerRadius,
          startAngle, endAngle, scoreColor);

      // Draw triple zone
      _drawSegment(canvas, center, tripleInnerRadius, tripleOuterRadius,
          startAngle, endAngle, isEven ? Colors.red : Colors.green);

      // Draw single inner zone
      _drawSegment(canvas, center, outerBullRadius, tripleInnerRadius,
          startAngle, endAngle, altColor);

      // Draw double zone
      _drawSegment(canvas, center, doubleInnerRadius, doubleOuterRadius,
          startAngle, endAngle, isEven ? Colors.red : Colors.green);

      // Draw number (center of segment)
      final number = dartboardSequence[i];
      final textAngle = (-90 + i * 18) * pi / 180; // Center angle for this segment
      final textRadius = radius * 1.15;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: number.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // Draw outer bull (25)
    canvas.drawCircle(center, outerBullRadius, Paint()..color = Colors.green);

    // Draw inner bull (50)
    canvas.drawCircle(center, innerBullRadius, Paint()..color = Colors.red);

    // Draw border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawSegment(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double outerRadius,
    double startAngle,
    double endAngle,
    Color color,
  ) {
    final path = Path();
    path.moveTo(
      center.dx + innerRadius * cos(startAngle),
      center.dy + innerRadius * sin(startAngle),
    );
    path.arcTo(
      Rect.fromCircle(center: center, radius: outerRadius),
      startAngle,
      endAngle - startAngle,
      false,
    );
    path.lineTo(
      center.dx + innerRadius * cos(endAngle),
      center.dy + innerRadius * sin(endAngle),
    );
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      endAngle,
      -(endAngle - startAngle),
      false,
    );
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
