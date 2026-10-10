import 'dart:convert';

import 'package:akpsatu/api/api.dart';
import 'package:akpsatu/l10n/lang.dart';
import 'package:akpsatu/screens/overtime.dart';
import 'package:akpsatu/theme.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

String _today() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

Map<String, dynamic> _window({bool ok = true, num remaining = 2, String from = '17:00', String to = '19:05', String? reason}) => {
      'data': {
        'date': _today(),
        'attendance': ok || reason != null && reason.contains('pulang') ? {'in': '06:50', 'out': ok ? to : null} : null,
        'working_day': true,
        'normal_end': '17:00',
        'from': ok ? from : null,
        'to': ok ? to : null,
        'minutes': ok ? 125 : 0,
        'ok': ok,
        'reason': ok ? null : (reason ?? 'Belum ada absensi pada tanggal tersebut. Lembur diajukan setelah dikerjakan dan ada absen pulang.'),
        'max_hours': 2,
        'max_hours_per_day': 2,
        'used_hours': 2 - remaining,
        'remaining_hours': remaining,
        'attendance_required': true,
        'tolerance_minutes': 0,
      },
    };

Map<String, dynamic> _row(int id, String status, {String? note, String? by}) => {
      'id': id, 'date': '2026-10-05', 'start': '17:00', 'end': '18:30', 'hours': 1.5, 'reason': 'Perbaikan switch', 'status': status,
      'status_label': status, 'decided_by': by, 'decided_at': null, 'note': note,
    };

