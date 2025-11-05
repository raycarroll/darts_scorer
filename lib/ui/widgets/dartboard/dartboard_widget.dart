import 'dart:math';
import 'package:flutter/material.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'dartboard_painter.dart';

class DartThrow {
  final int zone;
  final Multiplier multiplier;

  DartThrow({required this.zone, required this.multiplier});
}

class DartboardWidget extends StatelessWidget {
  final Function(DartThrow) onDartThrown;
  final double size;

  const DartboardWidget({
    Key? key,
    required this.onDartThrown,
    this.size = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) => _handleTap(details.localPosition),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: DartboardPainter(),
        ),
      ),
    );
  }

  void _handleTap(Offset localPosition) {
    final center = Offset(size / 2, size / 2);
    final radius = size / 2;

    // Calculate distance from center
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    // Calculate angle (0 = right, counter-clockwise)
    var angle = atan2(dy, dx) * 180 / pi;
    // Adjust so 0 is at top
    angle = (angle + 90) % 360;
    if (angle < 0) angle += 360;

    // Determine zone and multiplier
    final dartThrow = _calculateDartThrow(distance / radius, angle);
    if (dartThrow != null) {
      onDartThrown(dartThrow);
    }
  }

  DartThrow? _calculateDartThrow(double normalizedDistance, double angle) {
    // Define zone boundaries (normalized to radius = 1.0)
    const innerBull = 0.04;
    const outerBull = 0.08;
    const tripleInner = 0.54;
    const tripleOuter = 0.62;
    const doubleInner = 0.92;
    const doubleOuter = 1.0;

    // Bulls
    if (normalizedDistance <= innerBull) {
      return DartThrow(zone: 25, multiplier: Multiplier.innerBull);
    }
    if (normalizedDistance <= outerBull) {
      return DartThrow(zone: 25, multiplier: Multiplier.outerBull);
    }

    // Outside dartboard
    if (normalizedDistance > doubleOuter) {
      return DartThrow(zone: 0, multiplier: Multiplier.single); // Miss
    }

    // Determine zone number (1-20) based on angle
    final segmentAngle = 360.0 / 20; // 18 degrees per segment
    final segmentIndex = ((angle + segmentAngle / 2) % 360) ~/ segmentAngle;
    final zone = DartboardPainter.dartboardSequence[segmentIndex % 20];

    // Determine multiplier based on distance
    Multiplier multiplier;
    if (normalizedDistance >= doubleInner && normalizedDistance <= doubleOuter) {
      multiplier = Multiplier.double;
    } else if (normalizedDistance >= tripleInner && normalizedDistance <= tripleOuter) {
      multiplier = Multiplier.triple;
    } else {
      multiplier = Multiplier.single;
    }

    return DartThrow(zone: zone, multiplier: multiplier);
  }
}
