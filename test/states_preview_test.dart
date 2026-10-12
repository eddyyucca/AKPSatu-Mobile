// Pratinjau tampilan memuat & data kosong (menulis PNG bila SHOTS_DIR diberikan).
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akpsatu/states.dart';
import 'package:akpsatu/theme.dart';

const shotsDir = String.fromEnvironment('SHOTS_DIR', defaultValue: '');

void main() {
  setUpAll(() async {
    final jk = FontLoader('PlusJakartaSans');
    for (final w in [400, 500, 600, 700, 800]) {
      jk.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())));
    }
    await jk.load();
  });

  Future<void> shot(WidgetTester tester, String name, Widget child, {Size size = const Size(390, 700)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: key,
      child: MaterialApp(debugShowCheckedModeBanner: false, theme: buildTheme(), home: Scaffold(backgroundColor: C.bg, body: SafeArea(child: child))),
    ));
    await tester.runAsync(() async {
      await precacheImage(const AssetImage('assets/logo.png'), tester.element(find.byType(Scaffold).first));
    });
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    if (shotsDir.isNotEmpty) {
      await tester.runAsync(() async {
        final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final img = await b.toImage(pixelRatio: 1);
        final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
        Directory(shotsDir).createSync(recursive: true);
        File('$shotsDir/$name.png').writeAsBytesSync(bytes.buffer.asUint8List());
      });
    }
  }

  testWidgets('loading', (t) => shot(t, 'state_loading', const Column(children: [Expanded(child: LoadingView()), Padding(padding: EdgeInsets.all(16), child: SkeletonCards(count: 2)), LoadingView(compact: true)])));
  testWidgets('kosong', (t) => shot(t, 'state_empty', const Column(children: [
        EmptyState(icon: 'bell', title: 'Belum ada notifikasi', text: 'Pemberitahuan baru akan muncul di sini.'),
        EmptyState(icon: 'leave', title: 'Belum ada pengajuan cuti', text: 'Pengajuan cuti yang Anda buat akan tampil di sini.', color: C.orange, bg: C.orangeBg, compact: true),
      ]), size: const Size(390, 520)));
}
