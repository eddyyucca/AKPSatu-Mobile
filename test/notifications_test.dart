import 'dart:convert';

import 'package:akpsatu/api/api.dart';
import 'package:akpsatu/api/notifications.dart';
import 'package:akpsatu/l10n/lang.dart';
import 'package:akpsatu/routes.dart';
import 'package:akpsatu/screens/notif.dart';
import 'package:akpsatu/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

Map<String, dynamic> _n(int id, {String type = 'overtime.approved', String? title, String? body, bool read = false, DateTime? at}) => {
      'id': id,
      'type': type,
      'title': title ?? (type == 'overtime.rejected' ? 'Lembur ditolak' : 'Lembur disetujui'),
      'body': body ?? 'Pengajuan lembur 5 Okt 2026 pukul 17:00 – 18:30 (1,5 jam) disetujui oleh BUDI SUPER.',
      'data': {'route': 'overtime', 'id': 7},
      'read': read,
      'created_at': (at ?? DateTime.now()).toUtc().toIso8601String(),
    };

/// Server HRIS tiruan untuk notifikasi: isinya bisa diubah antar-putaran pemeriksaan.
class _Server {
  List<Map<String, dynamic>> rows = [];
  int status = 200; // untuk simulasi server lama (404)
  final calls = <http.Request>[];

  int get unread => rows.where((r) => r['read'] != true).length;

