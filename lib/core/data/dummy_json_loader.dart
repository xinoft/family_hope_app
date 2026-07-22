import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads a dummy-data JSON asset as a list, with a simulated network delay
/// - shared by every module still on placeholder content (Timetable,
/// Meetings, Goals, Chat), so swapping one to a real API call later is a
/// one-repository change, not a pattern change.
Future<List<dynamic>> loadDummyJsonList(
  String assetPath, {
  Duration delay = const Duration(seconds: 2),
}) async {
  await Future.delayed(delay);
  final raw = await rootBundle.loadString(assetPath);
  return jsonDecode(raw) as List<dynamic>;
}
