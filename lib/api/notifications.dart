import 'dart:async';
import 'package:flutter/widgets.dart';
import 'api.dart';

/// Satu notifikasi dari server (kotak masuk karyawan di HRIS).
class AppNotification {
  final int id;
  final String type, title, body;
  final String? route; // tujuan layar saat diketuk, mis. 'overtime'
  final int? refId;
  final DateTime createdAt;
  final bool read;
  const AppNotification({required this.id, required this.type, required this.title, required this.body, required this.route, required this.refId, required this.createdAt, required this.read});

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    final data = j['data'] is Map ? Map<String, dynamic>.from(j['data'] as Map) : <String, dynamic>{};
    return AppNotification(
      id: (j['id'] as num).toInt(),
      type: (j['type'] as String?) ?? '',
      title: (j['title'] as String?) ?? '',
      body: (j['body'] as String?) ?? '',
      route: data['route'] as String?,
      refId: (data['id'] as num?)?.toInt(),
      createdAt: DateTime.tryParse((j['created_at'] as String?) ?? '')?.toLocal() ?? DateTime.now(),
      read: j['read'] == true,
    );
  }

  AppNotification asRead() => AppNotification(id: id, type: type, title: title, body: body, route: route, refId: refId, createdAt: createdAt, read: true);
}

/// Notifikasi dari HRIS (`/api/mobile/v1/notifications`).
extension NotificationApi on Api {
  /// Ringan untuk diperiksa berkala: jumlah belum dibaca dan id terbaru (0 bila kotak masuk kosong).
  Future<({int unread, int latestId})> notificationSummary() async {
    final b = await hrisGet('notifications/summary');
    return (unread: (b['unread'] as num?)?.toInt() ?? 0, latestId: (b['latest_id'] as num?)?.toInt() ?? 0);
  }

  /// Terbaru dulu. [afterId] = hanya yang lebih baru dari id itu; [beforeId] = halaman berikutnya (lebih lama).
  Future<({List<AppNotification> items, int unread})> notifications({int? afterId, int? beforeId, int limit = 30}) async {
    final b = await hrisGet('notifications', {'limit': '$limit', if (afterId != null) 'after_id': '$afterId', if (beforeId != null) 'before_id': '$beforeId'});
    final list = (b['data'] as List? ?? const []).map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    return (items: list, unread: (b['unread'] as num?)?.toInt() ?? 0);
  }

  /// Mengembalikan sisa belum dibaca.
  Future<int> markNotificationRead(int id) async => ((await hrisPost('notifications/$id/read'))['unread'] as num?)?.toInt() ?? 0;

  Future<void> markAllNotificationsRead() async => hrisPost('notifications/read-all');
}

/// Pusat notifikasi aplikasi: jumlah belum dibaca (lencana di Beranda), daftar untuk layar Notifikasi, dan pemeriksa berkala.
///
/// Saat aplikasi terbuka, [poll] bertanya ringan ke server tiap [interval] (jumlah belum dibaca + id terbaru) dan mengambil
/// isinya hanya bila ada yang baru, lalu memanggil [onNew] (banner di dalam aplikasi). Pemeriksaan berhenti saat aplikasi
/// di latar belakang dan langsung berjalan lagi saat dibuka. Push saat aplikasi tertutup menyusul (FCM).
class NotificationCenter extends ChangeNotifier with WidgetsBindingObserver {
  NotificationCenter._();
  static final NotificationCenter instance = NotificationCenter._();

  /// Jarak antar pemeriksaan saat aplikasi terbuka.
  static const interval = Duration(seconds: 30);
  static const pageSize = 30;

  int unread = 0;
  List<AppNotification> items = const [];
  bool loading = false, hasMore = false, unsupported = false;
  String? error;

  /// Dipanggil dengan notifikasi baru yang belum dibaca (terbaru dulu) saat ditemukan oleh pemeriksa berkala.
  void Function(List<AppNotification> fresh)? onNew;

  int _lastSeenId = 0;
  bool _announce = false; // false sampai pemeriksaan pertama selesai: isi yang sudah ada tidak dibanjiri banner
  String? _owner;
  Timer? _timer;
  bool _observing = false;
  bool _polling = false;

  int _attached = 0; // jumlah layar utama yang sedang tampil

