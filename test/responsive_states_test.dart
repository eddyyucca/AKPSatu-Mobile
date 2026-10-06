// Uji responsif untuk keadaan interaktif (tab, hasil pencarian, dialog/overlay, layar hasil).
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

/// (rute, langkah-langkah ketuk berdasarkan teks)
const scenarios = <(String, List<String>)>[
  ('/home', ['@cuti']),
  ('/home', ['@zzzz']),
  ('/fitness', ['Riwayat']),
  ('/ptw', ['Riwayat']),
  ('/learning', ['Riwayat']),
  ('/learning', ['Training Saya (2)']),
  ('/approval', ['Selesai']),
  ('/approval/detail', ['Tolak']),
  ('/approval/detail', ['Setujui']),
  ('/p2h', ['Buka Kamera']),
  ('/p2h', ['Buka Kamera', 'Simulasi: barcode terbaca']),
  ('/peta', ['Bagikan Peta', 'Buat token akses']),
  ('/itinerary', ['Lihat rincian lumpsum']),
  ('/perjalanan', ['Kembali · 11 Okt']),
  ('/driver', ['11:30']),
  ('/activity', ['Compliance']),
  ('/activity', ['Mine Plan']),
  ('/camp', ['Lapor Kerusakan Kamar']),
  ('/ftw', ['Sehat']),
  ('/roster', ['Hari ini']),
  ('/pengajuan/cuti', ['Kirim Pengajuan']),
  ('/pengajuan/lembur', ['Kirim Pengajuan Lembur']),
  ('/profil', ['Hapus Riwayat']),
  ('/profil', ['Keluar']),
  ('/profil/password', ['Simpan Password']),
  ('/profil/privasi', []),
];

void main() {
  setUpAll(loadFonts);
  for (final sz in const [Size(320, 568), Size(360, 800), Size(768, 1024)]) {
    testWidgets('state responsif ${sz.width.toInt()}x${sz.height.toInt()}', (tester) async {
      tester.view.physicalSize = sz;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      final errors = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (d) {
        final loc = RegExp(r'lib/[\w/\.]+:\d+').firstMatch(d.toString())?.group(0) ?? '?';
        errors.add('${d.exceptionAsString().split('\n').first} @ $loc');
      };
      for (final (route, steps) in scenarios) {
        final tag = '[$route ${steps.join(' > ')}]';
        final before = errors.length;
        await tester.pumpWidget(MaterialApp(theme: buildTheme(), builder: appBuilder, home: Builder(builder: (c) => routes[route]!(c))));
        await tester.pump(const Duration(milliseconds: 300));
        for (final st in steps) {
          if (st.startsWith('@')) {
            final f = find.byType(TextField);
            if (f.evaluate().isNotEmpty) await tester.enterText(f.first, st.substring(1));
          } else {
            final f = find.text(st);
            if (f.evaluate().isEmpty) continue;
            try {
              await tester.ensureVisible(f.first);
            } catch (_) {}
            await tester.tap(f.first, warnIfMissed: false);
          }
          await tester.pump(const Duration(milliseconds: 350));
        }
        await tester.pump(const Duration(milliseconds: 300));
        final ex = tester.takeException();
        if (ex != null) errors.add('$ex');
        for (var i = before; i < errors.length; i++) {
          errors[i] = '$tag ${errors[i]}';
        }
      }
      FlutterError.onError = old;
      expect(errors, isEmpty, reason: errors.toSet().join('\n'));
    });
  }
}
