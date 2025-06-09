import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class GeminiOCR {
  static Future<String> toGemini(File imageFile) async {
    const apiKey = 'AIzaSyBLqomK-fi2NhAqCbCrPslCPiItPh6PJUU';

    final processedImage = await _preprocessImage(imageFile);
    final base64Image = base64Encode(await processedImage.readAsBytes());

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final prompt = "화면 안의 화학식을 알려줘. 만약 화학식이 아니라 물질의 이름이라면 해당 물질의 화학식을 알려줘.만약 여러개 잇으면 쉼표와 띄어쓰기로 구별해서 알려줘. 없으면 없다고 알려줘. 단답으로 알려줘. 첨자 없이 알려줘.";

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "inlineData": {
                "mimeType": "image/jpeg",
                "data": base64Image
              }
            },


            {
              "text": prompt
            }
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['candidates'][0]['content']['parts'][0]['text'] ?? '';
    } else {
      return '오류: ${response.statusCode} - ${response.body}';
    }
  }

  static Future<File> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('이미지 디코딩 실패');

    final cx = original.width ~/ 2;
    final cy = original.height ~/ 2;
    const boxW = 300, boxH = 150;
    final sx = (cx - boxW ~/ 2).clamp(0, original.width - boxW);
    final sy = (cy - boxH ~/ 2).clamp(0, original.height - boxH);

    final cropped = img.copyCrop(
      original,
      x: sx,
      y: sy,
      width: boxW,
      height: boxH,
    );

    final resized = img.copyResize(
      cropped,
      width: boxW * 2,
      height: boxH * 2,
      interpolation: img.Interpolation.nearest,
    );

    final gray = img.grayscale(resized);
    final contrast = img.adjustColor(gray, contrast: 1.5);
    final binary = _applyThreshold(contrast, 160);

    final outBytes = Uint8List.fromList(img.encodeJpg(binary));
    final outFile = File('${imageFile.path}_processed_gemini.jpg');
    await outFile.writeAsBytes(outBytes);
    return outFile;
  }

  static img.Image _applyThreshold(img.Image src, int threshold) {
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        final value = luminance > threshold ? 255 : 0;
        final grayPixel = img.ColorUint8.rgb(value, value, value);
        src.setPixel(x, y, grayPixel);
      }
    }
    return src;
  }
}