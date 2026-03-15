String maskPan(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.length <= 4) return trimmed;
  return '${trimmed.substring(0, 4)}****';
}

String maskAadhaar(String value) {
  final cleaned = value.replaceAll(RegExp(r'\s+'), '');
  if (cleaned.length <= 4) return cleaned;
  final start = cleaned.substring(0, 2);
  final end = cleaned.substring(cleaned.length - 4);
  return '$start******$end';
}
