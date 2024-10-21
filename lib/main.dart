import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'service.dart';

class ScreenMirrorController {
  static const platform = MethodChannel('external_display_channel');

  void showOnExternalDisplay(String route) async {
    try {
      await platform.invokeMethod('showFlutterWidget', route);
    } on PlatformException catch (e) {
      print("Failed to show Flutter widget: '${e.message}'.");
    }
  }

  void hideOnExternalDisplay() async {
    try {
      await platform.invokeMethod('hideFlutterWidget');
    } on PlatformException catch (e) {
      print("Failed to hide Flutter widget: '${e.message}'.");
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      routes: {
        '/showImage': (context) => const FullScreenImage(),
        '/default': (context) => const DefaultScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenMirrorService = ScreenMirrorService();

    return Scaffold(
      appBar: AppBar(title: const Text("External Display Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final isMirrored = await screenMirrorService.isScreenMirrored();
                if (isMirrored) {
                  await screenMirrorService
                      .showRouteOnExternalDisplay('/showImage');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'No external display connected or not on iOS')),
                  );
                }
              },
              child: const Text('Show Image on External Display'),
            ),
            ElevatedButton(
              onPressed: () => screenMirrorService.stopExternalDisplay(),
              child: const Text('Stop External Display'),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({super.key});

  @override
  Widget build(BuildContext context) {
    print('Media query ${MediaQuery.of(context).size}');

    return Material(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.network(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShfqn5FpTq7XM_XSP39wMUofHQpkc-wV8ymA&s',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class DefaultScreen extends StatelessWidget {
  const DefaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Default External Display Screen'),
      ),
    );
  }
}
