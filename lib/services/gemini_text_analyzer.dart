import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiTextAnalyzer {
  static const _apiKey = 'AIzaSyBLqomK-fi2NhAqCbCrPslCPiItPh6PJUU'; // 필요시 환경변수로 분리

  static Future<String> analyzeInput(String input) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    );

    final prompt = '''
다음 입력이 화학식이면 그대로 출력하고, 물질명이라면 정확한 분자식(예: C6H12O6)으로 변환해.
- 반드시 정확한 **분자식**만 단답형으로 출력해.
- 첨자 사용하지 말고 숫자 그대로 써줘 (예: H₂O → H2O).
- 설명, 문장 없이 오직 화학식만.
- 여러 개가 있거나 모르면 '없음'이라고만 대답해.

입력: $input
출력:
''';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final rawText = json['candidates'][0]['content']['parts'][0]['text']?.trim() ?? input;

        // 필터링: 너무 짧거나 원소 기호만 있는 경우는 무시
        if (rawText.toLowerCase() == '없음' || rawText.length < 4 || !_isLikelyFormula(rawText)) {
          return input; // 원래 입력 유지
        }
        return rawText;
      } else {
        return input;
      }
    } catch (e) {
      return input;
    }
  }

  static bool _isLikelyFormula(String text) {
    final formulaPattern = RegExp(r'^([A-Z][a-z]?\d*)+$');
    return formulaPattern.hasMatch(text);
  }
}
