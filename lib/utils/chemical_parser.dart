final List<String> periodicTable = [
  'H', 'He', 'Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne',
  'Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'Ar',
  'K', 'Ca', 'Sc', 'Ti', 'V', 'Cr', 'Mn', 'Fe', 'Co', 'Ni',
  'Cu', 'Zn', 'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr',
  'Rb', 'Sr', 'Y', 'Zr', 'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd',
  'Ag', 'Cd', 'In', 'Sn', 'Sb', 'Te', 'I', 'Xe',
  'Cs', 'Ba', 'La', 'Ce', 'Pr', 'Nd', 'Pm', 'Sm', 'Eu', 'Gd',
  'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb', 'Lu',
  'Hf', 'Ta', 'W', 'Re', 'Os', 'Ir', 'Pt', 'Au', 'Hg',
  'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn',
  'Fr', 'Ra', 'Ac', 'Th', 'Pa', 'U', 'Np', 'Pu', 'Am', 'Cm',
  'Bk', 'Cf', 'Es', 'Fm', 'Md', 'No', 'Lr', 'Rf', 'Db', 'Sg',
  'Bh', 'Hs', 'Mt', 'Ds', 'Rg', 'Cn', 'Fl', 'Lv', 'Ts', 'Og',
];

final Map<String, String> _subscriptMap = {
  '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄',
  '5': '₅', '6': '₆', '7': '₇', '8': '₈', '9': '₉',
};

/// 잘못된 화학식 문자열을 분석해 올바른 순서로 복구
String normalizeChemicalFormula(String input) {
  final buffer = StringBuffer();
  int i = 0;

  while (i < input.length) {
    // 대문자 + 소문자 조합 우선
    if (i + 1 < input.length) {
      final two = input.substring(i, i + 2);
      if (periodicTable.contains(two)) {
        buffer.write(two);
        i += 2;
        continue;
      }
    }

    // 대문자 1글자만
    final one = input[i];
    if (periodicTable.contains(one)) {
      buffer.write(one);
      i++;
      continue;
    }

    // 숫자라면
    if (RegExp(r'\d').hasMatch(one)) {
      buffer.write(one);
      i++;
      continue;
    }

    // 무시
    i++;
  }

  return buffer.toString();
}

/// 아래첨자 처리된 화학식 포맷
String formatFormulaWithSubscript(String formula) {
  return formula.replaceAllMapped(RegExp(r'(\d+)'), (match) {
    final digits = match.group(1)!;
    return digits.split('').map((d) => _subscriptMap[d] ?? d).join('');
  });
}
