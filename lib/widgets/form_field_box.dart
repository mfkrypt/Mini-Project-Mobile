import 'package:flutter/material.dart';

class FormFieldBox extends StatelessWidget {
  const FormFieldBox({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: const Color(0xffd9d9d9),
      child: Row(
        children: [
          const SizedBox(width: 13),
          Icon(icon, size: 23),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
