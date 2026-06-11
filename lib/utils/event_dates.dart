import 'package:flutter/services.dart';

class EventDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 6 ? digits.substring(0, 6) : digits;
    final buffer = StringBuffer();

    for (var i = 0; i < limited.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(limited[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

DateTime? parseEventDate(String value) {
  final trimmed = value.trim();
  final isoDate = DateTime.tryParse(trimmed);
  if (isoDate != null) {
    return DateTime(isoDate.year, isoDate.month, isoDate.day);
  }

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 6) {
    final day = int.tryParse(digits.substring(0, 2));
    final month = int.tryParse(digits.substring(2, 4));
    final year = int.tryParse(digits.substring(4, 6));
    if (day == null || month == null || year == null) {
      return null;
    }
    return _validDate(2000 + year, month, day);
  }

  if (digits.length == 8) {
    final day = int.tryParse(digits.substring(0, 2));
    final month = int.tryParse(digits.substring(2, 4));
    final year = int.tryParse(digits.substring(4, 8));
    if (day == null || month == null || year == null) {
      return null;
    }
    return _validDate(year, month, day);
  }

  return null;
}

String normalizeEventDateInput(String value) {
  final date = parseEventDate(value);
  if (date == null) {
    return value.trim();
  }
  return formatEventDate(date);
}

String formatEventDateForDisplay(String value) {
  final date = parseEventDate(value);
  if (date == null) {
    return value;
  }
  return formatEventDate(date);
}

String formatEventDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = (date.year % 100).toString().padLeft(2, '0');
  return '$day/$month/$year';
}

String eventStatusFromDates(String startDate, String endDate) {
  final start = parseEventDate(startDate);
  final end = parseEventDate(endDate);
  if (start == null || end == null) {
    return 'Upcoming';
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (today.isAfter(end)) {
    return 'Finished';
  }
  if (today.isBefore(start)) {
    return 'Upcoming';
  }
  return 'Ongoing';
}

DateTime? _validDate(int year, int month, int day) {
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}
