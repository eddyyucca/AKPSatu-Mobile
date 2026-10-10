import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api.dart';

/// Foto yang akan diunggah: nama berkas + isinya. Memakai byte (bukan path) supaya jalan juga di web/Chrome.
class UploadFile {
  final String name;
  final List<int> bytes;
  const UploadFile(this.name, this.bytes);
}

/// Satu halaman hasil dari server (daftar + penomoran halaman + ringkasan pemantauan bila ada).
class KomplainPage {
  final List<Map<String, dynamic>> items;
  final int page, lastPage, total;
  final Map<String, dynamic> summary;
  const KomplainPage(this.items, this.page, this.lastPage, this.total, [this.summary = const {}]);

  bool get hasMore => page < lastPage;
}

/// Layanan Laporan Komplain GA.
///
/// Login tetap lewat Portal. Untuk modul ini aplikasi menukar token login dengan token khusus modul
/// (POST {portal}/api/mobile/app-token, app=komplain-ga), lalu memanggil server komplain dengan token itu.
/// Identitas pelapor selalu dari token (server tidak mempercayai nama/NIK dari isian).
class KomplainApi {
  KomplainApi({http.Client? client, String? baseUrl, String? portalUrl})
      : _client = client ?? http.Client(),
        _base = baseUrl ?? ApiConfig.komplainUrl,
        _portal = portalUrl ?? ApiConfig.portalUrl;

  /// Dapat diganti pada tes (klien HTTP palsu).
  static KomplainApi instance = KomplainApi();

  static const app = 'komplain-ga';
  static const _timeout = Duration(seconds: 20);
  static const _uploadTimeout = Duration(seconds: 90);

  final http.Client _client;
  final String _base, _portal;

  String? _token;
  int _exp = 0;
  String? _forSession;

  /// Peran Portal pengguna di modul ini (null = karyawan biasa; petugas bila superadmin/receptionist/hk/laundry).
  String? role;

  bool get isStaff => role != null && const ['superadmin', 'receptionist', 'hk', 'laundry'].contains(role);

  void reset() {
    _token = null;
    _exp = 0;
    _forSession = null;
    role = null;
  }

  bool get _fresh =>
      _token != null && _forSession == Session.instance.token && DateTime.now().millisecondsSinceEpoch ~/ 1000 < _exp - 60;

  /// Tukar token login dengan token modul. Galat 401 dari Portal berarti sesi login berakhir (Api.send membersihkan sesi).
  Future<String> _moduleToken({bool force = false}) async {
    if (!force && _fresh) return _token!;

    final session = Session.instance.token;
    if (session == null) throw const ApiException(401, 'unauthenticated', 'Sesi berakhir. Silakan masuk lagi.');

    final Map<String, dynamic> body;
    try {
      body = await Api.instance.send(() => _client.post(
            Uri.parse('$_portal/api/mobile/app-token'),
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $session'},
            body: jsonEncode({'app': app}),
          ));
    } on ApiException catch (e) {
      // Sebut server yang gagal dijangkau supaya mudah dilacak (alamat salah, server mati, atau perangkat di luar jaringan).
      if (e.code == 'network') throw ApiException(0, 'network', 'Tidak dapat terhubung ke Portal ($_portal). Periksa jaringan atau alamat server.');
      rethrow;
    }

    _token = body['token'] as String;
    _exp = (body['expires_at'] as num).toInt();
    _forSession = session;
    role = body['role'] as String?;
    return _token!;
  }

  Map<String, dynamic> _parse(http.Response res) {
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
    throw ApiException(res.statusCode, (body['code'] as String?) ?? 'error', message, errors);
  }

