import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akpsatu/api/api.dart';
import 'package:akpsatu/api/komplain.dart';
import 'package:akpsatu/routes.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

int get _later => DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;

const _types = [
  {'value': 'receptionist', 'label': 'Receptionist', 'room_required': true, 'room_optional': false},
  {'value': 'hk', 'label': 'Housekeeping', 'room_required': false, 'room_optional': false},
  {'value': 'laundry', 'label': 'Laundry', 'room_required': false, 'room_optional': true},
];

const _buildings = [
  {'group': 'Mess Garnerit', 'items': ['GARNERIT A', 'GARNERIT B']},
];

Map<String, dynamic> _item(String ticket, String status, {bool overdue = false}) => {
      'ticket': ticket,
      'type': 'hk',
      'type_label': 'Housekeeping',
      'status': status,
      'status_label': status,
      'building': 'GARNERIT A',
      'room_number': '12',
      'description': 'Kamar mandi bocor di $ticket',
      'photo_count': 1,
      'created_at': '2026-10-09T03:15:00+00:00',
      'sla_deadline': '2026-10-09T11:15:00+00:00',
      'is_overdue': overdue,
      'reporter_name': 'BUDI',
    };

/// Server komplain palsu. [role] = peran Portal pengguna (null = karyawan biasa).
class _Fake {
  final String? role;
  final posts = <http.Request>[];
  _Fake(this.role);

  MockClient get client => MockClient((req) async {
        final path = req.url.path;
        if (path == '/api/mobile/app-token') return _json({'token': 'modul', 'expires_at': _later, 'role': role});
        if (path == '/api/mobile/v1/options') {
          return _json({'data': {'types': _types, 'buildings': _buildings, 'user': {'name': 'EDDY', 'nik': '32601949', 'role': role, 'can_monitor': role != null}}});
        }
        if (path == '/api/mobile/v1/complaints' && req.method == 'POST') {
          posts.add(req);
          return _json({'data': {..._item('RCP-0001', 'open'), 'type_label': 'Receptionist'}}, 201);
        }
        if (path == '/api/mobile/v1/complaints') {
          return _json({'data': [_item('HKP-0001', 'open'), _item('HKP-0002', 'closed')], 'meta': {'page': 1, 'last_page': 1, 'total': 2}});
        }
        if (path == '/api/mobile/v1/monitor') {
          return _json({
            'data': [_item('HKP-0003', 'open', overdue: true)],
            'meta': {'page': 1, 'last_page': 1, 'total': 1},
            'summary': {'open': 4, 'progress': 2, 'closed': 9, 'rejected': 1, 'overdue': 3, 'total': 16},
          });
        }
        return _json({'message': 'tidak ada'}, 404);
      });
}

Future<void> _open(WidgetTester tester, _Fake fake) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  await Session.instance.save('login-token', _later, {'name': 'EDDY', 'employee_no': '32601949'});
  KomplainApi.instance = KomplainApi(client: fake.client, baseUrl: 'http://komplain.test', portalUrl: 'http://portal.test');

  await tester.pumpWidget(MaterialApp(routes: routes, initialRoute: R.komplain));
  await tester.pumpAndSettle();
}

/// Muat font aplikasi seperti tes responsif lain, agar tata letak sama dengan di perangkat.
Future<void> _loadFonts() async {
  final jk = FontLoader('PlusJakartaSans');
  for (final w in [400, 500, 600, 700, 800]) {
    jk.addFont(Future.value(ByteData.sublistView(File('assets/fonts/PlusJakartaSans-$w.ttf').readAsBytesSync())));
  }
  await jk.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(File('C:/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf').readAsBytesSync())));
  await icons.load();
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('Beranda: ketuk menu Komplain GA membuka layar Komplain GA', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final fake = _Fake(null);
    SharedPreferences.setMockInitialValues({});
    await Session.instance.save('login-token', _later, {'name': 'EDDY', 'employee_no': '32601949'});
    KomplainApi.instance = KomplainApi(client: fake.client, baseUrl: 'http://komplain.test', portalUrl: 'http://portal.test');

    await tester.pumpWidget(MaterialApp(routes: routes, initialRoute: R.home));
    await tester.pump(const Duration(seconds: 1));

    final menu = find.text('Komplain GA');
    await tester.scrollUntilVisible(menu, 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(menu);
    await tester.pumpAndSettle();

    expect(find.text('Laporan Saya'), findsNothing, reason: 'karyawan biasa tidak punya tab');
    expect(find.text('HKP-0001'), findsOneWidget);
    expect(find.text('Buat Laporan'), findsOneWidget);
  });

  testWidgets('karyawan biasa: hanya Laporan Saya, daftar tampil, tombol buat laporan ada', (tester) async {
    await _open(tester, _Fake(null));

    expect(find.text('Pantau'), findsNothing);
    expect(find.text('HKP-0001'), findsOneWidget);
    expect(find.text('HKP-0002'), findsOneWidget);
    expect(find.text('Terbuka'), findsWidgets);
    expect(find.text('Buat Laporan'), findsOneWidget);
  });

  testWidgets('petugas: ada tab Pantau dengan ringkasan dan laporan yang terlambat', (tester) async {
    await _open(tester, _Fake('hk'));

    expect(find.text('Pantau'), findsOneWidget);
    await tester.tap(find.text('Pantau'));
    await tester.pumpAndSettle();

    expect(find.text('Terlambat'), findsWidgets);
    expect(find.text('4'), findsOneWidget); // terbuka
    expect(find.text('9'), findsOneWidget); // selesai
    expect(find.text('HKP-0003'), findsOneWidget);
    expect(find.text('BUDI'), findsOneWidget);
  });

  testWidgets('formulir: nomor kamar wajib untuk Receptionist, lalu terkirim dan tiket tampil', (tester) async {
    final fake = _Fake(null);
    await _open(tester, fake);

    await tester.tap(find.text('Buat Laporan'));
    await tester.pumpAndSettle();
    expect(find.text('Jenis laporan'), findsOneWidget);

    await tester.tap(find.text('Receptionist'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GARNERIT A · Mess Garnerit').last);
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), 'AC kamar mati total'); // uraian
    await tester.ensureVisible(find.text('Kirim Laporan'));
    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Nomor kamar wajib diisi untuk laporan Receptionist.'), findsOneWidget);
    expect(fake.posts, isEmpty, reason: 'validasi di perangkat mencegah kirim');

    await tester.enterText(fields.at(0), '12'); // nomor kamar
    await tester.ensureVisible(find.text('Kirim Laporan'));
    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();

    expect(fake.posts.length, 1);
    final body = latin1.decode(fake.posts.single.bodyBytes);
    expect(body, contains('receptionist'));
    expect(body, contains('GARNERIT A'));
    expect(body, contains('AC kamar mati total'));
    expect(body, contains('name="room_number"'));
    expect(find.text('Laporan terkirim'), findsOneWidget);
    expect(find.text('RCP-0001'), findsOneWidget);
  });

  testWidgets('formulir: uraian terlalu pendek ditolak', (tester) async {
    final fake = _Fake(null);
    await _open(tester, fake);

    await tester.tap(find.text('Buat Laporan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Housekeeping'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GARNERIT B · Mess Garnerit').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), 'ab');
    await tester.ensureVisible(find.text('Kirim Laporan'));
    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Uraikan masalahnya (minimal 5 karakter).'), findsOneWidget);
    expect(fake.posts, isEmpty);
  });
}
