import 'package:flutter/material.dart';

class FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Bordo campo
    final fieldRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(fieldRect, paint);

    // Linea metà campo
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Cerchio centrale
    const circleRadius = 40.0;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), circleRadius, paint);

    // Area di rigore
    final boxWidth = size.width * 0.6;
    final boxHeight = size.height * 0.15;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, boxHeight / 2),
        width: boxWidth,
        height: boxHeight,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - boxHeight / 2),
        width: boxWidth,
        height: boxHeight,
      ),
      paint,
    );

    // Area porta
    final goalWidth = size.width * 0.3;
    final goalHeight = size.height * 0.05;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, goalHeight / 2),
        width: goalWidth,
        height: goalHeight,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height - goalHeight / 2),
        width: goalWidth,
        height: goalHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
