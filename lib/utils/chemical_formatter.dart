/// 화학식을 관용 표기 순서로 정렬
String capitalizeFormula(String input) {
  final upper = input.replaceAll(' ', '').toUpperCase();
  final elementSymbols = <String>{
    // 모든 원소 기호 (1~118번)
    "H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne",
    "Na", "Mg", "Al", "Si", "P", "S", "Cl", "Ar",
    "K", "Ca", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn",
    "Ga", "Ge", "As", "Se", "Br", "Kr",
    "Rb", "Sr", "Y", "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd",
    "In", "Sn", "Sb", "Te", "I", "Xe",
    "Cs", "Ba", "La", "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu",
    "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au", "Hg",
    "Tl", "Pb", "Bi", "Po", "At", "Rn",
    "Fr", "Ra", "Ac", "Th", "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr",
    "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn", "Nh", "Fl", "Mc", "Lv", "Ts", "Og"
  };

  final elementCounts = <String, int>{};
  int index = 0;

  while (index < upper.length) {
    String? symbol;

    // 최대 2자리 기호 먼저 검사 (예: Na, Cl)
    if (index + 2 <= upper.length && elementSymbols.contains(upper.substring(index, index + 2))) {
      symbol = upper.substring(index, index + 2);
      index += 2;
    } else if (elementSymbols.contains(upper.substring(index, index + 1))) {
      symbol = upper.substring(index, index + 1);
      index += 1;
    } else {
      index++;
      continue;
    }

    // 숫자 파싱
    String countStr = '';
    while (index < upper.length && RegExp(r'\d').hasMatch(upper[index])) {
      countStr += upper[index];
      index++;
    }

    final count = countStr.isEmpty ? 1 : int.tryParse(countStr) ?? 1;
    elementCounts[symbol] = (elementCounts[symbol] ?? 0) + count;
  }

  // 관용 정렬 순서
  const preferredOrder = [
    'Na', 'K', 'Ca', 'Mg', 'Fe', 'Cu', 'Zn',
    'H', 'C', 'N', 'O',
    'Cl', 'Br', 'I', 'S', 'P'
  ];

  final sortedElements = elementCounts.keys.toList()
    ..sort((a, b) {
      final aIndex = preferredOrder.indexOf(a);
      final bIndex = preferredOrder.indexOf(b);
      if (aIndex == -1 && bIndex == -1) return a.compareTo(b);
      if (aIndex == -1) return 1;
      if (bIndex == -1) return -1;
      return aIndex.compareTo(bIndex);
    });

  final result = sortedElements.map((symbol) {
    final count = elementCounts[symbol]!;
    return '$symbol${count > 1 ? count : ''}';
  }).join();

  return result;
}
