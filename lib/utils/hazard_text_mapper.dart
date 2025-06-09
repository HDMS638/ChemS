List<String> getGhsImagesFromHazardText(String hazardText) {
  final map = {
    'Corrosive to metals': ['assets/images/ghs_corrosion.png'],
    'Skin corrosion/irritation': ['assets/images/ghs_corrosion.png'],
    'Serious eye damage/eye irritation': ['assets/images/ghs_corrosion.png'],
    'Acute toxicity': ['assets/images/ghs_skull.png'],
    'Gases under pressure': ['assets/images/ghs_gas.png'],
    'Flammable liquids': ['assets/images/ghs_flame.png'],
    'Oxidizing liquids': ['assets/images/ghs_flame_over_circle.png'],
    'Hazardous to the aquatic environment': ['assets/images/ghs_environment.png'],
    'Carcinogenicity': ['assets/images/ghs_health_hazard.png'],
    'Explosives': ['assets/images/ghs_Exploding_Bomb.png'],
  };

  return map.entries
      .where((entry) => hazardText.contains(entry.key))
      .expand((entry) => entry.value)
      .toSet()
      .toList();
}
