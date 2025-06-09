List<String> extractGhsHazardTexts(Map<String, dynamic> json) {
  final result = <String>[];

  final record = json['Record'];
  final sections = record?['Section'] as List<dynamic>?;

  if (sections == null) return result;

  for (final section in sections) {
    if (section['TOCHeading'] == 'Safety and Hazards') {
      final safetySections = section['Section'] as List<dynamic>? ?? [];
      for (final subSection in safetySections) {
        if (subSection['TOCHeading'] == 'GHS Classification') {
          final infos = subSection['Information'] as List<dynamic>? ?? [];
          for (final info in infos) {
            final value = info['Value'];
            final texts = value?['StringWithMarkup'] as List<dynamic>? ?? [];
            for (final t in texts) {
              final text = t['String'] as String? ?? '';
              result.add(text);
            }
          }
        }
      }
    }
  }

  return result;
}
