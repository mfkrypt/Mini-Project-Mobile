import 'package:flutter/material.dart';

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffdddddd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'lib/image/Easy_book_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        color: Colors.black,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }
}