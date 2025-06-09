String extractChemicalFormula(String raw) {
  // 1) 아래첨자 → 일반 숫자 매핑
  const Map<String, String> sub2normal = {
    '₀': '0',
    '₁': '1',
    '₂': '2',
    '₃': '3',
    '₄': '4',
    '₅': '5',
    '₆': '6',
    '₇': '7',
    '₈': '8',
    '₉': '9',
  };

  // 2) 모든 아래첨자를 대응하는 일반 숫자로 치환
  raw = raw.replaceAllMapped(
    RegExp(sub2normal.keys.map(RegExp.escape).join('|')),
        (m) => sub2normal[m[0]]!,
  );

  // 3) 화학식 패턴 매칭 (예: H2O, C6H12O6, Fe2O3 등)
  final regex = RegExp(r'([A-Z][a-z]?)(\d*)');
  final matches = regex.allMatches(raw);

  // 4) 매칭된 부분만 이어붙여서 최종 화학식 반환
  if (matches.isEmpty) return '';
  return matches.map((m) => m.group(0)).join();
}