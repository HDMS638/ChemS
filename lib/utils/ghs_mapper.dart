List<String> getGhsImagePathsFromHCodes(List<String> hCodes) {
  final List<String> imagePaths = [];

  final Map<String, String> hCodeToImage = {
    'H200': 'assets/images/ghs_explosion.png',
    'H225': 'assets/images/ghs_flame.png',
    'H270': 'assets/images/ghs_flame_over_circle.png',
    'H280': 'assets/images/ghs_gas.png',
    'H290': 'assets/images/ghs_corrosion.png',
    'H300': 'assets/images/ghs_skull.png',
    'H314': 'assets/images/ghs_corrosion.png',
    'H315': 'assets/images/ghs_exclamation.png',
    'H335': 'assets/images/ghs_exclamation.png',
    'H350': 'assets/images/ghs_health_hazard.png',
    'H400': 'assets/images/ghs_environment.png',
  };

  for (final hCode in hCodes) {
    final path = hCodeToImage[hCode];
    if (path != null && !imagePaths.contains(path)) {
      imagePaths.add(path);
    }
  }

  return imagePaths;
}
