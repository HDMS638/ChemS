import 'package:flutter/material.dart';
import 'package:chems/services/chemical_api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/favorite_item.dart';
import '../services/favorite_service.dart';

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
          _infoRow('⚗️ ${local.molecularFormula}', data!['MolecularFormula']),
          _infoRow('⚖️ ${local.molecularWeight}', '${data!['MolecularWeight']} g/mol'),
          _infoRow('❄️ ${local.meltingPoint}', _addUnit(data!['MeltingPoint'], '°C')),
          _infoRow('🔥 ${local.boilingPoint}', _addUnit(data!['BoilingPoint'], '°C')),
          _infoRow('🧊 ${local.density}', _addUnit(data!['Density'], 'g/cm³')),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await FavoriteService.addFavorite(FavoriteItem(
                name: data!['Title'] ?? 'Unknown',
                title: data!['Title'] ?? 'Unknown',
                formula: data!['MolecularFormula'] ?? '',
              ));
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

  String? _addUnit(String? value, String unit) {
    if (value == null || value.isEmpty) return null;
    if (value.contains(unit) || value.contains(RegExp(r'[a-zA-Z%]'))) {
      return value;
    }
    return '$value $unit';
  }
}
