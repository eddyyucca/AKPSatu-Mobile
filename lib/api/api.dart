import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Alamat server. Bawaan memakai domain hosting (Portal online); ubah lewat --dart-define, mis. untuk server lokal:
///   flutter run --dart-define=PORTAL_URL=http://10.0.2.2:8000 --dart-define=HRIS_URL=http://10.0.2.2:8001
/// (10.0.2.2 = alamat komputer host dari emulator Android).
class ApiConfig {
  static const portalUrl = String.fromEnvironment('PORTAL_URL', defaultValue: 'https://portal.lameruru.web.id');
  static const hrisUrl = String.fromEnvironment('HRIS_URL', defaultValue: 'https://hris.lameruru.web.id');
  static const komplainUrl = String.fromEnvironment('KOMPLAIN_URL', defaultValue: 'https://komplain.lameruru.web.id');
}

class ApiException implements Exception {
  final int status;
  final String code;
  final String message;
  final Map<String, dynamic> errors;
  const ApiException(this.status, this.code, this.message, [this.errors = const {}]);

  /// Sesi berakhir: pengguna harus masuk lagi.
  bool get unauthenticated => status == 401 || code == 'unauthenticated';

  /// Password awal belum diganti: arahkan ke layar ganti password.
  bool get mustChangePassword => code == 'password_change_required';

  /// Detik yang harus ditunggu sebelum meminta token email lagi (bila server mengirimnya).
  int? get retryAfter => (errors['retry_after'] as num?)?.toInt();

  @override
  String toString() => message;
}

/// Sesi login mobile: token Bearer dari Portal + ringkasan pengguna. Disimpan di perangkat (shared_preferences).
class Session {
  Session._();
  static final Session instance = Session._();

  static const _kToken = 'session.token';
  static const _kUser = 'session.user';
  static const _kExp = 'session.exp';
  static const _kDevice = 'device.id';
  static const _kPending = 'session.pending_otp';

  String? token;
  int expiresAt = 0;
  Map<String, dynamic> user = const {};

  /// Identitas perangkat ini (UUID acak, dibuat sekali dan tetap walau keluar akun). Portal memakainya untuk
  /// mengingat perangkat yang sudah lolos token email, jadi token email tidak diminta lagi setiap login.
  String deviceId = '';

  /// Login benar, tapi perangkat belum lolos token email: token login hanya boleh dipakai untuk otp/send dan otp/verify.
  bool pendingOtp = false;

  bool get active => token != null && !pendingOtp && DateTime.now().millisecondsSinceEpoch ~/ 1000 < expiresAt;
  String get name => (user['name'] as String?) ?? '';
  String get nik => (user['employee_no'] as String?) ?? (user['username'] as String?) ?? '';
  bool get mustChangePassword => user['must_change_password'] == true;

  String nameOr(String fallback) => name.isEmpty ? fallback : name;
  String nikOr(String fallback) => nik.isEmpty ? fallback : nik;
  String get headline => [user['position'], user['department']].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

