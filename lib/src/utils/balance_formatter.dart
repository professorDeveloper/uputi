String formatPrice(num value) {
  final s = value.toInt().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final index = s.length - i;
    buffer.write(s[i]);
    if (index > 1 && index % 3 == 1) buffer.write(' ');
  }
  return '${buffer.toString()} UZS';
}
