/// Helper for date-related param detection and formatting.
class DateFormatHelper {
  DateFormatHelper._();

  /// Returns true if [paramName] indicates a date input field.
  static bool isDateParam(String paramName) {
    final lower = paramName.toLowerCase();
    return lower.contains('dob') ||
        lower.contains('date of birth') ||
        lower.contains('birth date') ||
        lower.contains('expiry date') ||
        lower.contains('expiry') ||
        lower.contains('date');
  }

  /// Extracts the date format pattern from a param name.
  ///
  /// Examples:
  ///   "DOB (DD-MM-YYYY)"    → "DD-MM-YYYY"
  ///   "Expiry Date (MM/YY)" → "MM/YY"
  ///
  /// Falls back to "DD-MM-YYYY" if no pattern is found.
  static String extractFormat(String paramName) {
    final match =
        RegExp(r'\(([A-Za-z\-\/\.]+)\)').firstMatch(paramName);
    if (match != null) return match.group(1)!.toUpperCase();
    return 'DD-MM-YYYY';
  }

  /// Parses an ISO or common date string (e.g. "2026-03-12") to [DateTime].
  static DateTime? parseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    final numeric = RegExp(r'^(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})$');
    final match = numeric.firstMatch(value);
    if (match != null) {
      final day = int.tryParse(match.group(1) ?? '');
      final month = int.tryParse(match.group(2) ?? '');
      var year = int.tryParse(match.group(3) ?? '');
      if (day == null || month == null || year == null) return null;
      if (year < 100) year += 2000;
      return DateTime(year, month, day);
    }
    return null;
  }

  /// Formats a date string into a human-readable form, e.g. "12 March".
  /// Returns [raw] unchanged if it cannot be parsed.
  static String formatDisplayDate(String raw) {
    final date = parseDate(raw);
    if (date == null) return raw;
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  /// Formats [date] using the given [pattern].
  ///
  /// Supported tokens: DD, MM, YYYY, YY
  static String format(DateTime date, String pattern) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    final yy = yyyy.substring(2);
    return pattern
        .replaceAll('YYYY', yyyy)
        .replaceAll('YY', yy)
        .replaceAll('MM', mm)
        .replaceAll('DD', dd);
  }
}
