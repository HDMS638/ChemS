import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/favorite_item.dart';
import '../services/favorite_service.dart';
import 'search_result_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<FavoriteItem> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final items = await FavoriteService.getFavorites();
    setState(() {
      favorites = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(local.favorites)),
      body: favorites.isEmpty
          ? Center(child: Text(local.noFavorites))
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final item = favorites[index];
          return ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(item.name),
            subtitle: Text(item.formula),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await FavoriteService.removeFavorite(item);
                _loadFavorites();
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SearchResultPage(query: item.formula),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
