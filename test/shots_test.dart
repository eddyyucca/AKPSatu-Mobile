// Menghasilkan screenshot tiap layar (390x844) untuk dibandingkan dengan mockup.
// Jalankan: flutter test test/shots_test.dart --dart-define=SHOTS_DIR=<folder>
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akpsatu/routes.dart';
import 'package:akpsatu/theme.dart';

const shotsDir = String.fromEnvironment('SHOTS_DIR', defaultValue: '');

Future<void> loadFonts() async {
  final jk = FontLoader('PlusJakartaSans');
  for (final w in [400, 500, 600, 700, 800]) {
    final f = File('assets/fonts/PlusJakartaSans-$w.ttf');
    jk.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
  }
  await jk.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File('C:/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf').readAsBytesSync())));
  await icons.load();
}

const names = {
  '/': 'Main', '/splash': 'Splash', '/token': 'Token', '/home': 'Beranda', '/profil': 'Profil', '/profil/detail': 'DetailProfil', '/profil/password': 'UbahPassword', '/profil/privasi': 'Privasi', '/absensi': 'Absensi', '/roster': 'Roster',
  '/cuti': 'Cuti', '/ftw': 'FTW', '/makan': 'Barcode', '/fitness': 'Olahraga', '/fitness/rekam': 'FitnessRecord',
  '/camp': 'Camp', '/perjalanan': 'PerjalananCuti', '/notifikasi': 'Notifikasi', '/notifikasi/push': 'NotifPush',
  '/pengajuan/cuti': 'PengajuanCuti', '/pengajuan/lembur': 'PengajuanLembur', '/itinerary': 'Itinerary',
  '/approval': 'ApprovalInbox', '/approval/detail': 'ApprovalDetail', '/driver': 'DriverManifest', '/activity': 'MyActivity',
  '/activity/form': 'FormKerja', '/p2h': 'P2H', '/ptw': 'PTW', '/ptw/buat': 'PTWForm', '/learning': 'LearningCenter', '/peta': 'PetaTambang',
};

void main() {
  setUpAll(loadFonts);
  for (final e in names.entries) {
    testWidgets('shot ${e.value}', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: MaterialApp(debugShowCheckedModeBanner: false, theme: buildTheme(), home: Builder(builder: (c) => routes[e.key]!(c))),
      ));
      await tester.runAsync(() async {
        await precacheImage(const AssetImage('assets/logo.png'), tester.element(find.byType(Scaffold).first));
      });
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      if (e.key == '/splash') await tester.pump(const Duration(milliseconds: 1700)); // ~2,5 dtk: logo & judul sudah tampil
      final err = tester.takeException();
      if (shotsDir.isNotEmpty) {
        await tester.runAsync(() async {
          final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
          final img = await b.toImage(pixelRatio: 1);
          final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!;
          Directory(shotsDir).createSync(recursive: true);
          File('$shotsDir/${e.value}.png').writeAsBytesSync(bytes.buffer.asUint8List());
        });
      }
      expect(err, isNull);
    });
  }
}
