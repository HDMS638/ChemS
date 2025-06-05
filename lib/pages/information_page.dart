
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
  bool useInternationalScheme = true;

  @override
  void initState() {
    super.initState();
    _elementsFuture = loadElements();
  }

  Color getColorForElement(ElementModel element) {
    return useInternationalScheme
        ? internationalColor(element.category)
        : domesticColor(element.category);
  }

  Color internationalColor(String category) {
    switch (category.toLowerCase()) {
      case 'alkali metal':
        return Colors.orange.shade600;
      case 'alkaline earth metal':
        return Colors.red.shade700;
      case 'transition metal':
        return Colors.purple.shade900;
      case 'post-transition metal':
        return Colors.green.shade900;
      case 'metalloid':
        return Colors.green.shade300;
      case 'nonmetal':
        return Colors.grey.shade600;
      case 'halogen':
        return Colors.lightBlue.shade300;
      case 'noble gas':
        return Colors.lightBlue.shade900;
      case 'lanthanide':
        return Colors.blue.shade900;
      case 'actinide':
        return Colors.amberAccent;
      default:
        return Colors.grey.shade200;
    }
  }

  Color domesticColor(String category) {
    switch (category.toLowerCase()) {
      case 'metal':
      case 'transition metal':
      case 'alkali metal':
      case 'alkaline earth metal':
      case 'post-transition metal':
      case 'lanthanide':
      case 'actinide':
        return Colors.blue.shade400;
      case 'metalloid':
        return Colors.amber.shade300;
      case 'nonmetal':
      case 'halogen':
      case 'noble gas':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade200;
    }
  }

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
          color: getColorForElement(element),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              element.symbol,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              '${element.atomicNumber}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget legendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget buildLegendRow() {
    final items = useInternationalScheme
        ? [
            legendItem(color: Colors.orange.shade600, label: '알칼리 금속'),
            legendItem(color: Colors.red.shade700, label: '알칼리 토금속'),
            legendItem(color: Colors.purple.shade900, label: '전이 금속'),
            legendItem(color: Colors.green.shade900, label: '전이후 금속'),
            legendItem(color: Colors.green.shade300, label: '준금속'),
            legendItem(color: Colors.grey.shade600, label: '비금속'),
            legendItem(color: Colors.lightBlue.shade300, label: '할로겐'),
            legendItem(color: Colors.lightBlue.shade900, label: '비활성 기체'),
          ]
        : [
            legendItem(color: Colors.blue.shade400, label: '금속'),
            legendItem(color: Colors.amber.shade300, label: '준금속'),
            legendItem(color: Colors.red.shade400, label: '비금속'),
          ];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 4,
        children: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (_selectedElement != null && !_selectedElement!.isEmpty)
              ? '${_selectedElement!.name} (${_selectedElement!.symbol})'
              : '원소를 선택하세요',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cached),
            tooltip: '색상 기준 교체',
            onPressed: () {
              setState(() {
                useInternationalScheme = !useInternationalScheme;
              });
            },
          )
        ],
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
          final lanthanides = elements
              .where((e) => e.atomicNumber >= 57 && e.atomicNumber <= 71)
              .toList();
          final actinides = elements
              .where((e) => e.atomicNumber >= 89 && e.atomicNumber <= 103)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLegendRow(),
                const Divider(),
                if (_selectedElement != null && !_selectedElement!.isEmpty)
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
                  ),
                InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: SingleChildScrollView(
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
                            return element.isEmpty
                                ? const SizedBox(height: 60)
                                : buildElementBox(element);
                          }),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text('란타넘족 (57–71)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: lanthanides.map(buildElementBox).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text('악티늄족 (89–103)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: actinides.map(buildElementBox).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
