import 'package:flutter/material.dart';

class ExhibitionImagePlaceholder extends StatelessWidget {
  const ExhibitionImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffc5cedc),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 66, color: Colors.black),
    );
  }
}
