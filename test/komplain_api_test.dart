import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akpsatu/api/api.dart';
import 'package:akpsatu/api/komplain.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

int get _later => DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Session.instance.save('login-token', _later, {'name': 'EDDY', 'employee_no': '32601949'});
  });

  KomplainApi api(MockClient c) => KomplainApi(client: c, baseUrl: 'http://komplain.test', portalUrl: 'http://portal.test');

  test('menukar token login dengan token modul lalu memakainya, dan menyimpannya untuk panggilan berikutnya', () async {
    final calls = <String>[];
    final auth = <String, String?>{};
    final client = MockClient((req) async {
      calls.add('${req.method} ${req.url.path}');
      auth[req.url.path] = req.headers['Authorization'];
      if (req.url.path == '/api/mobile/app-token') {
        expect(jsonDecode(req.body), {'app': 'komplain-ga'});
        return _json({'token': 'modul-token', 'expires_at': _later, 'role': 'hk'});
      }
      return _json({'data': {'types': [], 'buildings': [], 'user': {'role': 'hk', 'can_monitor': true}}});
    });
    final k = api(client);

    await k.options();
    await k.options();

    expect(calls.where((c) => c.contains('app-token')).length, 1, reason: 'token modul dipakai ulang');
    expect(auth['/api/mobile/app-token'], 'Bearer login-token');
    expect(auth['/api/mobile/v1/options'], 'Bearer modul-token');
    expect(k.role, 'hk');
    expect(k.isStaff, isTrue);
  });

  test('karyawan biasa bukan petugas', () async {
    final k = api(MockClient((req) async => req.url.path.contains('app-token')
        ? _json({'token': 't', 'expires_at': _later, 'role': null})
        : _json({'data': {'user': {'role': null, 'can_monitor': false}}})));

    await k.options();

    expect(k.role, isNull);
    expect(k.isStaff, isFalse);
  });

  test('token modul ditolak (401): minta token baru sekali lalu berhasil', () async {
    var exchanges = 0;
    var apiCalls = 0;
    final k = api(MockClient((req) async {
      if (req.url.path.contains('app-token')) {
        exchanges++;
        return _json({'token': 'modul-$exchanges', 'expires_at': _later, 'role': null});
      }
      apiCalls++;
      return apiCalls == 1 ? _json({'message': 'x'}, 401) : _json({'data': [], 'meta': {'page': 1, 'last_page': 1, 'total': 0}});
    }));

    final page = await k.mine();

    expect(exchanges, 2);
    expect(page.items, isEmpty);
    expect(Session.instance.token, 'login-token', reason: 'sesi Portal tidak boleh hilang karena modul menolak token');
  });

  test('modul menolak terus (401 dua kali): galat jelas, pengguna TIDAK dikeluarkan dari aplikasi', () async {
    final k = api(MockClient((req) async => req.url.path.contains('app-token') ? _json({'token': 't', 'expires_at': _later, 'role': null}) : _json({}, 401)));

    await expectLater(k.mine(), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'komplain_unauthorized').having((e) => e.unauthenticated, 'unauthenticated', isFalse)));

    expect(Session.instance.active, isTrue);
  });

  test('sesi Portal berakhir (401 dari Portal): sesi dibersihkan dan pengguna diminta masuk lagi', () async {
    final k = api(MockClient((req) async => _json({'code': 'unauthenticated', 'message': 'Sesi berakhir.'}, 401)));

    await expectLater(k.options(), throwsA(isA<ApiException>().having((e) => e.unauthenticated, 'unauthenticated', isTrue)));

    expect(Session.instance.token, isNull);
  });

  test('wajib ganti password terbaca dari Portal', () async {
    final k = api(MockClient((req) async => _json({'code': 'password_change_required', 'message': 'Ganti password.'}, 403)));

    await expectLater(k.options(), throwsA(isA<ApiException>().having((e) => e.mustChangePassword, 'mustChangePassword', isTrue)));
  });

  test('tanpa sesi login: galat sesi berakhir tanpa memanggil jaringan', () async {
    await Session.instance.clear();
    var called = false;
    final k = api(MockClient((req) async {
      called = true;
      return _json({});
    }));

    await expectLater(k.options(), throwsA(isA<ApiException>().having((e) => e.unauthenticated, 'unauthenticated', isTrue)));
    expect(called, isFalse);
  });

  test('galat validasi 422 menampilkan pesan pertama', () async {
    final k = api(MockClient((req) async => req.url.path.contains('app-token')
        ? _json({'token': 't', 'expires_at': _later, 'role': null})
        : _json({'message': 'The given data was invalid.', 'errors': {'room_number': ['Nomor kamar wajib diisi.']}}, 422)));

    await expectLater(k.create(type: 'receptionist', building: 'GARNERIT A', description: 'AC mati'), throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Nomor kamar wajib diisi.')));
  });

  test('membuat laporan: kirim multipart dengan isian dan foto, hasilnya dikembalikan', () async {
    late http.Request sent;
    final k = api(MockClient((req) async {
      if (req.url.path.contains('app-token')) return _json({'token': 'modul', 'expires_at': _later, 'role': null});
      sent = req;
      return _json({'data': {'ticket': 'HKP-0007', 'status': 'open'}}, 201);
    }));

    final data = await k.create(
      type: 'hk',
      building: 'GARNERIT A',
      description: 'Kamar mandi bocor',
      room: ' 12 ',
      photos: [UploadFile('a.jpg', [1, 2, 3]), UploadFile('b.png', [4, 5])],
    );

    expect(data['ticket'], 'HKP-0007');
    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/mobile/v1/complaints');
    expect(sent.headers['Authorization'], 'Bearer modul');
    expect(sent.headers['content-type'], startsWith('multipart/form-data'));
    final body = latin1.decode(sent.bodyBytes);
    expect(body, contains('name="type"'));
    expect(body, contains('GARNERIT A'));
    expect(body, contains('name="room_number"'));
    expect(body, isNot(contains('name="location"')), reason: 'isian kosong tidak dikirim');
    expect('name="photos[]"'.allMatches(body).length, 2);
    expect(body, contains('filename="a.jpg"'));
    expect(body, contains('filename="b.png"'));
  });

  test('daftar laporan saya: penomoran halaman dan filter status', () async {
    Uri? seen;
    final k = api(MockClient((req) async {
      if (req.url.path.contains('app-token')) return _json({'token': 't', 'expires_at': _later, 'role': null});
      seen = req.url;
      return _json({
        'data': [
          {'ticket': 'HKP-0001', 'status': 'open'},
          {'ticket': 'HKP-0002', 'status': 'closed'},
        ],
        'meta': {'page': 1, 'last_page': 3, 'total': 45},
      });
    }));

    final page = await k.mine(status: 'open');

    expect(seen!.queryParameters, {'page': '1', 'status': 'open'});
    expect(page.items.length, 2);
    expect(page.hasMore, isTrue);
    expect(page.total, 45);
  });

  test('pemantauan: ringkasan dan filter dikirim ke server', () async {
    Uri? seen;
    final k = api(MockClient((req) async {
      if (req.url.path.contains('app-token')) return _json({'token': 't', 'expires_at': _later, 'role': 'superadmin'});
      seen = req.url;
      return _json({
        'data': [],
        'meta': {'page': 1, 'last_page': 1, 'total': 0},
        'summary': {'open': 4, 'progress': 2, 'closed': 9, 'rejected': 1, 'overdue': 3, 'total': 16},
      });
    }));

    final page = await k.monitor(status: 'open', type: 'hk', q: ' bocor ', overdue: true);

    expect(seen!.path, '/api/mobile/v1/monitor');
    expect(seen!.queryParameters, {'page': '1', 'status': 'open', 'type': 'hk', 'q': 'bocor', 'overdue': '1'});
    expect(page.summary['overdue'], 3);
    expect(page.hasMore, isFalse);
  });

  test('jaringan ke Portal putus: galat menyebut alamat Portal', () async {
    final k = api(MockClient((req) async => throw http.ClientException('putus')));

    await expectLater(k.options(), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'network').having((e) => e.message, 'message', contains('portal.test'))));
  });

  test('jaringan ke server komplain putus: galat menyebut alamat server komplain', () async {
    final k = api(MockClient((req) async {
      if (req.url.path.contains('app-token')) return _json({'token': 't', 'expires_at': _later, 'role': null});
      throw http.ClientException('putus');
    }));

    await expectLater(k.options(), throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('komplain.test'))));
  });
}
