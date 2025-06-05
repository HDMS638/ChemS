String capitalizeFormula(String formula) {
  final buffer = StringBuffer();
  final regex = RegExp(r'[A-Za-z]+|\d+');

  for (final match in regex.allMatches(formula)) {
    final part = match.group(0)!;
    if (RegExp(r'^[a-zA-Z]+$').hasMatch(part)) {
      buffer.write(part[0].toUpperCase());
      if (part.length > 1) {
        buffer.write(part.substring(1).toLowerCase());
      }
    } else {
      buffer.write(part);
    }
  }
  return buffer.toString();
}