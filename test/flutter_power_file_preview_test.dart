import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_power_file_preview/src/flutter_power_file_preview.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_power_file_preview');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterPowerFilePreview.platformVersion, '42');
  });
}
