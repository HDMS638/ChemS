import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/element_model.dart';

Future<List<ElementModel>> loadElements() async {
  final String response = await rootBundle.loadString('assets/periodic_table.json');
  final List<dynamic> data = json.decode(response);
  return data.map((e) => ElementModel.fromJson(e)).toList();
}