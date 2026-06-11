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

    if (path == null) {
      return const _UnavailableFloorPlan();
    }

    return Container(
      height: 306,
      color: const Color(0xfff3f4f2),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _UnavailableFloorPlan(),
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

class _UnavailableFloorPlan extends StatelessWidget {
  const _UnavailableFloorPlan();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 306,
      color: const Color(0xfff3f4f2),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(18),
      child: const Text(
        'Floor plan is not available yet.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }
}
