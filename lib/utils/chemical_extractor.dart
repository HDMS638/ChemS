// lib/utils/chemical_extractor.dart

/// OCR 인식 텍스트를 보정 (문자 대체, 특수문자 제거 등)
String fixOcrText(String text) {
  return text
      .replaceAll('0', 'O') // 숫자 0 → 대문자 O
      .replaceAll('1', 'I') // 숫자 1 → 대문자 I
      .replaceAll(RegExp(r'[^\w]'), '') // 특수문자 제거 (단어 문자만 남김)
      .toUpperCase(); // 대문자로 통일
}

/// OCR 결과에서 화학식 후보를 추출
String extractChemicalFormula(String rawText) {
  final lines = rawText.split('\n');

  // 간단한 화학식 후보 정규표현식: 대문자+숫자 (길이 제한: 2~6자)
  final regex = RegExp(r'^[A-Z][A-Z0-9]{1,5}$');

  for (final line in lines) {
    final cleaned = fixOcrText(line);
    if (regex.hasMatch(cleaned)) {
      print('🧪 추출된 화학식 후보: $cleaned');
      return cleaned;
    }
  }

  return ''; // 추출된 화학식이 없을 경우
}
