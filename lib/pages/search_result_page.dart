import 'package:flutter/material.dart';
import 'package:chems/services/chemical_api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';
import '../services/favorite_service.dart';
import '../utils/chemical_formatter.dart';
import '../utils/unit_formatter.dart';

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
    _loadDataAndStoreHistory();
  }

  Future<void> _loadDataAndStoreHistory() async {
    final result = await fetchChemicalInfoWithFallback(widget.query);

    final prefs = await SharedPreferences.getInstance();
    final shouldSave = prefs.getBool('saveSearchHistory') ?? true;

    if (shouldSave) {
      List<String> history = prefs.getStringList('searchHistory') ?? [];
      if (!history.contains(widget.query)) {
        history.add(widget.query);
        await prefs.setStringList('searchHistory', history);
      }
    }

    setState(() {
      data = result;

      // ✅ 디버깅용 로그 추가
      print('🔬 원본 화학식: ${data?['MolecularFormula']}');
      print('🧪 정렬된 화학식: ${formatFormula(data?['MolecularFormula'] ?? '')}');

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(local.searchResult)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? Center(child: Text(local.noResult))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoRow('🧪 ${local.name}', data!['Title']),
          _infoRow('⚗️ ${local.molecularFormula}', formatFormula(data!['MolecularFormula'] ?? '')),
          _infoRow('⚖️ ${local.molecularWeight}', '${data!['MolecularWeight']} g/mol'),
          _infoRow('❄️ ${local.meltingPoint}', addTemperatureUnit(data!['MeltingPoint'])),
          _infoRow('🔥 ${local.boilingPoint}', addTemperatureUnit(data!['BoilingPoint'])),
          _infoRow('🧊 ${local.density}', addDensityUnit(data!['Density'])),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await FavoriteService.addFavorite(FavoriteItem(
                name: data!['Title'] ?? 'Unknown',
                title: data!['Title'] ?? 'Unknown',
                formula: formatFormula(data!['MolecularFormula'] ?? ''), // ✅ 관용 표기로 저장
              ));

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(local.addedToFavorites)),
              );
            },
            icon: const Icon(Icons.favorite, color: Colors.white),
            label: Text(local.addToFavorites),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    final local = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? local.noInfo),
          ),
        ],
      ),
    );
  }
}
