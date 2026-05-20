import 'package:flutter/material.dart';

class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;
  static const pixel5Width = 393.0;
  static const pixel5Height = 851.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showPreviewFrame = constraints.maxWidth > pixel5Width + 48;

        if (!showPreviewFrame) {
          return ColoredBox(color: Colors.white, child: child);
        }

        return ColoredBox(
          color: const Color(0xff202020),
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: pixel5Width,
                height: pixel5Height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
