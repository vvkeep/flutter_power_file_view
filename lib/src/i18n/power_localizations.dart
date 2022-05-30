import 'package:flutter/material.dart';

abstract class PowerLocalizationsBase {
  const PowerLocalizationsBase(this.locale);

  final Locale? locale;

  Object? getItem(String key);

  String get reload => getItem('reload').toString();

  String get unsupportedPlatform => getItem('unsupportedPlatform').toString();

  String get nonExistent => getItem('nonExistent').toString();

  String get unsupportedType => getItem('unsupportedType').toString();

  String get engineFail => getItem('engineFail').toString();

  String get fileFail => getItem('fileFail').toString();

  String get unkownError => getItem('unkownError').toString();

  String get engineLoading => getItem('engineLoading').toString();

  String get fileLoading => getItem('fileLoading').toString();

  String get loading => getItem('loading').toString();
}

/// localizations
class PowerLocalizations extends PowerLocalizationsBase {
  const PowerLocalizations(Locale? locale) : super(locale);

  static const PowerLocalizations _static = PowerLocalizations(null);

  @override
  Object? getItem(String key) {
    Map<String, Object>? localData;
    if (locale != null) {
      localData = localizedValues[locale!.languageCode];
    }
    if (localData == null) {
      return localizedValues['zh']![key];
    }
    return localData[key];
  }

  static PowerLocalizations of(BuildContext context) {
    return Localizations.of<PowerLocalizations>(context, PowerLocalizations) ?? _static;
  }

  /// Language Support
  static const List<String> languages = <String>['en', 'zh'];

  /// Language Values
  static const Map<String, Map<String, Object>> localizedValues = <String, Map<String, Object>>{
    'en': <String, String>{
      'reload': 'Reload',
      'unsupportedPlatform': 'Currently only supports Android, iOS',
      'nonExistent': 'Non-existent file',
      'unsupportedType': 'Does not support opening files of type %s',
      'engineFail': 'The engine failed to load, please reload',
      'fileFail': 'File failed to load, please reload',
      'unkownError': 'unkown error',
      'engineLoading': 'Engine loading(%s)',
      'fileLoading': 'File loading(%s)',
      'loading': 'loading',
    },
    'zh': <String, String>{
      'reload': '重新加载',
      'unsupportedPlatform': '当前仅支持Android、iOS',
      'nonExistent': '文件不存在',
      'unsupportedType': '不支持打开%s类型的文件',
      'engineFail': '引擎加载失败，请重试',
      'fileFail': '文件加载失败',
      'unkownError': '未知错误',
      'engineLoading': '引擎加载中(%s)',
      'fileLoading': '文件加载中(%s)',
      'loading': '加载中',
    },
  };
}
