String capitalizeFormula(String input) {
  final RegExp regex = RegExp(r'[A-Z][a-z]?|\d+|[a-zA-Z]');
  final matches = regex.allMatches(input);

  final buffer = StringBuffer();
  for (final match in matches) {
    final part = match.group(0)!;

    // 숫자면 그대로 추가
    if (RegExp(r'^\d+$').hasMatch(part)) {
      buffer.write(part);
    }
    // 한 글자인 경우 대문자로
    else if (part.length == 1) {
      buffer.write(part.toUpperCase());
    }
    // 두 글자인 경우 첫 글자 대문자 + 나머지 소문자
    else {
      buffer.write(part[0].toUpperCase() + part.substring(1).toLowerCase());
    }
  }

  return buffer.toString();
}
