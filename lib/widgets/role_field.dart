import 'package:flutter/material.dart';

class RoleField extends StatelessWidget {
  const RoleField({
    super.key,
    required this.value,
    required this.onChanged,
    this.includeAdmin = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool includeAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: const Color(0xffd9d9d9),
      padding: const EdgeInsets.only(left: 13, right: 18),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 36,
            color: Color(0xff888888),
          ),
          items: [
            const DropdownMenuItem(
              value: 'Role (Dropdown)',
              child: RoleLabel(text: 'Role (Dropdown)'),
            ),
            const DropdownMenuItem(
              value: 'Organizer',
              child: RoleLabel(text: 'Organizer'),
            ),
            const DropdownMenuItem(
              value: 'Exhibitor',
              child: RoleLabel(text: 'Exhibitor'),
            ),
            if (includeAdmin)
              const DropdownMenuItem(
                value: 'Administrator',
                child: RoleLabel(text: 'Administrator'),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class RoleLabel extends StatelessWidget {
  const RoleLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.work_outline, size: 23),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
