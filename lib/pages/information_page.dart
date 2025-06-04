import 'package:flutter/material.dart';
import '../models/element_model.dart';
import '../services/element_service.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  late Future<List<ElementModel>> _elementsFuture;
  ElementModel? _selectedElement;

  @override
  void initState() {
    super.initState();
    _elementsFuture = loadElements();
  }

  // ✅ 카테고리별 색상 맵
  final Map<String, Color> categoryColors = {
    'Nonmetal': Colors.lightGreen.shade200,
    'Noble Gas': Colors.purple.shade200,
    'Alkali Metal': Colors.orange.shade200,
    'Alkaline Earth Metal': Colors.orange.shade100,
    'Metalloid': Colors.lightBlue.shade100,
    'Halogen': Colors.red.shade200,
    'Metal': Colors.blueGrey.shade100,
    'Transition Metal': Colors.amber.shade300,
    'Lanthanide': Colors.deepPurple.shade200,
    'Actinide': Colors.cyan.shade200,
    'Post-transition Metal': Colors.greenAccent.shade100,
    'Unknown': Colors.grey.shade300,
  };

  Widget buildElementBox(ElementModel element) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedElement = element;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(6),
        width: 50,
        height: 60,
        decoration: BoxDecoration(
          color: categoryColors[element.category] ?? Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
          border: _selectedElement?.atomicNumber == element.atomicNumber
              ? Border.all(color: Colors.teal, width: 2)
              : Border.all(color: Colors.teal.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              element.symbol,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              '${element.atomicNumber}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedElement != null
              ? '${_selectedElement!.name} (${_selectedElement!.symbol})'
              : 'Information Page',
        ),
      ),
      body: FutureBuilder<List<ElementModel>>(
        future: _elementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }

          final elements = snapshot.data!;
          final lanthanides = elements.where((e) => e.atomicNumber >= 57 && e.atomicNumber <= 71).toList();
          final actinides = elements.where((e) => e.atomicNumber >= 89 && e.atomicNumber <= 103).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // ✅ 상세 정보
                if (_selectedElement != null)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('원자 번호: ${_selectedElement!.atomicNumber}', style: const TextStyle(fontSize: 16)),
                        Text('기호: ${_selectedElement!.symbol}', style: const TextStyle(fontSize: 16)),
                        Text('원자 질량: ${_selectedElement!.atomicMass}', style: const TextStyle(fontSize: 16)),
                        Text('분류: ${_selectedElement!.category}', style: const TextStyle(fontSize: 16)),
                        Text('족(Group): ${_selectedElement!.group}', style: const TextStyle(fontSize: 16)),
                        Text('주기(Period): ${_selectedElement!.period}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('원소를 선택해주세요.', style: TextStyle(fontSize: 16)),
                  ),

                const Divider(),

                // ✅ 본체 주기율표 (1~118 중 57~71, 89~103 제외)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultColumnWidth: const FixedColumnWidth(52),
                    children: List.generate(7, (period) {
                      return TableRow(
                        children: List.generate(18, (group) {
                          final element = elements.firstWhere(
                                (e) =>
                            e.period == period + 1 &&
                                e.group == group + 1 &&
                                !(e.atomicNumber >= 57 && e.atomicNumber <= 71) &&
                                !(e.atomicNumber >= 89 && e.atomicNumber <= 103),
                            orElse: () => ElementModel.empty(),
                          );
                          if (element.isEmpty) {
                            return const SizedBox(height: 60);
                          }
                          return buildElementBox(element);
                        }),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ 란타넘족
                const Text('란타넘족 (57–71)', style: TextStyle(fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: lanthanides.map((e) => buildElementBox(e)).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // ✅ 악티늄족
                const Text('악티늄족 (89–103)', style: TextStyle(fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: actinides.map((e) => buildElementBox(e)).toList(),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}