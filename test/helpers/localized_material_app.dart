import 'package:flutter/material.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

MaterialApp localizedMaterialApp({
  required Widget home,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
