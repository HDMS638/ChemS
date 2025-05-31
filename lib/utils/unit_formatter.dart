String? addUnit(String? value, String unit) {
  if (value == null || value.isEmpty) return null;
  if (value.contains(unit) || value.contains(RegExp(r'[a-zA-Z%]'))) {
    return value;
  }
  return '$value $unit';
}

String? addTemperatureUnit(String? value) => addUnit(value, '°C');
String? addDensityUnit(String? value) => addUnit(value, 'g/cm³');