  /// Nama dua huruf untuk avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    return (parts.first[0] + (parts.length > 1 ? parts[1][0] : '')).toUpperCase();
  }

  /// UUID v4 acak untuk identitas perangkat.
  static String _newDeviceId() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  /// Identitas perangkat; dibuat dan disimpan pada pemakaian pertama.
  Future<String> ensureDeviceId() async {
    if (deviceId.isNotEmpty) return deviceId;
    try {
      final p = await SharedPreferences.getInstance();
      var id = p.getString(_kDevice);
      if (id == null || id.length < 16) {
        id = _newDeviceId();
        await p.setString(_kDevice, id);
      }
      deviceId = id;
    } catch (_) {
      deviceId = _newDeviceId();   // penyimpanan gagal: tetap dipakai selama aplikasi berjalan
    }
    return deviceId;
  }

  Future<void> restore() async {
    try {
      await ensureDeviceId();
      final p = await SharedPreferences.getInstance();
      token = p.getString(_kToken);
      expiresAt = p.getInt(_kExp) ?? 0;
      pendingOtp = p.getBool(_kPending) ?? false;
      final raw = p.getString(_kUser);
      user = raw == null ? const {} : Map<String, dynamic>.from(jsonDecode(raw) as Map);
      // Aplikasi ditutup di tengah token email: mulai dari login lagi.
      if (pendingOtp || !active) await clear();
    } catch (_) {
      token = null;
    }
  }

  /// Tambahkan ringkasan jabatan/departemen ke sesi (untuk header beranda & profil).
  Future<void> merge(Map<String, dynamic> extra) async {
    user = {...user, ...extra};
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kUser, jsonEncode(user));
    } catch (_) {}
  }

  Future<void> save(String newToken, int exp, Map<String, dynamic> newUser, {bool pendingOtp = false}) async {
    token = newToken;
    expiresAt = exp;
    user = newUser;
    this.pendingOtp = pendingOtp;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kToken, newToken);
      await p.setInt(_kExp, exp);
      await p.setString(_kUser, jsonEncode(newUser));
      await p.setBool(_kPending, pendingOtp);
    } catch (_) {}
  }

  /// Keluar / sesi berakhir. Identitas perangkat (deviceId) sengaja dipertahankan.
  Future<void> clear() async {
    token = null;
    expiresAt = 0;
    user = const {};
    pendingOtp = false;
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_kToken);
      await p.remove(_kExp);
      await p.remove(_kUser);
      await p.remove(_kPending);
    } catch (_) {}
  }
}

/// Klien API AKPSatu. Login lewat Portal; data HRIS hanya milik karyawan yang login (server memakai NIK pada token).
class Api {
  Api._();
  static final Api instance = Api._();

  final _session = Session.instance;
  static const _timeout = Duration(seconds: 20);

