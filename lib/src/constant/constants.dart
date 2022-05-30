import 'package:flutter/material.dart';
import 'package:power_file_view/power_file_view.dart';

abstract class Constants {
  static const String packageName = 'power_file_view';
  static const String channelName = 'vvkeep.power_file_view.io.channel';
  static const String viewName = 'vvkeep.power_file_view.view';
}

powerPrint(String? message, {int? wrapWidth}) {
  if (PowerFileViewManager.logEnable) {
    debugPrint(message, wrapWidth: wrapWidth);
  }
}
