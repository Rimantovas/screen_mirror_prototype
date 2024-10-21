import 'dart:io';

import 'package:flutter/services.dart';

class ScreenMirrorService {
  static final ScreenMirrorService _instance = ScreenMirrorService._internal();
  factory ScreenMirrorService() => _instance;

  ScreenMirrorService._internal();

  static const platform = MethodChannel('external_display_channel');

  Future<bool> isScreenMirrored() async {
    if (!Platform.isIOS) return false;

    try {
      final bool result = await platform.invokeMethod('isScreenMirrored');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check screen mirroring status: '${e.message}'.");
      return false;
    }
  }

  Future<void> showRouteOnExternalDisplay(String route) async {
    if (!Platform.isIOS) return;

    try {
      await platform.invokeMethod('showFlutterWidget', route);
    } on PlatformException catch (e) {
      print("Failed to show route on external display: '${e.message}'.");
    }
  }

  Future<void> stopExternalDisplay() async {
    if (!Platform.isIOS) return;

    try {
      await platform.invokeMethod('hideFlutterWidget');
    } on PlatformException catch (e) {
      print("Failed to stop external display: '${e.message}'.");
    }
  }
}