  Map<String, String> _headers({bool auth = true}) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (auth && _session.token != null) 'Authorization': 'Bearer ${_session.token}',
      };

  /// Dipakai klien modul lain (mis. komplain) untuk memanggil Portal dengan penanganan galat dan sesi berakhir yang sama.
  Future<Map<String, dynamic>> send(Future<http.Response> Function() call) => _send(call);

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() call) async {
    final http.Response res;
    try {
      res = await call().timeout(_timeout);
    } catch (_) {
      throw const ApiException(0, 'network', 'Tidak dapat terhubung ke server. Periksa jaringan Anda.');
    }

    Map<String, dynamic> body = {};
    try {
      body = res.body.isEmpty ? {} : Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (_) {}

    if (res.statusCode >= 200 && res.statusCode < 300) return body;

    final errors = body['errors'] is Map ? Map<String, dynamic>.from(body['errors'] as Map) : <String, dynamic>{};
    var message = (body['message'] as String?) ?? 'Terjadi kesalahan (${res.statusCode}).';
    if (errors.isNotEmpty && res.statusCode == 422) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) message = first.first.toString();
    }
    if (body['retry_after'] != null) errors['retry_after'] = body['retry_after'];
    final ex = ApiException(res.statusCode, (body['code'] as String?) ?? 'error', message, errors);
    if (ex.unauthenticated) await _session.clear();
    throw ex;
  }

  Future<void> _storeLogin(Map<String, dynamic> body, {bool pendingOtp = false}) =>
      _session.save(body['token'] as String, (body['expires_at'] as num).toInt(), Map<String, dynamic>.from(body['user'] as Map), pendingOtp: pendingOtp);

  // — Portal —

  /// Masuk dengan NIK + password Portal. Bila perangkat ini belum lolos token email, Portal menjawab `otp_required`:
  /// sesi tersimpan sebagai [Session.pendingOtp] dan layar token email harus dilanjutkan ([sendOtp] lalu [verifyOtp]).
  /// Server lama tanpa fitur ini tidak mengirim `otp_required`, jadi login langsung selesai.
  Future<void> login(String nik, String password) async {
    final deviceId = await _session.ensureDeviceId();
    final body = await _send(() => http.post(Uri.parse('${ApiConfig.portalUrl}/api/mobile/login'),
        headers: _headers(auth: false), body: jsonEncode({'username': nik.trim(), 'password': password, 'device_id': deviceId})));
    await _storeLogin(body, pendingOtp: body['otp_required'] == true);
  }

  /// Minta Portal mengirim token verifikasi (6 digit) ke email akun. Mengembalikan email tersamar dan detik tunggu kirim ulang.
  Future<({String? email, int retryAfter})> sendOtp() async {
    final deviceId = await _session.ensureDeviceId();
    final body = await _send(() => http.post(Uri.parse('${ApiConfig.portalUrl}/api/mobile/otp/send'), headers: _headers(), body: jsonEncode({'device_id': deviceId})));
    return (email: body['email_masked'] as String?, retryAfter: (body['retry_after'] as num?)?.toInt() ?? 30);
  }

  /// Periksa token verifikasi di Portal. Bila benar, perangkat dipercaya dan sesi diganti dengan token terverifikasi.
  Future<void> verifyOtp(String code) async {
    final deviceId = await _session.ensureDeviceId();
    final body = await _send(() => http.post(Uri.parse('${ApiConfig.portalUrl}/api/mobile/otp/verify'), headers: _headers(), body: jsonEncode({'device_id': deviceId, 'code': code})));
    await _storeLogin(body);
  }

  /// Ganti password; server memberi token baru (tanpa kewajiban ganti password).
  Future<void> changePassword(String current, String next, String confirmation) async {
    final body = await _send(() => http.post(Uri.parse('${ApiConfig.portalUrl}/api/mobile/password'),
        headers: _headers(), body: jsonEncode({'current_password': current, 'password': next, 'password_confirmation': confirmation})));
    await _storeLogin(body);
  }

  Future<void> logout() => _session.clear();

  // — HRIS (hanya data karyawan yang login) —

  Future<Map<String, dynamic>> _hris(String path, [Map<String, String>? query]) =>
      _send(() => http.get(Uri.parse('${ApiConfig.hrisUrl}/api/mobile/v1/$path').replace(queryParameters: query), headers: _headers()));

  /// Akses HRIS untuk klien modul lain (mis. notifikasi) dengan penanganan galat dan sesi berakhir yang sama.
  Future<Map<String, dynamic>> hrisGet(String path, [Map<String, String>? query]) => _hris(path, query);

  Future<Map<String, dynamic>> hrisPost(String path) =>
      _send(() => http.post(Uri.parse('${ApiConfig.hrisUrl}/api/mobile/v1/$path'), headers: _headers()));

  Future<Map<String, dynamic>> profile() async => Map<String, dynamic>.from((await _hris('me'))['data'] as Map);

  /// Simpan jabatan & departemen ke sesi. Gagal diam-diam (header tetap tampil tanpa keterangan).
  Future<void> loadSummary() async {
    try {
      final p = await profile();
      final job = Map<String, dynamic>.from(p['job'] as Map);
      await _session.merge({'position': job['position'], 'department': job['department']});
    } catch (_) {}
  }

  /// Roster satu bulan, format 'yyyy-MM'.
  Future<Map<String, dynamic>> roster(String month) => _hris('roster', {'month': month});

  Future<Map<String, dynamic>> attendance(String month) => _hris('attendance', {'month': month});

  Future<List<Map<String, dynamic>>> overtimes() async =>
      ((await _hris('overtimes'))['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  /// Lembur yang bisa diajukan pada satu tanggal ('yyyy-MM-dd') menurut absensi aktual + sisa kuota jam (dihitung server).
  Future<Map<String, dynamic>> overtimeCheck(String date) async => Map<String, dynamic>.from((await _hris('overtimes/check', {'date': date}))['data'] as Map);

  Future<Map<String, dynamic>> submitOvertime({required String date, required String start, required String end, required String reason}) async {
    final body = await _send(() => http.post(Uri.parse('${ApiConfig.hrisUrl}/api/mobile/v1/overtimes'),
        headers: _headers(), body: jsonEncode({'work_date': date, 'start_time': start, 'end_time': end, 'reason': reason})));
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  Future<void> cancelOvertime(int id) async {
    await _send(() => http.post(Uri.parse('${ApiConfig.hrisUrl}/api/mobile/v1/overtimes/$id/cancel'), headers: _headers()));
  }
}