  /// Panggil server komplain. Bila token modul ditolak (401), minta token baru sekali lalu ulangi.
  /// 401 dari modul TIDAK mengeluarkan pengguna dari aplikasi (itu hanya berlaku untuk sesi Portal).
  Future<Map<String, dynamic>> _call(Future<http.Response> Function(Map<String, String> headers) request, {Duration timeout = _timeout}) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final token = await _moduleToken(force: attempt > 0);
      final http.Response res;
      try {
        res = await request({'Accept': 'application/json', 'Authorization': 'Bearer $token'}).timeout(timeout);
      } catch (_) {
        throw ApiException(0, 'network', 'Tidak dapat terhubung ke server komplain ($_base). Periksa jaringan atau alamat server.');
      }
      if (res.statusCode == 401 && attempt == 0) continue;
      if (res.statusCode == 401) {
        throw const ApiException(0, 'komplain_unauthorized', 'Layanan komplain menolak sesi Anda. Coba masuk ulang atau hubungi administrator.');
      }
      return _parse(res);
    }
    throw const ApiException(0, 'error', 'Terjadi kesalahan.');
  }

  Uri _uri(String path, [Map<String, String>? query]) => Uri.parse('$_base/api/mobile/v1/$path').replace(queryParameters: query);

  List<Map<String, dynamic>> _list(Object? v) => ((v as List?) ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  KomplainPage _page(Map<String, dynamic> body) {
    final meta = Map<String, dynamic>.from((body['meta'] as Map?) ?? const {});
    return KomplainPage(
      _list(body['data']),
      (meta['page'] as num?)?.toInt() ?? 1,
      (meta['last_page'] as num?)?.toInt() ?? 1,
      (meta['total'] as num?)?.toInt() ?? 0,
      Map<String, dynamic>.from((body['summary'] as Map?) ?? const {}),
    );
  }

  /// Jenis laporan, daftar bangunan, dan hak pengguna. Sekaligus memperbarui [role].
  Future<Map<String, dynamic>> options() async {
    final body = await _call((h) => _client.get(_uri('options'), headers: h));
    final data = Map<String, dynamic>.from(body['data'] as Map);
    final user = Map<String, dynamic>.from((data['user'] as Map?) ?? const {});
    role = user['role'] as String?;
    return data;
  }

  Future<KomplainPage> mine({String? status, int page = 1}) async => _page(await _call((h) => _client.get(
        _uri('complaints', {'page': '$page', 'status': ?status}),
        headers: h,
      )));

  Future<Map<String, dynamic>> detail(String ticket) async =>
      Map<String, dynamic>.from((await _call((h) => _client.get(_uri('complaints/${Uri.encodeComponent(ticket)}'), headers: h)))['data'] as Map);

  Future<KomplainPage> monitor({String? status, String? type, String q = '', bool overdue = false, int page = 1}) async => _page(await _call((h) => _client.get(
        _uri('monitor', {
          'page': '$page',
          'status': ?status,
          'type': ?type,
          if (q.trim().isNotEmpty) 'q': q.trim(),
          if (overdue) 'overdue': '1',
        }),
        headers: h,
      )));

  /// Kirim laporan baru; [photos] maksimal 6 foto (jpg/png/webp, masing-masing maksimal 5 MB).
  Future<Map<String, dynamic>> create({
    required String type,
    required String building,
    required String description,
    String room = '',
    String location = '',
    String wa = '',
    List<UploadFile> photos = const [],
  }) async {
    final body = await _call((h) async {
      final req = http.MultipartRequest('POST', _uri('complaints'))
        ..headers.addAll(h)
        ..fields['type'] = type
        ..fields['building'] = building
        ..fields['description'] = description;
      if (room.trim().isNotEmpty) req.fields['room_number'] = room.trim();
      if (location.trim().isNotEmpty) req.fields['location'] = location.trim();
      if (wa.trim().isNotEmpty) req.fields['reporter_wa'] = wa.trim();
      for (final f in photos) {
        req.files.add(http.MultipartFile.fromBytes('photos[]', f.bytes, filename: f.name));
      }
      return http.Response.fromStream(await _client.send(req));
    }, timeout: _uploadTimeout);

    return Map<String, dynamic>.from(body['data'] as Map);
  }
}
