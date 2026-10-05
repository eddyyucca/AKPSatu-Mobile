import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akpsatu/main.dart';
import 'package:akpsatu/routes.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> loadRoboto() async {
  final dir = Directory('C:/flutter/bin/cache/artifacts/material_fonts');
  final loader = FontLoader('Roboto');
  for (final f in ['roboto-regular.ttf', 'roboto-bold.ttf']) {
    final file = File('${dir.path}/$f');
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(loadRoboto);

  testWidgets('Login tampil', (tester) async {
    await tester.pumpWidget(const AkpSatuApp());
    expect(find.text('Masuk'), findsWidgets);
  });

  // Render setiap layar di ukuran mockup (390x844) dan pastikan tanpa exception/overflow.
  for (final name in routes.keys) {
    testWidgets('Render $name', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
        home: Builder(builder: (c) => routes[name]!(c)),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }
}
