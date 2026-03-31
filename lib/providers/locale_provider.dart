import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = WidgetsBinding.instance.window.locale.languageCode == 'ar'
      ? const Locale('ar')
      : const Locale('en');

  Locale get locale => _locale;

  void toggle() {
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('ar');
    }
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
