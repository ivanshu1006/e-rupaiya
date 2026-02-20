class LanguageOption {
  const LanguageOption({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

const languageOptions = [
  LanguageOption(label: 'Hello (English)', value: 'en'),
  LanguageOption(label: 'नमस्ते (Hindi)', value: 'hi'),
];
