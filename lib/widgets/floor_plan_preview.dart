import 'package:flutter/material.dart';

class FloorPlanPreview extends StatelessWidget {
  const FloorPlanPreview({super.key, this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 306,
      color: const Color(0xfff3f4f2),
      child: imagePath == null
          ? CustomPaint(
              painter: FloorPlanPainter(),
              child: const SizedBox.expand(),
            )
          : ClipRRect(
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}

class FloorPlanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..color = const Color(0xffb9b9b9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final boothPaint = Paint()
      ..color = const Color(0xffd8e8f1)
      ..style = PaintingStyle.fill;
    final boothBorder = Paint()
      ..color = const Color(0xff9fb6c4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final selectedPaint = Paint()..color = const Color(0xff7fb8e8);

    canvas.drawRect(
      Rect.fromLTWH(12, 0, size.width - 24, size.height - 6),
      wallPaint,
    );
    canvas.drawLine(Offset(0, 74), Offset(size.width, 74), wallPaint);
    canvas.drawLine(Offset(0, 246), Offset(size.width, 246), wallPaint);

    final booths = [
      {'name': 'A-01', 'rect': Rect.fromLTWH(152, 120, 80, 75)},

      {'name': 'B-01', 'rect': Rect.fromLTWH(66, 88, 60, 50)},
      {'name': 'B-02', 'rect': Rect.fromLTWH(260, 88, 60, 50)},

      {'name': 'B-03', 'rect': Rect.fromLTWH(66, 166, 60, 50)},
      {'name': 'B-04', 'rect': Rect.fromLTWH(260, 166, 60, 50)},

      {'name': 'C-01', 'rect': Rect.fromLTWH(18, 94, 28, 122)},
      {'name': 'C-02', 'rect': Rect.fromLTWH(size.width - 46, 94, 28, 122)},
    ];

    void drawBoothText(String text, Rect booth) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Color(0xff4f7190),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          booth.center.dx - textPainter.width / 2,
          booth.center.dy - textPainter.height / 2,
        ),
      );
    }

    for (final booth in booths) {
      final name = booth['name'] as String;
      final rect = booth['rect'] as Rect;

      canvas.drawRect(rect, boothPaint);
      canvas.drawRect(rect, boothBorder);

      drawBoothText(name, rect);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
