// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ChemS';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get fontSize => 'Font Size';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get aboutApp => 'About App';

  @override
  String get searchHint => 'Enter a formula';

  @override
  String get searchResult => 'Search Result';

  @override
  String get noResult => 'No results found.';

  @override
  String get name => 'Name';

  @override
  String get molecularFormula => 'Formula';

  @override
  String get molecularWeight => 'Molecular Weight';

  @override
  String get meltingPoint => 'Melting Point';

  @override
  String get boilingPoint => 'Boiling Point';

  @override
  String get density => 'Density';

  @override
  String get noInfo => 'No info';
}