void main() {
  late List<http.Request> calls;

  /// Layar dijalankan terhadap server HRIS tiruan; [check] menjawab /overtimes/check.
  Future<void> open(WidgetTester tester, {required http.Response Function() check, http.Response Function(http.Request)? post, List<Map<String, dynamic>>? history, Size size = const Size(900, 3200)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    calls = [];
    SharedPreferences.setMockInitialValues({});
    L.instance.lang = AppLang.id;
    Session.instance.token = 'token';
    Session.instance.expiresAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
    Session.instance.pendingOtp = false;

    final client = MockClient((req) async {
      calls.add(req);
      final path = req.url.path;
      if (path.endsWith('/overtimes/check')) return check();
      if (path.endsWith('/overtimes') && req.method == 'GET') return _json({'data': history ?? []});
      if (path.endsWith('/overtimes') && req.method == 'POST') return post!(req);
      if (path.endsWith('/cancel')) return _json({'data': _row(9, 'cancelled')});
      return _json({'message': 'tidak ada'}, 404);
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(LangScope(child: MaterialApp(theme: buildTheme(), home: const OvertimeScreen())));
      await tester.pumpAndSettle();
    }, () => client);
    _client = client;
  }

  testWidgets('menampilkan absensi aktual, jendela lembur dan jam bawaan dibatasi 2 jam', (tester) async {
    await open(tester, check: () => _json(_window()));

    expect(find.text('Absensi aktual'), findsOneWidget);
    expect(find.text('06:50'), findsOneWidget);
    expect(find.text('19:05'), findsOneWidget);
    expect(find.text('Lembur yang bisa diajukan: 17:00 – 19:05'), findsOneWidget);
    expect(find.textContaining('Maksimal 2 jam per hari'), findsWidgets);
    // Bawaan: mulai 17:00, selesai 19:00 (2 jam, bukan sampai tap pulang 19:05).
    expect(find.text('17:00'), findsOneWidget);
    expect(find.text('19:00'), findsOneWidget);
    expect(find.text('2 jam'), findsOneWidget);
    expect(find.text('Kirim Pengajuan Lembur'), findsOneWidget);
    expect(calls.any((c) => c.url.queryParameters['date'] == _today()), isTrue);
  });

  testWidgets('kuota tersisa membatasi jam selesai', (tester) async {
    await open(tester, check: () => _json(_window(remaining: 0.75, to: '19:30')));

    expect(find.text('17:45'), findsOneWidget); // 17:00 + 45 menit
    expect(find.text('45 menit'), findsOneWidget);
    expect(find.textContaining('Sisa kuota hari ini: 0,75 jam'), findsOneWidget);
  });

  testWidgets('kirim pengajuan memanggil HRIS dengan tanggal dan jam terpilih', (tester) async {
    await open(tester, check: () => _json(_window()), post: (req) => _json({'data': _row(55, 'pending')..['date'] = _today(), 'message': 'ok'}, 201));

    await http.runWithClient(() async {
      await tester.enterText(find.byType(TextField), 'Perbaikan switch core');
      await tester.pump();
      await tester.tap(find.text('Kirim Pengajuan Lembur'));
      await tester.pumpAndSettle();
    }, () => _client);

    final post = calls.lastWhere((c) => c.method == 'POST');
    expect(jsonDecode(post.body), {'work_date': _today(), 'start_time': '17:00', 'end_time': '19:00', 'reason': 'Perbaikan switch core'});
    expect(find.text('Pengajuan lembur terkirim'), findsOneWidget);
    expect(find.text('#55'), findsOneWidget);
  });

  testWidgets('uraian pekerjaan wajib diisi sebelum kirim', (tester) async {
    await open(tester, check: () => _json(_window()), post: (_) => _json({}, 500));

    await tester.tap(find.text('Kirim Pengajuan Lembur'));
    await tester.pumpAndSettle();

    expect(find.text('Isi uraian pekerjaan.'), findsOneWidget);
    expect(calls.where((c) => c.method == 'POST'), isEmpty);
  });

  testWidgets('galat validasi dari server ditampilkan apa adanya', (tester) async {
    await open(tester, check: () => _json(_window()), post: (_) => _json({'message': 'x', 'errors': {'start_time': ['Jam lembur harus sesuai absensi aktual: antara 17:00 dan 19:05 (setelah jam pulang normal 17:00).']}}, 422));

    await http.runWithClient(() async {
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      await tester.tap(find.text('Kirim Pengajuan Lembur'));
      await tester.pumpAndSettle();
    }, () => _client);

    expect(find.textContaining('Jam lembur harus sesuai absensi aktual'), findsOneWidget);
    expect(find.text('Pengajuan lembur terkirim'), findsNothing);
  });

  testWidgets('tanggal tanpa absensi: alasan ditampilkan dan formulir tidak muncul', (tester) async {
    await open(tester, check: () => _json(_window(ok: false)));

    expect(find.textContaining('Belum ada absensi pada tanggal tersebut'), findsOneWidget);
    expect(find.text('Kirim Pengajuan Lembur'), findsNothing);
    expect(find.text('Jam mulai'), findsNothing);
  });

  testWidgets('kuota habis: formulir diganti pemberitahuan', (tester) async {
    await open(tester, check: () => _json(_window(remaining: 0)));

    expect(find.textContaining('Kuota lembur tanggal ini sudah habis'), findsOneWidget);
    expect(find.text('Kirim Pengajuan Lembur'), findsNothing);
  });

  testWidgets('server lama tanpa endpoint check: tetap bisa dipakai, server yang memeriksa', (tester) async {
    await open(tester, check: () => _json({'message': 'Not Found'}, 404));

    expect(find.textContaining('Pemeriksaan absensi belum tersedia di server'), findsOneWidget);
    expect(find.text('Kirim Pengajuan Lembur'), findsOneWidget);
  });

  testWidgets('riwayat asli dari HRIS: status, catatan penolakan, dan batalkan hanya untuk yang menunggu', (tester) async {
    await open(tester, check: () => _json(_window()), history: [_row(9, 'pending'), _row(8, 'approved'), _row(7, 'rejected', note: 'Tidak sesuai absensi', by: 'BUDI SUPER'), _row(6, 'cancelled')]);

    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Disetujui'), findsOneWidget);
    expect(find.text('Ditolak'), findsOneWidget);
    expect(find.text('Dibatalkan'), findsOneWidget);
    expect(find.text('BUDI SUPER: Tidak sesuai absensi'), findsOneWidget);
    expect(find.text('Batalkan'), findsOneWidget); // hanya satu: yang berstatus menunggu

    await http.runWithClient(() async {
      await tester.tap(find.text('Batalkan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Batalkan').last); // tombol konfirmasi di dialog
      await tester.pumpAndSettle();
    }, () => _client);

    expect(calls.any((c) => c.method == 'POST' && c.url.path.endsWith('/overtimes/9/cancel')), isTrue);
  });

  testWidgets('tidak overflow di HP sempit 360 px (Indonesia dan Korea)', (tester) async {
    await open(tester, check: () => _json(_window()), history: [_row(9, 'pending'), _row(7, 'rejected', note: 'Tidak sesuai absensi pada tanggal tersebut karena pulang lebih awal', by: 'BUDI SUPER')], size: const Size(360, 800));
    expect(tester.takeException(), isNull);

    await L.instance.set(AppLang.ko);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await L.instance.set(AppLang.id);
  });

  testWidgets('berbahasa Korea', (tester) async {
    await open(tester, check: () => _json(_window()));
    await L.instance.set(AppLang.ko);
    await tester.pump();

    expect(find.text('실제 근태'), findsOneWidget);
    expect(find.text('초과근무 신청'), findsOneWidget);
    expect(find.text('신청 가능한 초과근무: 17:00 – 19:05'), findsOneWidget);
    expect(find.text('2시간'), findsOneWidget);
    await L.instance.set(AppLang.id);
  });
}

late http.Client _client;
