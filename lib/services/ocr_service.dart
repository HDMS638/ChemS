import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> recognizeTextFromImage(InputImage image) async {
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(image);
    textRecognizer.close();
    return recognizedText.text;
  }
}
