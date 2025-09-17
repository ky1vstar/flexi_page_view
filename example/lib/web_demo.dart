import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'main.dart';

void main() => runApp(
  DevicePreview(
    enabled: true,
    builder: (context) => MyApp(),
    isToolbarVisible: false,
    defaultDevice: Devices.ios.iPhone13,
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      home: const MyHomePage(),
    );
  }
}
