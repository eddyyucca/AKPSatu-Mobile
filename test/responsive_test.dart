// Uji responsif: render setiap layar di beberapa ukuran layar & skala teks,
// lalu laporkan semua overflow / exception layout.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akpsatu/routes.dart';
import 'package:akpsatu/theme.dart';

Future<void> loadFonts() async {
  final jk = FontLoader('PlusJakartaSans');
  for (final w in [400, 500, 600, 700, 800]) {
    jk.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())));
  }
  await jk.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File('C:/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf').readAsBytesSync())));
  await icons.load();
}

const sizes = <String, Size>{
  'kecil 320x568': Size(320, 568),
  'kecil 360x640': Size(360, 640),
  'umum 360x800': Size(360, 800),
  'umum 390x844': Size(390, 844),
  'besar 412x915': Size(412, 915),
  'tablet 768x1024': Size(768, 1024),
};

void main() {
  setUpAll(loadFonts);
  for (final scale in [1.0, 1.3]) {
    for (final s in sizes.entries) {
      testWidgets('responsif ${s.key} teks x$scale', (tester) async {
        tester.view.physicalSize = s.value;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final errors = <String>[];
        final old = FlutterError.onError;
        FlutterError.onError = (d) {
          final m = d.exceptionAsString();
          final loc = RegExp(r'lib/[\w/\.]+:\d+').firstMatch(d.toString())?.group(0) ?? '?';
          errors.add('${m.split('\n').first} @ $loc');
        };
        for (final r in routes.keys) {
          if (r == '/splash') continue;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          await tester.pumpWidget(MaterialApp(
            theme: buildTheme(),
            builder: appBuilder,
            home: Builder(builder: (c) => routes[r]!(c)),
          ));
          await tester.pump(const Duration(milliseconds: 300));
          final before = errors.length;
          final ex = tester.takeException();
          if (ex != null) errors.add('$ex');
          if (errors.length > before) {
            for (var i = before; i < errors.length; i++) {
              errors[i] = '[$r] ${errors[i]}';
            }
          }
          // tandai error yang muncul saat pump untuk rute ini
          for (var i = 0; i < errors.length; i++) {
            if (!errors[i].startsWith('[')) errors[i] = '[$r] ${errors[i]}';
          }
        }
        FlutterError.onError = old;
        expect(errors, isEmpty, reason: errors.toSet().join('\n'));
      });
    }
  }
}
