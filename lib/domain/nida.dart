class NidaNumber {
  NidaNumber._();

  static final _digits = RegExp(r'^\d{16}$');

  static String normalize(String raw) => raw.replaceAll(RegExp(r'\s|-'), '');

  static bool isValid(String raw) {
    final value = normalize(raw);
    if (!_digits.hasMatch(value)) return false;
    if (value[0] != '1' && value[0] != '2') return false;
    final year = int.parse(value.substring(1, 5));
    final maxYear = DateTime.now().year - 16;
    if (year < 1920 || year > maxYear) return false;
    final gender = value[5];
    return gender == '7' || gender == '8';
  }

  static String seed(int index) {
    final year = 1970 + (index % 30);
    final gender = index.isEven ? '7' : '8';
    final serial = index.toString().padLeft(10, '0');
    return '1$year$gender$serial';
  }
}
