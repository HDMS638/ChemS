import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:chems/utils/chemical_parser.dart'; // ✅ 화학식 보정 + 아래첨자 유틸

class OcrService {
  /// OCR 전에 이미지 전처리: 중앙 크롭 + 해상도 확대 + 대비 조절 + 이진화
  static Future<File> preprocessImage(File imageFile) async {
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

    final thresh = _applyThreshold(contrast, 160);

    final outBytes = Uint8List.fromList(img.encodeJpg(thresh));
    final outFile = File('${imageFile.path}_processed.jpg');
    await outFile.writeAsBytes(outBytes);
    return outFile;
  }

  /// OCR 실행 + 화학식 보정 + 아래첨자 변환 결과 리턴
  static Future<String> runOCR(File imageFile) async {
    final processed = await preprocessImage(imageFile);
    final inputImage = InputImage.fromFile(processed);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(inputImage);
    await recognizer.close();

    final raw = result.text.trim();
    print('📸 OCR 원본 결과: $raw');

    final corrected = normalizeChemicalFormula(raw);
    print('🧪 보정된 화학식: $corrected');

    final pretty = formatFormulaWithSubscript(corrected);
    print('🔡 최종 표기 형식: $pretty');

    return pretty; // ✅ UI에 표시할 때는 이걸 사용
  }

  /// 이진화 적용 (흑백 픽셀)
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
