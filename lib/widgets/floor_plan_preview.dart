import 'package:flutter/material.dart';

import '../models/admin_booth_map.dart';
import '../utils/asset_path.dart';

class FloorPlanPreview extends StatelessWidget {
  const FloorPlanPreview({super.key, this.imagePath, this.booths = const []});

  final String? imagePath;
  final List<AdminBoothMap> booths;

  String? get _normalizedImagePath {
    if (imagePath == null || imagePath!.trim().isEmpty) {
      return null;
    }
    return normalizeFloorPlanAssetPath(imagePath);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xff55bd69);
      case 'booked':
        return const Color(0xffd9534f);
      case 'pending':
        return const Color(0xfff0ad4e);
      case 'selected':
        return const Color(0xff4389f4);
      default:
        return const Color(0xff9b9b9b);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = _normalizedImagePath;

    return Container(
      height: 306,
      color: const Color(0xfff3f4f2),
      child: Stack(
        children: [
          Positioned.fill(
            child: path == null
                ? CustomPaint(
                    painter: FloorPlanPainter(),
                    child: const SizedBox.expand(),
                  )
                : Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(painter: FloorPlanPainter()),
                        const Center(
                          child: ColoredBox(
                            color: Color(0xccffffff),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Floor plan image not found',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: [
                    for (final booth in booths)
                      Positioned(
                        left: booth.x * width,
                        top: booth.y * height,
                        width: booth.width * width,
                        height: booth.height * height,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _statusColor(
                              booth.status,
                            ).withValues(alpha: 0.78),
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Text(
                                booth.boothId,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
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