  bool get running => _timer != null;

  /// Dipanggil layar utama saat tampil: pemeriksaan berkala berjalan selama ada layar utama. Pengguna berbeda dari sebelumnya = mulai dari kosong.
  void attach() {
    _attached++;
    final nik = Session.instance.nik;
    if (_owner != null && _owner != nik) reset();
    _owner = nik;
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    _resume();
  }

  /// Dipanggil layar utama saat ditutup; pemeriksaan berhenti bila tidak ada lagi.
  void detach() {
    if (_attached > 0) _attached--;
    if (_attached == 0) stop();
  }

  void _resume() {
    if (_attached == 0 || !Session.instance.active) return; // belum/tidak masuk: tidak ada yang diperiksa
    _timer ??= Timer.periodic(interval, (_) => poll());
    poll();
  }

  /// Berhenti memeriksa sementara (aplikasi ke latar belakang, sesi berakhir, atau tidak ada layar utama).
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Lupakan semuanya (keluar akun / pengguna lain).
  void reset() {
    stop();
    unread = 0;
    items = const [];
    hasMore = false;
    error = null;
    unsupported = false;
    _lastSeenId = 0;
    _announce = false;
    _owner = null;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resume();
    } else if (state == AppLifecycleState.paused) {
      stop();
    }
  }

  /// Satu putaran pemeriksaan. Aman dipanggil kapan saja; kegagalan jaringan diabaikan (dicoba lagi pada putaran berikutnya).
  Future<void> poll() async {
    if (_polling || unsupported) return;
    if (!Session.instance.active) {
      stop();
      return;
    }
    _polling = true;
    try {
      final s = await Api.instance.notificationSummary();
      final changed = s.unread != unread;
      unread = s.unread;

      if (s.latestId > _lastSeenId) {
        if (_announce && _lastSeenId > 0) {
          final page = await Api.instance.notifications(afterId: _lastSeenId);
          final fresh = page.items.where((n) => !n.read).toList();
          if (fresh.isNotEmpty) {
            items = [...fresh, ...items.where((o) => !fresh.any((f) => f.id == o.id))];
            onNew?.call(fresh);
          }
        }
        _lastSeenId = s.latestId;
        notifyListeners();
      } else if (changed) {
        notifyListeners();
      }
      _announce = true;
    } on ApiException catch (e) {
      if (e.status == 404) {
        unsupported = true; // server HRIS belum punya fitur notifikasi
        stop();
        notifyListeners();
      }
    } catch (_) {
      // jaringan putus: abaikan
    } finally {
      _polling = false;
    }
  }

  /// Muat halaman pertama untuk layar Notifikasi (tarik-segarkan).
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final page = await Api.instance.notifications(limit: pageSize);
      items = page.items;
      unread = page.unread;
      hasMore = page.items.length >= pageSize;
      final top = page.items.isEmpty ? 0 : page.items.first.id;
      if (top > _lastSeenId) _lastSeenId = top;
      _announce = true;
    } on ApiException catch (e) {
      error = e.status == 404 ? 'Fitur notifikasi belum tersedia di server.' : e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Halaman berikutnya (lebih lama).
  Future<void> loadMore() async {
    if (loading || !hasMore || items.isEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final page = await Api.instance.notifications(beforeId: items.last.id, limit: pageSize);
      items = [...items, ...page.items];
      hasMore = page.items.length >= pageSize;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Tandai satu notifikasi dibaca (langsung di layar, lalu ke server).
  Future<void> markRead(AppNotification n) async {
    if (n.read) return;
    items = [for (final o in items) o.id == n.id ? o.asRead() : o];
    unread = unread > 0 ? unread - 1 : 0;
    notifyListeners();
    try {
      unread = await Api.instance.markNotificationRead(n.id);
    } on ApiException {
      // tetap dianggap dibaca di layar; sinkron lagi pada pemeriksaan berikutnya
    }
    notifyListeners();
  }

  Future<void> markAllRead() async {
    items = [for (final o in items) o.asRead()];
    unread = 0;
    notifyListeners();
    try {
      await Api.instance.markAllNotificationsRead();
    } on ApiException {
      // disinkronkan lagi pada pemeriksaan berikutnya
    }
  }
}
