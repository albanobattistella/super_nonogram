import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final tmpDir = Directory.systemTemp.path;

void setupMockPathProvider() {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '$tmpDir/super-nonogram-test-docs';
        } else if (methodCall.method == 'getTemporaryDirectory') {
          return '$tmpDir/super-nonogram-test-tmp';
        } else if (methodCall.method == 'getApplicationSupportDirectory') {
          return '$tmpDir/super-nonogram-test-support';
        }
        return null;
      });
}
