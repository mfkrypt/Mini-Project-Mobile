import 'package:flutter/material.dart';

import '../widgets/divider_line.dart';
import '../widgets/phone_frame.dart';

class HugeXPage extends StatelessWidget {
  const HugeXPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhoneFrame(
        child: Column(
          children: [
            const DividerLine(),
            Expanded(
              child: Center(
                child: Text(
                  'X',
                  style: TextStyle(
                    fontSize: 190,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
