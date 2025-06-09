import 'package:flutter/material.dart';
import 'package:chems/services/chemical_api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';
import '../services/favorite_service.dart';
import '../utils/chemical_utils.dart';
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

  late final String displayFormula;
  late final String apiQuery;

  List<String> ghsPictograms = [];

  @override
  void initState() {
    super.initState();
    displayFormula = capitalizeFormula(widget.query);
    apiQuery = widget.query.toLowerCase();
    _loadDataAndStoreHistory();
  }

  Future<void> _loadDataAndStoreHistory() async {
    final result = await fetchChemicalInfoWithFallback(apiQuery);

    final prefs = await SharedPreferences.getInstance();
    final shouldSave = prefs.getBool('saveSearchHistory') ?? true;

    if (shouldSave) {
      List<String> history = prefs.getStringList('searchHistory') ?? [];
      history.removeWhere((item) =>
      capitalizeFormula(item).toLowerCase() == displayFormula.toLowerCase());
      history.insert(0, displayFormula);
      await prefs.setStringList('searchHistory', history);
    }

    if (result != null && result['RawJson'] != null) {
      ghsPictograms = extractGhsPictograms(result['RawJson']);
    }

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  List<String> extractGhsPictograms(Map<String, dynamic> rawJson) {
    final pictograms = <String>[];

    void searchGHS(dynamic section) {
      if (section is Map<String, dynamic>) {
        if (section['TOCHeading'] == 'GHS Classification') {
          final infoList = section['Information'] ?? [];
          for (var info in infoList) {
            final value = info['Value'];
            if (value != null && value['ExternalDataURL'] != null) {
              final url = value['ExternalDataURL'];
              final name = _mapUrlToFileName(url);
              if (name != null) pictograms.add(name);
            } else if (value != null && value['StringWithMarkup'] != null) {
              for (var item in value['StringWithMarkup']) {
                final href = item['Markup']?[0]?['URL'];
                final name = _mapUrlToFileName(href);
                if (name != null) pictograms.add(name);
              }
            }
          }
        } else if (section.containsKey('Section')) {
          for (var sub in section['Section']) {
            searchGHS(sub);
          }
        }
      } else if (section is List) {
        for (var sub in section) {
          searchGHS(sub);
        }
      }
    }

    searchGHS(rawJson['Record']['Section']);
    return pictograms.toSet().toList();
  }

  String? _mapUrlToFileName(String? url) {
    if (url == null) return null;
    if (url.contains('GHS01')) return 'ghs_Exploding_Bomb';
    if (url.contains('GHS02')) return 'ghs_flame';
    if (url.contains('GHS03')) return 'ghs_flame_over_circle';
    if (url.contains('GHS04')) return 'ghs_gas';
    if (url.contains('GHS05')) return 'ghs_corrosion';
    if (url.contains('GHS06')) return 'ghs_skull';
    if (url.contains('GHS07')) return 'ghs_exclamation';
    if (url.contains('GHS08')) return 'ghs_health_hazard';
    if (url.contains('GHS09')) return 'ghs_environment';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(displayFormula)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? Center(child: Text(local.noResult))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoRow('🧪 ${local.name}', data?['Title'] ?? 'Unknown'),
          _infoRow('⚗️ ${local.molecularFormula}', displayFormula),
          _infoRow('⚖️ ${local.molecularWeight}', '${data?['MolecularWeight'] ?? 'Unknown'} g/mol'),
          _infoRow('❄️ ${local.meltingPoint}', addTemperatureUnit(data?['MeltingPoint'])),
          _infoRow('🔥 ${local.boilingPoint}', addTemperatureUnit(data?['BoilingPoint'])),
          _infoRow('🧊 ${local.density}', addDensityUnit(data?['Density'])),
          if (ghsPictograms.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text("☣️ GHS 라벨", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ghsPictograms.map((filename) {
                return Image.asset(
                  'assets/image/$filename.png',
                  width: 64,
                  height: 64,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await FavoriteService.addFavorite(FavoriteItem(
                name: data?['Title'] ?? 'Unknown',
                title: data?['Title'] ?? 'Unknown',
                formula: displayFormula,
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
