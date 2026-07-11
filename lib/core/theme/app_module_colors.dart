import 'package:flutter/material.dart';

import '../constants/app_module.dart';

/// Fixed accent color per module - deterministic (not cycled by list
/// position) so a module's color stays the same everywhere it's shown
/// (home grid, module page icon, etc.), which is what "consistent" means
/// for a colorful UI. Independent of the brand seed color in [AppTheme],
/// since these are used as fixed identifiers, not the primary brand hue.
class AppModuleColors {
  AppModuleColors._();

  static const Map<AppModule, Color> _colors = {
    AppModule.circulars: Color(0xFFEF6C00),
    AppModule.attendance: Color(0xFF1E88E5),
    AppModule.timetable: Color(0xFF8E24AA),
    AppModule.meetings: Color(0xFF00897B),
    AppModule.goals: Color(0xFFE53935),
    AppModule.reports: Color(0xFF3949AB),
    AppModule.finance: Color(0xFF2E7D32),
    AppModule.gallery: Color(0xFFD81B60),
    AppModule.approvals: Color(0xFFF9A825),
    AppModule.chat: Color(0xFF00ACC1),
  };

  static Color of(AppModule module) => _colors[module] ?? Colors.blueGrey;
}
