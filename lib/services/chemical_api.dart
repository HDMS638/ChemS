import 'dart:convert';
import 'package:http/http.dart' as http;

/// PubChem API로부터 CID를 가져옴
Future<int?> fetchCID(String query) async {
  final url = Uri.parse(
    'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/cids/JSON',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final cids = decoded['IdentifierList']?['CID'];
    if (cids != null && cids.isNotEmpty) {
      return cids[0];
    }
  }
  return null;
}

/// CID를 이용하여 상세 화학 물질 정보(JSON 포함) 가져옴
Future<Map<String, dynamic>?> fetchChemicalInfoFromPubChem(int cid) async {
  final url = Uri.parse(
    'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    return parseChemicalInfo(decoded);
  }
  return null;
}

/// PubChem JSON 구조에서 원하는 정보 추출 (재귀적 탐색 포함)
Map<String, dynamic> parseChemicalInfo(Map<String, dynamic> json) {
  String? searchValue(String heading, dynamic section) {
    if (section is Map<String, dynamic>) {
      if (section['TOCHeading'] == heading && section.containsKey('Information')) {
        final info = section['Information'][0];
        final value = info['Value'];
        if (value.containsKey('StringWithMarkup')) {
          return value['StringWithMarkup'][0]['String'];
        } else if (value.containsKey('Number')) {
          return value['Number'].toString();
        }
      }

      if (section.containsKey('Section')) {
        for (var sub in section['Section']) {
          final result = searchValue(heading, sub);
          if (result != null) return result;
        }
      }
    } else if (section is List) {
      for (var sub in section) {
        final result = searchValue(heading, sub);
        if (result != null) return result;
      }
    }

    return null;
  }

  final record = json['Record'];
  final sections = record['Section'];

  return {
    'Title': record['RecordTitle'] ?? 'Unknown', // ✅ 이름 직접 추출
    'MolecularWeight': searchValue('Molecular Weight', sections) ?? 'Unknown',
    'MeltingPoint': searchValue('Melting Point', sections) ?? 'Unknown',
    'BoilingPoint': searchValue('Boiling Point', sections) ?? 'Unknown',
    'Density': searchValue('Density', sections) ?? 'Unknown',
    'RawJson': json,
  };
}

/// 검색어 기반으로 PubChem에서 CID → 상세정보 추출 → 반환
Future<Map<String, dynamic>?> fetchChemicalInfoWithFallback(String query) async {
  final cid = await fetchCID(query);
  if (cid == null) return null;

  final info = await fetchChemicalInfoFromPubChem(cid);
  return info;
}
