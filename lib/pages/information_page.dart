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
    final category = element.category['en']?.toLowerCase() ?? '';
    return useInternationalScheme
        ? internationalColor(category)
        : domesticColor(category);
  }

  Color internationalColor(String category) {
    switch (category) {
      case 'alkali metal':
        return Colors.red.shade100;
      case 'alkaline earth metal':
        return Colors.deepPurple.shade50;
      case 'transition metal':
        return Colors.blue.shade100;
      case 'post-transition metal':
        return Colors.greenAccent.shade100;
      case 'metalloid':
        return Colors.lightGreen.shade100;
      case 'nonmetal':
        return Colors.yellow.shade100;
      case 'halogen':
        return Colors.lightBlue.shade100;
      case 'noble gas':
        return Colors.orange.shade100;
      case 'lanthanide':
        return Colors.cyan.shade100;
      case 'actinide':
        return Colors.tealAccent.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color domesticColor(String category) {
    switch (category) {
      case 'metal':
      case 'transition metal':
      case 'alkali metal':
      case 'alkaline earth metal':
      case 'post-transition metal':
      case 'lanthanide':
      case 'actinide':
        return Colors.lightBlue.shade100;
      case 'metalloid':
        return Colors.lime.shade200;
      case 'nonmetal':
      case 'halogen':
      case 'noble gas':
        return Colors.red.shade100;
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
                color: Colors.black,
              ),
            ),
            Text(
              '${element.atomicNumber}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
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

  Widget buildLegendRow(String locale) {
    final items = useInternationalScheme
        ? [
      legendItem(color: Colors.red.shade100, label: locale == 'ko' ? '알칼리 금속' : 'Alkali Metal'),
      legendItem(color: Colors.deepPurple.shade50, label: locale == 'ko' ? '알칼리 토금속' : 'Alkaline Earth Metal'),
      legendItem(color: Colors.blue.shade100, label: locale == 'ko' ? '전이 금속' : 'Transition Metal'),
      legendItem(color: Colors.greenAccent.shade100, label: locale == 'ko' ? '전이후 금속' : 'Post-transition Metal'),
      legendItem(color: Colors.lightGreen.shade100, label: locale == 'ko' ? '준금속' : 'Metalloid'),
      legendItem(color: Colors.yellow.shade100, label: locale == 'ko' ? '비금속' : 'Nonmetal'),
      legendItem(color: Colors.lightBlue.shade100, label: locale == 'ko' ? '할로겐' : 'Halogen'),
      legendItem(color: Colors.orange.shade100, label: locale == 'ko' ? '비활성 기체' : 'Noble Gas'),
    ]
        : [
      legendItem(color: Colors.lightBlue.shade100, label: locale == 'ko' ? '금속' : 'Metal'),
      legendItem(color: Colors.lime.shade200, label: locale == 'ko' ? '준금속' : 'Metalloid'),
      legendItem(color: Colors.red.shade100, label: locale == 'ko' ? '비금속' : 'Nonmetal'),
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
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (_selectedElement != null && !_selectedElement!.isEmpty)
              ? '${_selectedElement!.name[locale] ?? _selectedElement!.name['en']} (${_selectedElement!.symbol})'
              : (locale == 'ko' ? '원소를 선택하세요' : 'Select an element'),
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
          final lanthanides = elements.where((e) => e.atomicNumber >= 57 && e.atomicNumber <= 71).toList();
          final actinides = elements.where((e) => e.atomicNumber >= 89 && e.atomicNumber <= 103).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLegendRow(locale),
                const Divider(),
                if (_selectedElement != null && !_selectedElement!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale == 'ko' ? '원자 번호: ${_selectedElement!.atomicNumber}' : 'Atomic Number: ${_selectedElement!.atomicNumber}',
                            style: const TextStyle(fontSize: 16)),
                        Text(locale == 'ko' ? '기호: ${_selectedElement!.symbol}' : 'Symbol: ${_selectedElement!.symbol}',
                            style: const TextStyle(fontSize: 16)),
                        Text(locale == 'ko' ? '원자 질량: ${_selectedElement!.atomicMass}' : 'Atomic Mass: ${_selectedElement!.atomicMass}',
                            style: const TextStyle(fontSize: 16)),
                        Text(
                            locale == 'ko'
                                ? '분류: ${_selectedElement!.category[locale] ?? _selectedElement!.category['en']}'
                                : 'Category: ${_selectedElement!.category[locale] ?? _selectedElement!.category['en']}',
                            style: const TextStyle(fontSize: 16)),
                        Text(locale == 'ko' ? '족(Group): ${_selectedElement!.group}' : 'Group: ${_selectedElement!.group}',
                            style: const TextStyle(fontSize: 16)),
                        Text(locale == 'ko' ? '주기(Period): ${_selectedElement!.period}' : 'Period: ${_selectedElement!.period}',
                            style: const TextStyle(fontSize: 16)),
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
                            return element.isEmpty ? const SizedBox(height: 60) : buildElementBox(element);
                          }),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(locale == 'ko' ? '란타넘족 (57–71)' : 'Lanthanides (57–71)',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(children: lanthanides.map(buildElementBox).toList()),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(locale == 'ko' ? '악티늄족 (89–103)' : 'Actinides (89–103)',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(children: actinides.map(buildElementBox).toList()),
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