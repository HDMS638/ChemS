import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:chems/services/ocr_service.dart';
import 'package:chems/utils/chemical_extractor.dart';
import 'search_result_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndRecognizeText() async {
    try {
      await _initializeControllerFuture;
      final imageFile = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final rawText = await OcrService.recognizeTextFromImage(inputImage);

      debugPrint('📸 OCR 인식 결과: $rawText');

      final formula = extractChemicalFormula(rawText);
      debugPrint('🧪 추출된 화학식: $formula');

      if (!mounted) return;

      if (formula.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('화학식을 인식하지 못했습니다')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultPage(query: formula),
        ),
      );
    } catch (e) {
      debugPrint('❌ 오류 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('텍스트 인식 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Center(
                  child: Container(
                    width: 250,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '가이드라인 안에 화학식을 맞춰주세요',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _captureAndRecognizeText,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        '촬영 및 인식',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.indigo,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('카메라 오류 발생: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
