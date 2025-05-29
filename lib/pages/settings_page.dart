import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/font_provider.dart';
import '../utils/email_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isHistoryEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('saveSearchHistory') ?? true;
    setState(() {
      _isHistoryEnabled = enabled;
    });
  }

  Future<void> _toggleHistory(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saveSearchHistory', value);
    setState(() {
      _isHistoryEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontProvider = Provider.of<FontProvider>(context);
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(local.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(local.darkMode),
            value: themeProvider.isDarkMode,
            onChanged: themeProvider.toggleTheme,
          ),

          const Divider(thickness: 1, height: 32),

          ListTile(
            title: Text(local.language),
            trailing: const Icon(Icons.language),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(local.language),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('한국어'),
                        onTap: () {
                          Provider.of<LocaleProvider>(context, listen: false)
                              .setLocale(const Locale('ko'));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('English'),
                        onTap: () {
                          Provider.of<LocaleProvider>(context, listen: false)
                              .setLocale(const Locale('en'));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Divider(thickness: 1, height: 32),

          ListTile(
            title: Text(local.fontSize),
            trailing: const Icon(Icons.format_size),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(local.fontSize, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 12),
                      Slider(
                        value: fontProvider.fontScale,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        label: fontProvider.fontScale.toStringAsFixed(1),
                        onChanged: fontProvider.setFontScale,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Divider(thickness: 1, height: 32),

          // 검색 기록 저장 스위치
          SwitchListTile(
            title: const Text("검색기록 저장"),
            value: _isHistoryEnabled,
            onChanged: _toggleHistory,
          ),

          const Divider(thickness: 1, height: 32),

          ListTile(
            title: Text(local.sendFeedback),
            trailing: const Icon(Icons.mail_outline),
            onTap: () {
              launchEmail(
                toEmail: 'ChemS@gmail.com',
                subject: '${local.appTitle} 앱 피드백',
                body: '안녕하세요,\n\n${local.appTitle} 앱에 대해 피드백 드립니다:\n',
              );
            },
          ),

          const Divider(thickness: 1, height: 32),

          ListTile(
            title: Text(local.aboutApp),
            trailing: const Icon(Icons.info_outline),
            onTap: () async {
              final info = await PackageInfo.fromPlatform();
              showAboutDialog(
                context: context,
                applicationName: info.appName,
                applicationVersion: info.version,
                applicationIcon: const Icon(Icons.science),
                applicationLegalese: '© 2025 ChemS',
              );
            },
          ),
        ],
      ),
    );
  }
}
