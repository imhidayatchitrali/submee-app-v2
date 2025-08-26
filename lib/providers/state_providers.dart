import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/services/config_service.dart';

import '../models/app_version.dart';

final localeProvider = StateProvider<Locale>((ref) {
  final String localeName = Platform.localeName;
  final List<String> parts = localeName.split('_');

  final String languageCode = parts[0];
  final String? countryCode = parts.length > 1 ? parts[1] : null;

  return Locale(languageCode, countryCode);
});

final appVersionProvider = FutureProvider<AppVersion>((ref) {
  return ref.read(configService).getAppVersion();
});
