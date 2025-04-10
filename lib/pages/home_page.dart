import 'package:flutter/material.dart';
import 'search_result_page.dart'; // 결과 페이지 import

class HomePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            Text(
              'ChemS',
              style: TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _controller,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultPage(query: value.trim()),
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: '화학식을 입력하세요',
                  prefixIcon: Icon(Icons.search, color: Colors.indigo),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.indigo),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
