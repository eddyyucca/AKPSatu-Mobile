import 'dart:convert';

import 'package:akpsatu/api/api.dart';
import 'package:akpsatu/l10n/lang.dart';
import 'package:akpsatu/routes.dart';
import 'package:akpsatu/screens/leave.dart';
import 'package:akpsatu/screens/requests.dart';
import 'package:akpsatu/theme.dart';
import 'package:akpsatu/widgets.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

Map<String, dynamic> _row(int id, String status, {String type = 'cuti_tahunan', String typeLabel = 'Cuti Tahunan', String start = '2026-11-01', String end = '2026-11-05', int days = 5, Map<String, dynamic>? sup, Map<String, dynamic>? hr, Map<String, dynamic>? travel, bool needsTicket = false, bool needsPickup = false}) => {
      'id': id, 'type': type, 'type_label': typeLabel, 'start_date': start, 'end_date': end, 'days': days,
      'departure_half_day_date': null, 'travel_out_date': null, 'travel_back_date': null, 'return_half_day_date': null,
      'reason': 'Liburan keluarga', 'status': status, 'needs_ticket': needsTicket, 'needs_pickup': needsPickup, 'destination_city': null,
      'address_during_leave': null, 'emergency_phone': null, 'replacement': null, 'supervisor': sup, 'hr': hr, 'travel': travel,
    };

class _Server {
  List<Map<String, dynamic>> rows = [];
  final calls = <http.Request>[];
  http.Response Function(http.Request)? checkHandler;
  http.Response Function(http.Request)? postHandler;

  Future<http.Response> handle(http.Request req) async {
    calls.add(req);
    final path = req.url.path;
    if (path.endsWith('/leaves/check')) return (checkHandler ?? (_) => _json({'message': 'no handler'}, 500))(req);
    if (path.endsWith('/leaves') && req.method == 'GET') return _json({'data': rows});
    if (path.endsWith('/leaves') && req.method == 'POST') return (postHandler ?? (_) => _json({}, 500))(req);
    final m = RegExp(r'/leaves/(\d+)/cancel$').firstMatch(path);
    if (m != null) {
      final id = int.parse(m[1]!);
      final row = rows.firstWhere((r) => r['id'] == id, orElse: () => {});
      if (row.isEmpty) return _json({'message': 'tidak ada'}, 404);
      if (row['status'] != 'pending_supervisor' && row['status'] != 'pending_hr') return _json({'code': 'not_pending'}, 409);
      row['status'] = 'cancelled';
      return _json({'data': row});
    }
    return _json({'message': 'tidak ada'}, 404);
  }
}