  Future<http.Response> handle(http.Request req) async {
    calls.add(req);
    if (status != 200) return _json({'message': 'Not Found'}, status);
    final path = req.url.path;
    final newestFirst = [...rows]..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    if (path.endsWith('/notifications/summary')) return _json({'unread': unread, 'latest_id': newestFirst.isEmpty ? null : newestFirst.first['id']});
    if (path.endsWith('/notifications') && req.method == 'GET') {
      final after = int.tryParse(req.url.queryParameters['after_id'] ?? '');
      final before = int.tryParse(req.url.queryParameters['before_id'] ?? '');
      final limit = int.tryParse(req.url.queryParameters['limit'] ?? '') ?? 30;
      final page = newestFirst.where((r) => (after == null || (r['id'] as int) > after) && (before == null || (r['id'] as int) < before)).take(limit).toList();
      return _json({'data': page, 'unread': unread});
    }
    if (path.endsWith('/notifications/read-all')) {
      for (final r in rows) {
        r['read'] = true;
      }
      return _json({'unread': 0});
    }
    final m = RegExp(r'/notifications/(\d+)/read$').firstMatch(path);
    if (m != null) {
      rows.firstWhere((r) => r['id'] == int.parse(m[1]!))['read'] = true;
      return _json({'unread': unread});
    }
    return _json({'message': 'tidak ada'}, 404);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final center = NotificationCenter.instance;
  late _Server server;
  late http.Client client;
  late List<List<AppNotification>> announced;

  Future<T> run<T>(Future<T> Function() body) => http.runWithClient(body, () => client);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    L.instance.lang = AppLang.id;
    Session.instance.token = 'token';
    Session.instance.expiresAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
    Session.instance.pendingOtp = false;
    Session.instance.user = {'employee_no': '32601949', 'name': 'EDDY'};
    server = _Server();
    client = MockClient(server.handle);
    center.reset();
    announced = [];
    center.onNew = announced.add;
  });

  tearDown(() => center.reset());

  group('pemeriksa berkala', () {
    test('putaran pertama hanya mengisi lencana; yang sudah ada tidak dibanjiri banner', () async {
      server.rows = [_n(1), _n(2)];

      await run(center.poll);

      expect(center.unread, 2);
      expect(announced, isEmpty);
      expect(server.calls.map((c) => c.url.path.split('/').last), ['summary']); // ringan: tidak mengambil isi daftar
    });

    test('notifikasi baru diumumkan sekali dengan isinya, lencana bertambah', () async {
      server.rows = [_n(1, read: true)];
      await run(center.poll);
      expect(center.unread, 0);

      server.rows.add(_n(2, type: 'overtime.rejected'));
      await run(center.poll);

      expect(center.unread, 1);
      expect(announced, hasLength(1));
      expect(announced.single.single.id, 2);
      expect(announced.single.single.title, 'Lembur ditolak');
      expect(announced.single.single.route, 'overtime');
      expect(announced.single.single.refId, 7);

      await run(center.poll); // tidak ada yang baru: tidak diumumkan lagi
      expect(announced, hasLength(1));
      expect(server.calls.where((c) => c.url.queryParameters.containsKey('after_id')), hasLength(1));
    });

    test('hanya yang baru dan belum dibaca yang diumumkan, terbaru dulu', () async {
      server.rows = [_n(1)];
      await run(center.poll);

      server.rows.addAll([_n(2), _n(3, read: true), _n(4)]);
      await run(center.poll);

      expect(announced.single.map((n) => n.id), [4, 2]);
      expect(center.items.map((n) => n.id), [4, 2]);
    });

    test('dibaca di tempat lain (web) menurunkan lencana tanpa banner', () async {
      server.rows = [_n(1), _n(2)];
      await run(center.poll);

      server.rows.first['read'] = true;
      await run(center.poll);

      expect(center.unread, 1);
      expect(announced, isEmpty);
    });

    test('server lama tanpa fitur notifikasi (404): berhenti diam-diam dan tidak memanggil lagi', () async {
      server.status = 404;

      await run(center.poll);
      expect(center.unsupported, isTrue);
      final calls = server.calls.length;

      await run(center.poll);
      expect(server.calls.length, calls);
      expect(center.unread, 0);
    });

    test('jaringan putus tidak mematikan pemeriksaan; dicoba lagi putaran berikutnya', () async {
      server.rows = [_n(1)];
      client = MockClient((_) async => throw Exception('offline'));
      await run(center.poll);
      expect(center.unsupported, isFalse);

      client = MockClient(server.handle);
      await run(center.poll);
      expect(center.unread, 1);
    });

    test('berjalan selama ada layar utama, berhenti setelah yang terakhir ditutup, dan tidak jalan tanpa sesi', () async {
      await run(() async => center.attach());
      expect(center.running, isTrue);

      center.attach(); // layar utama kedua (mis. membuka tab lain lewat rute)
      center.detach();
      expect(center.running, isTrue);

      center.detach();
      expect(center.running, isFalse);

      Session.instance.token = null;
      center.attach();
      expect(center.running, isFalse);
      center.detach();
    });

    test('tanpa sesi tidak memanggil server', () async {
      Session.instance.token = null;

      await run(center.poll);

      expect(server.calls, isEmpty);
    });

    test('pengguna lain pada perangkat yang sama mulai dari kosong', () async {
      server.rows = [_n(1), _n(2)];
      await run(center.poll);
      center.attach();
      expect(center.unread, 2);

      Session.instance.user = {'employee_no': '32601950', 'name': 'SITI'};
      server.rows = [];
      center.attach();
      await run(center.poll);

      expect(center.unread, 0);
      expect(center.items, isEmpty);
      center.detach();
      center.detach();
      expect(center.running, isFalse);
    });
  });

  group('daftar dan tanda baca', () {
    test('load mengambil daftar terbaru dulu dan menetapkan batas "sudah dilihat"', () async {
      server.rows = [_n(1, read: true), _n(2), _n(3)];

      await run(center.load);

      expect(center.items.map((n) => n.id), [3, 2, 1]);
      expect(center.unread, 2);
      expect(center.hasMore, isFalse);

      await run(center.poll); // yang sudah ada di daftar tidak diumumkan sebagai baru
      expect(announced, isEmpty);
    });

    test('halaman berikutnya memakai before_id', () async {
      server.rows = [for (var i = 1; i <= 40; i++) _n(i)];

      await run(center.load);
      expect(center.items, hasLength(30));
      expect(center.hasMore, isTrue);

      await run(center.loadMore);
      expect(center.items.map((n) => n.id).toList(), [for (var i = 40; i >= 1; i--) i]);
      expect(center.hasMore, isFalse);
    });

    test('markRead langsung mengurangi lencana lalu menyelaraskan dengan server; idempoten', () async {
      server.rows = [_n(1), _n(2)];
      await run(center.load);

      await run(() => center.markRead(center.items.first));

      expect(center.unread, 1);
      expect(center.items.first.read, isTrue);
      expect(server.rows.firstWhere((r) => r['id'] == 2)['read'], isTrue);

      final posts = server.calls.where((c) => c.method == 'POST').length;
      await run(() => center.markRead(center.items.first)); // sudah dibaca: tidak memanggil server
      expect(server.calls.where((c) => c.method == 'POST').length, posts);
    });

    test('markAllRead', () async {
      server.rows = [_n(1), _n(2), _n(3)];
      await run(center.load);

      await run(center.markAllRead);

      expect(center.unread, 0);
      expect(center.items.every((n) => n.read), isTrue);
      expect(server.unread, 0);
    });

    test('galat memuat (bukan 404) ditampilkan; server lama diberi pesan khusus', () async {
      server.status = 500;
      await run(center.load);
      expect(center.error, isNotNull);
      expect(center.items, isEmpty);

      server.status = 404;
      await run(center.load);
      expect(center.error, 'Fitur notifikasi belum tersedia di server.');
    });
  });

  group('layar Notifikasi', () {
    Future<void> open(WidgetTester tester, {Size size = const Size(900, 2400)}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await run(() async {
        await tester.pumpWidget(LangScope(
          child: MaterialApp(theme: buildTheme(), home: const NotifScreen(), routes: {R.pengajuanLembur: (_) => const Scaffold(body: Center(child: Text('HALAMAN LEMBUR')))}),
        ));
        await tester.pumpAndSettle();
      });
    }

    final now = DateTime.now();

    testWidgets('menampilkan notifikasi asli dari server, dikelompokkan per hari, dengan penanda belum dibaca', (tester) async {
      server.rows = [_n(1, read: true, at: now.subtract(const Duration(days: 1))), _n(2, type: 'overtime.rejected', body: 'Pengajuan lembur 4 Okt 2026 pukul 17:00 – 19:00 (2 jam) ditolak oleh BUDI SUPER. Alasan: Tidak sesuai absensi'), _n(3)];
      await open(tester);

      expect(find.text('HARI INI'), findsOneWidget);
      expect(find.text('KEMARIN'), findsOneWidget);
      expect(find.text('Lembur disetujui'), findsNWidgets(2));
      expect(find.text('Lembur ditolak'), findsOneWidget);
      expect(find.textContaining('ditolak oleh BUDI SUPER. Alasan: Tidak sesuai absensi'), findsOneWidget);
      expect(find.text('Belum dibaca (2)'), findsOneWidget);
      // Data contoh lama tidak ada lagi.
      expect(find.text('Jemputan cuti terkonfirmasi'), findsNothing);
      expect(find.text('PTW-0047 perlu revisi'), findsNothing);
    });

    testWidgets('mengetuk notifikasi menandai dibaca dan membuka layar tujuan', (tester) async {
      server.rows = [_n(3)];
      await open(tester);
      expect(find.text('Belum dibaca (1)'), findsOneWidget);

      await run(() async {
        await tester.tap(find.text('Lembur disetujui'));
        await tester.pumpAndSettle();
      });

      expect(find.text('HALAMAN LEMBUR'), findsOneWidget);
      expect(server.rows.single['read'], isTrue);
      expect(center.unread, 0);
    });

    testWidgets('tandai semua dibaca dan filter belum dibaca', (tester) async {
      server.rows = [_n(1, read: true), _n(2), _n(3)];
      await open(tester);

      await run(() async {
        await tester.tap(find.text('Belum dibaca (2)'));
        await tester.pumpAndSettle();
      });
      expect(find.text('Lembur disetujui'), findsNWidgets(2)); // yang sudah dibaca tidak tampil

      await run(() async {
        await tester.tap(find.text('Tandai semua dibaca'));
        await tester.pumpAndSettle();
      });
      expect(find.text('Semua notifikasi sudah dibaca.'), findsOneWidget);
      expect(find.text('Belum dibaca (0)'), findsOneWidget);
      expect(find.text('Tandai semua dibaca'), findsNothing);
    });

    testWidgets('kotak masuk kosong', (tester) async {
      await open(tester);

      expect(find.text('Belum ada notifikasi.'), findsOneWidget);
    });

    testWidgets('server lama: pesan jelas, bukan layar kosong yang menyesatkan', (tester) async {
      server.status = 404;
      await open(tester);

      expect(find.text('Fitur notifikasi belum tersedia di server.'), findsOneWidget);
    });

    testWidgets('berbahasa Korea: judul, isi (termasuk tanggal), dan pengelompokan', (tester) async {
      server.rows = [_n(3)];
      await open(tester);
      await L.instance.set(AppLang.ko);
      await tester.pump();

      expect(find.text('초과근무 승인됨'), findsOneWidget);
      expect(find.text('2026년 10월 5일 17:00 – 18:30 초과근무 신청(1,5시간)이 BUDI SUPER님에 의해 승인되었습니다.'), findsOneWidget);
      expect(find.text('오늘'), findsOneWidget);

      await L.instance.set(AppLang.en);
      await tester.pump();
      expect(find.text('Your overtime request on 5 Oct 2026 at 17:00 – 18:30 (1,5 hours) was approved by BUDI SUPER.'), findsOneWidget);
      await L.instance.set(AppLang.id);
    });

    testWidgets('tidak overflow di HP sempit 360 px', (tester) async {
      server.rows = [_n(3), _n(2, type: 'overtime.rejected', body: 'Pengajuan lembur 4 Okt 2026 pukul 17:00 – 19:00 (2 jam) ditolak oleh BUDI SUPER dan rekan. Alasan: Tidak sesuai absensi aktual pada tanggal tersebut karena pulang lebih awal')];
      await open(tester, size: const Size(360, 800));

      expect(tester.takeException(), isNull);
    });
  });
}
