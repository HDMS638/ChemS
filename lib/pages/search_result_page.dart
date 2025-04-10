import 'package:flutter/material.dart';
import 'package:chems/services/chemical_api.dart';

class SearchResultPage extends StatefulWidget {
  final String query;
  const SearchResultPage({required this.query, super.key});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChemicalInfoWithFallback(widget.query).then((result) {
      setState(() {
        data = result;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('검색 결과')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text('결과를 찾을 수 없습니다.'))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoRow('🧪 이름', data!['Title']),
          _infoRow('⚗️ 분자식', data!['MolecularFormula']),
          _infoRow('⚖️ 분자량', '${data!['MolecularWeight']} g/mol'),
          _infoRow('❄️ 녹는점', _addUnit(data!['MeltingPoint'], '°C')),
          _infoRow('🔥 끓는점', _addUnit(data!['BoilingPoint'], '°C')),
          _infoRow('🧊 밀도', _addUnit(data!['Density'], 'g/cm³')),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100,
              child: Text(
                  label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value ?? '정보 없음')),
        ],
      ),
    );
  }

  String? _addUnit(String? value, String unit) {
    if (value == null || value.isEmpty) return null;

    // 단위가 이미 포함된 경우 또는 기호가 있는 경우 그대로 반환
    if (value.contains(unit) || value.contains(RegExp(r'[a-zA-Z%]'))) {
      return value;
    }

    return '$value $unit';
  }
}