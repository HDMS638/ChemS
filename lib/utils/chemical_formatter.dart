/// 숫자를 아래첨자로 변환
String toSubscript(String input) {
  const subscriptMap = {
    '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄',
    '5': '₅', '6': '₆', '7': '₇', '8': '₈', '9': '₉',
  };
  return input.replaceAllMapped(RegExp(r'\d'), (m) => subscriptMap[m[0]] ?? m[0]!);
}

/// 화학식 내 원소 순서를 유지하며 파싱
List<String> parseFormulaElements(String formula) {
  final matches = RegExp(r'([A-Z][a-z]?)').allMatches(formula);
  return matches.map((m) => m.group(1)!).toList();
}

/// 관용 순서 대신 실제 입력된 순서를 우선시하여 정렬
String formatFormula(String formula) {
  final pattern = RegExp(r'([A-Z][a-z]?)(\d*)');
  final matches = pattern.allMatches(formula);
  final Map<String, int> elementCounts = {};

  for (final match in matches) {
    final element = match.group(1)!;
    final countStr = match.group(2);
    final count = countStr == null || countStr.isEmpty ? 1 : int.tryParse(countStr) ?? 1;
    elementCounts[element] = (elementCounts[element] ?? 0) + count;
  }

  final order = parseFormulaElements(formula).toSet().toList(); // 입력 순서 유지

  return order.map((el) {
    final count = elementCounts[el]!;
    return count == 1 ? el : '$el$count';
  }).join();
}

/// 정렬된 화학식에 아래첨자 적용
String formatFormulaWithSubscript(String formula) {
  return toSubscript(formatFormula(formula));
}
