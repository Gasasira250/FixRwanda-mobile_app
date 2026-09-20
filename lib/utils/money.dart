class Money {
  Money._();

  static String rwf(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    final prefix = amount < 0 ? '-' : '';
    return '$prefix${buffer.toString()} RWF';
  }
}
