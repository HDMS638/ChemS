import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_result_page.dart';
import '../utils/chemical_formatter.dart';

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
    final history = prefs.getStringList('searchHistory') ?? [];
    setState(() => _searchHistory = history);
  }

  Future<void> _addToSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final formatted = capitalizeFormula(query.trim());

    final history = prefs.getStringList('searchHistory') ?? [];

    if (history.contains(formatted)) return;

    history.insert(0, formatted);
    await prefs.setStringList('searchHistory', history);

    setState(() => _searchHistory = history);
  }

  Future<void> _deleteFromSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('searchHistory') ?? [];
    history.remove(query);
    await prefs.setStringList('searchHistory', history);
    setState(() => _searchHistory = history);
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() => _searchHistory = []);
  }

  void _navigateToSearchResult(String query) {
    if (query.trim().isEmpty) return;
    final formatted = capitalizeFormula(query);
    _addToSearchHistory(formatted);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultPage(query: formatted),
      ),
    );
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSubmitted: _navigateToSearchResult,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: local?.searchHint ?? '화학식을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_showHistory && _searchHistory.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        local?.recentSearches ?? '최근 검색어',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearSearchHistory,
                        child: Text(local?.clearAll ?? '전체삭제'),
                      ),
                    ],
                  ),
                if (_showHistory && _searchHistory.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        final query = _searchHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(query),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _deleteFromSearchHistory(query),
                          ),
                          onTap: () => _navigateToSearchResult(query),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
