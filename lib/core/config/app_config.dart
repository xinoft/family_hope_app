import 'package:flutter/material.dart';

/// Single seam for rebranding this app for another school: swap out
/// [AppConfig.current] (or later, load it from a build flavor / remote
/// config) and the rest of the app follows.
class AppConfig {
  final String appName;
  final String organizationName;
  final String apiBaseUrl;
  final Color brandSeedColor;

  const AppConfig({
    required this.appName,
    required this.organizationName,
    required this.apiBaseUrl,
    required this.brandSeedColor,
  });

  static const AppConfig current = AppConfig(
    appName: 'Family Hope',
    organizationName: 'Family Hope Center',
    apiBaseUrl: 'https://vuexyapi.xinoft.com',
    brandSeedColor: Color(0xFF2E7D32),
  );
}
