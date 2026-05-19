import 'package:flutter/material.dart';

class AdminTable extends StatelessWidget {
  const AdminTable({
    super.key,
    required this.headers,
    required this.rows,
    this.columnWidths,
  });

  final List<String> headers;
  final List<List<Widget>> rows;
  final Map<int, TableColumnWidth>? columnWidths;

  @override
  Widget build(BuildContext context) {
    final headerStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    return Table(
      columnWidths: columnWidths,
      border: TableBorder.all(color: Colors.black, width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xffa6a6a6)),
          children: headers
              .map(
                (header) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Text(header, style: headerStyle),
                ),
              )
              .toList(),
        ),
        for (final row in rows)
          TableRow(
            children: row
                .map(
                  (cell) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      child: cell,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class AdminActionIcon extends StatelessWidget {
  const AdminActionIcon({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 18,
      child: Icon(icon, size: 18, color: Colors.black),
    );
  }
}
