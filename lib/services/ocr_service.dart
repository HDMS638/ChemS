import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<File> preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('이미지 디코딩 실패');

    // 중앙 크롭
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

    // 해상도 2배 확대
    final resized = img.copyResize(
      cropped,
      width: boxW * 2,
      height: boxH * 2,
      interpolation: img.Interpolation.nearest,
    );

    // 그레이스케일 + 대비
    final gray = img.grayscale(resized);
    final contrast = img.adjustColor(gray, contrast: 1.5);

    // 이진화
    final thresh = _applyThreshold(contrast, 160);

    // 저장
    final outBytes = Uint8List.fromList(img.encodeJpg(thresh));
    final outFile = File('${imageFile.path}_processed.jpg');
    await outFile.writeAsBytes(outBytes);
    return outFile;
  }

  static Future<String> runOCR(File imageFile) async {
    final processed = await preprocessImage(imageFile);
    final inputImage = InputImage.fromFile(processed);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(inputImage);
    await recognizer.close();
    return result.text;
  }

  static img.Image _applyThreshold(img.Image src, int threshold) {
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        final value = luminance > threshold ? 255 : 0;

        // ⚠️ getColor → ColorUint8.rgb 로 교체
        final grayPixel = img.ColorUint8.rgb(value, value, value);
        src.setPixel(x, y, grayPixel);
      }
    }
    return src;
  }
}
