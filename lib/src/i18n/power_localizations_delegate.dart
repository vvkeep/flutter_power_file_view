import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'power_localizations.dart';

class PowerLocalizationsDelegate extends LocalizationsDelegate<PowerLocalizations> {
  const PowerLocalizationsDelegate();

  static const PowerLocalizationsDelegate delegate = PowerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => PowerLocalizations.languages.contains(locale.languageCode);

  @override
  Future<PowerLocalizations> load(Locale locale) {
    return SynchronousFuture<PowerLocalizations>(PowerLocalizations(locale));
  }

  @override
  bool shouldReload(PowerLocalizationsDelegate old) => false;
}
