import 'package:flutter/material.dart';

import '../pages/login_page.dart';
import 'app_name.dart';
import 'logo_mark.dart';

class ListHeader extends StatelessWidget {
  const ListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(left: 22, top: 19, child: LogoMark(size: 40)),
          const AppName(),
          Positioned(
            right: 7,
            top: 28,
            child: SizedBox(
              height: 22,
              child: FilledButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginPage())),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff5e5e5e),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Login/Register'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
