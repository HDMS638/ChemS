import 'package:chems/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'pages/camera_page.dart';
import 'pages/search_page.dart';
import 'pages/favorites_page.dart';
import 'pages/settings_page.dart';

void main() => runApp(ChemSApp());

class ChemSApp extends StatelessWidget {
  const ChemSApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChemS',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    CameraPage(),
    SearchPage(),
    HomePage(),
    FavoritesPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.indigo.withAlpha((0.3 * 255).toInt()),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
