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

  late final String standardizedFormula;

  @override
  void initState() {
    super.initState();
    standardizedFormula = capitalizeFormula(widget.query); // ✅ 보정
    _loadDataAndStoreHistory();
  }

  Future<void> _loadDataAndStoreHistory() async {
    final result = await fetchChemicalInfoWithFallback(standardizedFormula.toLowerCase());

    final prefs = await SharedPreferences.getInstance();
    final shouldSave = prefs.getBool('saveSearchHistory') ?? true;

    if (shouldSave) {
      List<String> history = prefs.getStringList('searchHistory') ?? [];
      final lowerHistory = history.map((e) => e.toLowerCase()).toList();

      if (!lowerHistory.contains(standardizedFormula.toLowerCase())) {
        history.add(standardizedFormula);
        await prefs.setStringList('searchHistory', history);
      }
    }

    setState(() {
      data = result;
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
          _infoRow('⚗️ ${local.molecularFormula}', standardizedFormula), // ✅ 정규화된 화학식 사용
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
                formula: standardizedFormula, // ✅ 정규화된 값 저장
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
