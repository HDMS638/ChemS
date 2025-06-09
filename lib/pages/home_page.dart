import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/chemical_utils.dart';
import 'search_result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _searchHistory = [];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _focusNode.addListener(() {
      setState(() => _showHistory = _focusNode.hasFocus);
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _deleteTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(term);
    await prefs.setStringList('searchHistory', _searchHistory);
    setState(() {});
  }

  Future<void> _clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() => _searchHistory.clear());
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) return;
    final formatted = capitalizeFormula(query.trim());

    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(formatted);
    _searchHistory.insert(0, formatted);
    await prefs.setStringList('searchHistory', _searchHistory);

    _controller.clear();
    _focusNode.unfocus();
    setState(() => _showHistory = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultPage(query: formatted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Text(
            local?.appTitle ?? "ChemS",
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: local?.searchHint ?? 'Enter a formula',
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.indigo),
                ),
              ),
            ),
          ),
          if (_showHistory)
            ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("최근 검색어", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _clearAllHistory,
                      child: const Text("전체삭제"),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    final item = _searchHistory[index];
                    return ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(item),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _deleteTerm(item),
                      ),
                      onTap: () => _onSearch(item),
                    );
                  },
                ),
              ),
            ]
        ],
      ),
    );
  }
}
