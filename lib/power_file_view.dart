import 'dart:async';

import 'package:flutter/services.dart';

class PowerFileView {
  static const MethodChannel _channel = MethodChannel('power_file_view');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
