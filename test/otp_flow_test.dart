import 'dart:convert';

import 'package:akpsatu/api/api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

Map<String, dynamic> _login({bool otp = true, String token = 'login-token'}) => {
      'token': token,
      'token_type': 'Bearer',
      'expires_at': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
      'user': {'username': '32601949', 'employee_no': '32601949', 'name': 'EDDY ADHA', 'email': 'eddy@akp.test', 'must_change_password': false},
      if (otp) 'otp_required': true,
      if (otp) 'email_masked': 'e***@akp.test',
    };

void main() {
  late List<http.Request> calls;

  /// Jalankan [body] dengan server Portal tiruan; [routes] memetakan path → balasan.
  Future<T> withServer<T>(Map<String, http.Response Function(http.Request)> routes, Future<T> Function() body) {
    calls = [];
    return http.runWithClient(body, () => MockClient((req) async {
          calls.add(req);
          final h = routes[req.url.path];
          return h == null ? _json({'message': 'tidak ada'}, 404) : h(req);
        }));
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Session.instance.deviceId = '';
    await Session.instance.clear();
  });

  test('identitas perangkat berbentuk UUID, tetap sama, dan tidak hilang saat keluar akun', () async {
    final id = await Session.instance.ensureDeviceId();
    expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(RegExp(r'^[A-Za-z0-9\-]{16,64}$').hasMatch(id), isTrue); // aturan validasi Portal

    await Session.instance.clear();
    Session.instance.deviceId = ''; // seolah aplikasi dibuka ulang
    expect(await Session.instance.ensureDeviceId(), id);
  });

  test('login perangkat baru → token email dikirim & diperiksa di Portal → sesi aktif', () async {
    await withServer({
      '/api/mobile/login': (_) => _json(_login()),
      '/api/mobile/otp/send': (_) => _json({'sent': true, 'email_masked': 'e***@akp.test', 'retry_after': 30, 'expires_in': 600}),
      '/api/mobile/otp/verify': (_) => _json(_login(otp: false, token: 'verified-token')),
    }, () async {
      await Api.instance.login(' 32601949 ', 'Rahasia123');
      expect(Session.instance.pendingOtp, isTrue);
      expect(Session.instance.active, isFalse); // belum boleh masuk ke aplikasi

      final login = jsonDecode(calls.last.body) as Map;
      expect(login['username'], '32601949');
      expect(login['device_id'], Session.instance.deviceId);

      final sent = await Api.instance.sendOtp();
      expect(sent.email, 'e***@akp.test');
      expect(sent.retryAfter, 30);
      expect(calls.last.headers['Authorization'], 'Bearer login-token');

      await Api.instance.verifyOtp('123456');
      expect(jsonDecode(calls.last.body), {'device_id': Session.instance.deviceId, 'code': '123456'});
      expect(Session.instance.pendingOtp, isFalse);
      expect(Session.instance.active, isTrue);
      expect(Session.instance.token, 'verified-token');
    });

    // Tidak ada panggilan ke layanan lain: semuanya ke Portal.
    expect(calls.map((c) => c.url.host).toSet(), {Uri.parse(ApiConfig.portalUrl).host});
  });

  test('perangkat yang sudah dipercaya (atau server lama tanpa otp_required) langsung masuk', () async {
    await withServer({'/api/mobile/login': (_) => _json(_login(otp: false))}, () async {
      await Api.instance.login('32601949', 'Rahasia123');
      expect(Session.instance.pendingOtp, isFalse);
      expect(Session.instance.active, isTrue);
    });
  });

  test('aplikasi ditutup di tengah token email → mulai dari login lagi', () async {
    await withServer({'/api/mobile/login': (_) => _json(_login())}, () async {
      await Api.instance.login('32601949', 'Rahasia123');
    });
    expect(Session.instance.pendingOtp, isTrue);

    final id = Session.instance.deviceId;
    await Session.instance.restore(); // aplikasi dibuka lagi
    expect(Session.instance.token, isNull);
    expect(Session.instance.pendingOtp, isFalse);
    expect(Session.instance.deviceId, id);
  });

  test('sesi terverifikasi tetap dipakai setelah aplikasi dibuka lagi', () async {
    await withServer({'/api/mobile/login': (_) => _json(_login(otp: false))}, () async {
      await Api.instance.login('32601949', 'Rahasia123');
    });
    Session.instance.token = null; // simulasi proses baru
    await Session.instance.restore();
    expect(Session.instance.active, isTrue);
    expect(Session.instance.name, 'EDDY ADHA');
  });

  test('galat Portal: token salah, terlalu cepat kirim ulang, sesi berakhir', () async {
    await withServer({
      '/api/mobile/login': (_) => _json(_login()),
      '/api/mobile/otp/verify': (_) => _json({'code': 'otp_invalid', 'message': 'Token salah. Periksa email Anda.'}, 422),
      '/api/mobile/otp/send': (_) => _json({'code': 'otp_wait', 'message': 'Tunggu 12 detik sebelum meminta token lagi.', 'retry_after': 12}, 429),
    }, () async {
      await Api.instance.login('32601949', 'Rahasia123');

      await expectLater(Api.instance.verifyOtp('000000'), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'otp_invalid').having((e) => e.message, 'message', contains('Token salah'))));
      expect(Session.instance.pendingOtp, isTrue); // salah ketik tidak mengeluarkan sesi

      await expectLater(Api.instance.sendOtp(), throwsA(isA<ApiException>().having((e) => e.retryAfter, 'retryAfter', 12)));
    });

    await withServer({'/api/mobile/otp/send': (_) => _json({'code': 'unauthenticated', 'message': 'Sesi berakhir. Silakan masuk lagi.'}, 401)}, () async {
      await expectLater(Api.instance.sendOtp(), throwsA(isA<ApiException>().having((e) => e.unauthenticated, 'unauthenticated', true)));
      expect(Session.instance.token, isNull); // sesi dibersihkan
    });
  });
}
