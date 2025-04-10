// lib/services/chemical_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> fetchChemicalInfo(String query) async {
  final cidUrl = Uri.parse(
    'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/$query/cids/JSON',
  );

  final cidResponse = await http.get(cidUrl);
  print('CID 검색 요청: $cidUrl');

  if (cidResponse.statusCode == 200) {
    final cidData = json.decode(cidResponse.body);
    final cids = cidData['IdentifierList']?['CID'];

    if (cids != null && cids.isNotEmpty) {
      final cid = cids[0];
      print('✅ CID: $cid');

      final propUrl = Uri.parse(
        'https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/$cid/property/Title,MolecularFormula,MolecularWeight/JSON',
      );
      final propResponse = await http.get(propUrl);

      if (propResponse.statusCode == 200) {
        final propData = json.decode(propResponse.body);
        final props = propData['PropertyTable']['Properties'][0];

        final viewUrl = Uri.parse(
          'https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound/$cid/JSON',
        );
        final viewResponse = await http.get(viewUrl);
        print('PUG View 요청: $viewUrl');

        if (viewResponse.statusCode == 200) {
          final viewData = json.decode(viewResponse.body);
          final sections = viewData['Record']['Section'] as List<dynamic>;

          String? extractValue(List<dynamic> sections, String heading) {
            for (final section in sections) {
              if (section['TOCHeading'] == 'Experimental Properties') {
                for (final sub in section['Section'] ?? []) {
                  if (sub['TOCHeading'] == heading) {
                    final info = sub['Information']?[0]?['Value'];
                    if (info == null) return null;

                    if (info['StringWithMarkup'] != null) {
                      String raw = info['StringWithMarkup'][0]['String'];
                      if (heading == 'Melting Point' || heading == 'Boiling Point') {
                        raw = _convertFahrenheitToCelsius(raw);
                      }
                      return raw;
                    }

                    if (info['Number'] != null) {
                      return info['Number'][0].toString();
                    }
                  }
                }
              } else if (section['Section'] != null) {
                final result = extractValue(section['Section'], heading);
                if (result != null) return result;
              }
            }
            return null;
          }

          props['MeltingPoint'] = extractValue(sections, 'Melting Point');
          props['BoilingPoint'] = extractValue(sections, 'Boiling Point');
          props['Density'] = extractValue(sections, 'Density');
        }

        return props;
      }
    }
  }

  return null;
}

String _convertFahrenheitToCelsius(String input) {
  final regex = RegExp(r'([-+]?[0-9]*\.?[0-9]+)\s*°F');
  final match = regex.firstMatch(input);
  if (match != null) {
    final fahrenheit = double.tryParse(match.group(1)!);
    if (fahrenheit != null) {
      final celsius = ((fahrenheit - 32) * 5 / 9).toStringAsFixed(1);
      return '$celsius °C';
    }
  }
  return input;
}

Future<Map<String, dynamic>?> fetchChemicalInfoWithFallback(String query) async {
  final result = await fetchChemicalInfo(query);

  if (result != null) {
    for (final key in ['MeltingPoint', 'BoilingPoint', 'Density']) {
      if (result[key] == null || result[key] == '정보 없음') {
        final fallback = await fetchWikipediaProperty(query, key);
        if (fallback != null) result[key] = fallback;
      }
    }
  }

  return result;
}

Future<String?> fetchWikipediaProperty(String query, String propertyName) async {
  final url = Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$query');
  final response = await http.get(url);

  print('📘 Wikipedia 요청: $url');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final extract = data['extract'] as String;
    print('📘 Wikipedia 응답 내용:\n$extract');

    final regexMap = {
      'Density': RegExp(r'Density[:\s]*([0-9.]+)\s*g/cm'),
      'MeltingPoint': RegExp(r'Melting point[:\s]*([-+]?[0-9.]+)\s*°?[CF]'),
      'BoilingPoint': RegExp(r'Boiling point[:\s]*([-+]?[0-9.]+)\s*°?[CF]'),
    };

    final match = regexMap[propertyName]?.firstMatch(extract);
    if (match != null) {
      print('📘 Wikipedia 매칭된 $propertyName: ${match.group(1)}');
      return '${match.group(1)} °C';
    }
  }

  return null;
}
