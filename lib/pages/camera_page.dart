import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
  Future<void>? _initializeControllerFuture; // nullable로 수정

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {}); // 다시 build 호출
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndRecognizeText() async {
    try {
      if (_initializeControllerFuture == null) return;
      await _initializeControllerFuture;
      final picture = await _controller.takePicture();
      final rawText = await OcrService.runOCR(File(picture.path));

      debugPrint('📸 OCR 결과: $rawText');
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
        MaterialPageRoute(builder: (_) => SearchResultPage(query: formula)),
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
    if (_initializeControllerFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBody: true, // 하단 네비게이션에 겹치지 않게
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),

                // 가이드 박스
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

                // 촬영 버튼
                Positioned(
                  bottom: 100,
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
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (snap.hasError) {
            return Center(child: Text('카메라 오류 발생: ${snap.error}'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
