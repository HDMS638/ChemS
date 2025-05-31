// lib/utils/chemical_parser.dart

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
  'Bk', 'Cf', 'Es', 'Fm', 'Md', 'No', 'Lr',
  'Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds', 'Rg', 'Cn',
  'Fl', 'Lv', 'Ts', 'Og'
];

/// 잘못 인식된 화학식을 주기율표 기반으로 정리
String normalizeChemicalFormula(String input) {
  final buffer = StringBuffer();
  int i = 0;

  while (i < input.length) {
    if (i + 1 < input.length) {
      final two = input.substring(i, i + 2);
      if (periodicTable.contains(two)) {
        buffer.write(two);
        i += 2;
        continue;
      }
    }

    final one = input[i];
    if (periodicTable.contains(one)) {
      buffer.write(one);
      i++;
      continue;
    }

    if (RegExp(r'\d').hasMatch(one)) {
      buffer.write(one);
      i++;
      continue;
    }

    i++;
  }

  return buffer.toString();
}