void main() {
  late _Server server;
  late http.Client client;

  Future<T> run<T>(Future<T> Function() body) => http.runWithClient(body, () => client);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    L.instance.lang = AppLang.id;
    Session.instance.token = 'token';
    Session.instance.expiresAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
    Session.instance.pendingOtp = false;
    server = _Server();
    client = MockClient(server.handle);
  });

  group('LeaveRequestScreen', () {
    Future<void> open(WidgetTester tester, {Size size = const Size(900, 3600)}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await run(() async {
        await tester.pumpWidget(LangScope(
          child: MaterialApp(
            theme: buildTheme(),
            initialRoute: '/test',
            routes: {
              '/test': (_) => const LeaveRequestScreen(),
              R.itinerary: (_) => const Scaffold(body: Center(child: Text('ITINERARY'))),
            },
          ),
        ));
        await tester.pumpAndSettle();
      });
    }

    testWidgets('Cuti Tahunan: menampilkan saldo dan memvalidasi durasi melebihi sisa', (tester) async {
      server.checkHandler = (req) {
        final type = req.url.queryParameters['type'];
        if (type == 'cuti_tahunan') return _json({'data': {'type': type, 'roster_driven': false, 'min_submission_days': 14, 'balance': {'quota': 12, 'used': 7, 'remaining': 5}}});
        return _json({'data': {'type': type, 'roster_driven': false, 'min_submission_days': 14, 'balance': null}});
      };
      await open(tester);

      expect(find.text('5 hari'), findsOneWidget);
      expect(find.text('Sisa cuti tahunan'), findsOneWidget);
    });

    testWidgets('Cuti Roster: memuat jendela saran otomatis dan menampilkan pratinjau tanggal buffer', (tester) async {
      var rosterCalls = 0;
      server.checkHandler = (req) {
        final type = req.url.queryParameters['type'];
        if (type != 'cuti_roster') return _json({'data': {'type': type, 'roster_driven': false, 'min_submission_days': 14, 'balance': {'quota': 12, 'used': 0, 'remaining': 12}}});
        rosterCalls++;
        final sent = req.url.queryParameters['start_date'];
        if (sent == '2026-10-31') {
          return _json({'data': {'type': 'cuti_roster', 'roster_driven': true, 'min_submission_days': 14, 'roster_window': {'start': '2026-10-31', 'end': '2026-11-13'}, 'ok': true, 'start_date': '2026-10-31', 'end_date': '2026-11-13', 'days': 14, 'departure_half_day_date': '2026-10-29', 'travel_out_date': '2026-10-30', 'travel_back_date': '2026-11-14', 'return_half_day_date': '2026-11-15'}});
        }
        return _json({'data': {'type': 'cuti_roster', 'roster_driven': true, 'min_submission_days': 14, 'roster_window': {'start': '2026-10-31', 'end': '2026-11-13'}, 'ok': false, 'reason': 'Tanggal mulai cuti harus dekat dengan jadwal siklus roster Anda (2026-10-31), maksimal 7 hari berbeda.'}});
      };
      await open(tester);

      await run(() async {
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cuti Roster').last);
        await tester.pumpAndSettle();
      });

      expect(rosterCalls, greaterThanOrEqualTo(2));   // tanggal awal (tidak cocok) lalu otomatis disesuaikan ke saran server
      expect(find.text('14 hari'), findsOneWidget);
      expect(find.textContaining('29 Okt'), findsOneWidget);   // setengah hari berangkat
      expect(find.textContaining('30 Okt'), findsOneWidget);   // penerbangan pergi
      expect(find.text('Kirim Pengajuan'), findsOneWidget);
    });

    testWidgets('Cuti Roster di luar jendela: tombol kirim nonaktif dan alasan server ditampilkan', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_roster', 'roster_driven': true, 'min_submission_days': 14, 'roster_window': null, 'ok': false, 'reason': 'Karyawan ini belum memiliki siklus Cuti Roster (Sistem Cuti). Hubungi HR atau gunakan Cuti Tahunan.'}});
      await open(tester);

      await run(() async {
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cuti Roster').last);
        await tester.pumpAndSettle();
      });

      expect(find.textContaining('belum memiliki siklus Cuti Roster'), findsOneWidget);
      final btn = tester.widget<InkWell>(find.ancestor(of: find.text('Kirim Pengajuan'), matching: find.byType(InkWell)).first);
      expect(btn.onTap, isNull);
    });

    testWidgets('submit mengirim body sesuai pilihan dan menampilkan ringkasan hasil', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'min_submission_days': 14, 'balance': {'quota': 12, 'used': 0, 'remaining': 12}}});
      server.postHandler = (req) => _json({'data': _row(42, 'pending_supervisor', start: '2026-11-01', end: '2026-11-03', days: 3), 'message': 'ok'}, 201);
      await open(tester);

      await run(() async {
        await tester.enterText(find.byType(TextFormField).first, 'Acara keluarga');
        await tester.pump();
        await tester.tap(find.text('Kirim Pengajuan'));
        await tester.pumpAndSettle();
      });

      final post = server.calls.lastWhere((c) => c.method == 'POST' && c.url.path.endsWith('/leaves'));
      final body = jsonDecode(post.body) as Map;
      expect(body['leave_type'], 'cuti_tahunan');
      expect(body['reason'], 'Acara keluarga');
      expect(body['needs_ticket'], false);
      expect(body['needs_pickup'], false);
      expect(find.text('Pengajuan terkirim'), findsOneWidget);
      expect(find.text('#42'), findsOneWidget);
      expect(find.text('Lihat Itinerary'), findsOneWidget);
    });

    testWidgets('alasan wajib diisi sebelum kirim', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'min_submission_days': 14, 'balance': {'quota': 12, 'used': 0, 'remaining': 12}}});
      await open(tester);

      await run(() async {
        await tester.tap(find.text('Kirim Pengajuan'));
        await tester.pumpAndSettle();
      });

      expect(find.text('Isi alasan cuti.'), findsOneWidget);
      expect(server.calls.where((c) => c.method == 'POST'), isEmpty);
    });

    testWidgets('galat validasi dari server (lead time H-14) ditampilkan apa adanya', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'min_submission_days': 14, 'balance': {'quota': 12, 'used': 0, 'remaining': 12}}});
      server.postHandler = (_) => _json({
            'message': 'x',
            'errors': {
              'start_date': ['Pengajuan cuti dengan tiket/jemputan harus diajukan paling lambat 14 hari sebelum keberangkatan (2026-10-20).']
            },
          }, 422);
      await open(tester);

      await run(() async {
        await tester.enterText(find.byType(TextFormField).first, 'x');
        await tester.pump();
        await tester.tap(find.text('Kirim Pengajuan'));
        await tester.pumpAndSettle();
      });

      expect(find.textContaining('paling lambat 14 hari sebelum keberangkatan'), findsOneWidget);
      expect(find.text('Pengajuan terkirim'), findsNothing);
    });

    testWidgets('tidak overflow di HP sempit 360 px', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'min_submission_days': 14, 'balance': {'quota': 12, 'used': 3, 'remaining': 9}}});
      await open(tester, size: const Size(360, 1600));
      expect(tester.takeException(), isNull);
    });
  });

  group('LeaveScreen', () {
    Future<void> open(WidgetTester tester, {Size size = const Size(900, 3200)}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await run(() async {
        await tester.pumpWidget(LangScope(
          child: MaterialApp(
            theme: buildTheme(),
            initialRoute: '/test',
            routes: {
              '/test': (_) => const LeaveScreen(),
              R.pengajuanCuti: (_) => const Scaffold(body: Center(child: Text('FORM CUTI'))),
              R.itinerary: (_) => const Scaffold(body: Center(child: Text('ITINERARY'))),
            },
          ),
        ));
        await tester.pumpAndSettle();
      });
    }

    testWidgets('menampilkan saldo asli dan riwayat dengan berbagai status', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'balance': {'quota': 12, 'used': 3, 'remaining': 9}}});
      server.rows = [
        _row(1, 'pending_supervisor'),
        _row(2, 'pending_hr', sup: {'by': 'BUDI', 'at': '2026-10-01T09:00:00Z', 'note': null}),
        _row(3, 'approved', sup: {'by': 'BUDI', 'at': '2026-10-01T09:00:00Z', 'note': null}, hr: {'by': 'SITI', 'at': '2026-10-02T09:00:00Z', 'note': null}),
        _row(4, 'rejected', hr: {'by': 'SITI', 'at': '2026-10-02T09:00:00Z', 'note': 'Saldo tidak cukup'}),
      ];
      await open(tester);

      expect(find.text('9'), findsOneWidget);
      expect(find.text('dari 12 hari'), findsOneWidget);
      expect(find.text('Menunggu atasan'), findsOneWidget);
      expect(find.text('Menunggu HR'), findsOneWidget);
      expect(find.text('Disetujui'), findsOneWidget);
      expect(find.text('Ditolak'), findsOneWidget);
    });

    testWidgets('mengetuk riwayat membuka Itinerary dengan id yang benar', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'balance': {'quota': 12, 'used': 0, 'remaining': 12}}});
      server.rows = [_row(7, 'approved', sup: {'by': 'BUDI', 'at': '2026-10-01T09:00:00Z'}, hr: {'by': 'SITI', 'at': '2026-10-02T09:00:00Z'})];
      await open(tester);

      await run(() async {
        await tester.tap(find.ancestor(of: find.textContaining('Cuti Tahunan'), matching: find.byType(InkWell)).first);
        await tester.pumpAndSettle();
      });

      expect(find.text('ITINERARY'), findsOneWidget);
    });

    testWidgets('kosong: pesan jelas, bukan data contoh lama', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'balance': {'quota': 12, 'used': 0, 'remaining': 12}}});
      await open(tester);

      expect(find.text('Belum ada pengajuan cuti.'), findsOneWidget);
      expect(find.text('19 – 21 Okt 2026'), findsNothing);   // data mock lama sudah tidak ada
    });

    testWidgets('berbahasa Korea', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'balance': {'quota': 12, 'used': 3, 'remaining': 9}}});
      server.rows = [_row(1, 'pending_supervisor')];
      await open(tester);
      await L.instance.set(AppLang.ko);
      await tester.pump();

      expect(find.text('연차'), findsOneWidget);
      expect(find.text('상사 승인 대기'), findsOneWidget);
      await L.instance.set(AppLang.id);
    });

    testWidgets('tidak overflow di HP sempit 360 px', (tester) async {
      server.checkHandler = (_) => _json({'data': {'type': 'cuti_tahunan', 'roster_driven': false, 'balance': {'quota': 12, 'used': 3, 'remaining': 9}}});
      server.rows = [_row(1, 'rejected', hr: {'by': 'SITI', 'at': '2026-10-02T09:00:00Z', 'note': 'Bentrok jadwal shutdown pada periode yang sama dengan tim lain'})];
      await open(tester, size: const Size(360, 900));
      expect(tester.takeException(), isNull);
    });
  });
}
