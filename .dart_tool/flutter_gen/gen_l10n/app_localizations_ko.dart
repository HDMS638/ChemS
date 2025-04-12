// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'ChemS';

  @override
  String get settings => '설정';

  @override
  String get darkMode => '다크 모드';

  @override
  String get language => '언어';

  @override
  String get fontSize => '글꼴 크기';

  @override
  String get sendFeedback => '피드백 보내기';

  @override
  String get aboutApp => '앱 정보';

  @override
  String get searchHint => '화학식을 입력하세요';

  @override
  String get searchResult => '검색 결과';

  @override
  String get noResult => '결과가 없습니다.';

  @override
  String get name => '이름';

  @override
  String get molecularFormula => '화학식';

  @override
  String get molecularWeight => '분자량';

  @override
  String get meltingPoint => '녹는점';

  @override
  String get boilingPoint => '끓는점';

  @override
  String get density => '밀도';

  @override
  String get noInfo => '정보 없음';
}
