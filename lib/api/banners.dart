import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

/// Satu kampanye/banner dari Portal.
class PromoItem {
  final int id;
  final String title, subtitle, imageUrl, linkUrl, linkLabel;
  const PromoItem({required this.id, required this.title, required this.subtitle, required this.imageUrl, required this.linkUrl, required this.linkLabel});

  factory PromoItem.fromJson(Map<String, dynamic> j) => PromoItem(
        id: (j['id'] as num).toInt(),
        title: (j['title'] as String?) ?? '',
        subtitle: (j['subtitle'] as String?) ?? '',
        imageUrl: (j['image_url'] as String?) ?? '',
        linkUrl: (j['link_url'] as String?) ?? '',
        linkLabel: (j['link_label'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'subtitle': subtitle, 'image_url': imageUrl, 'link_url': linkUrl, 'link_label': linkLabel};
}

/// Banner beranda yang disimpan di perangkat supaya ringan:
///  - daftar banner (teks + alamat gambar) disimpan lokal dan langsung tampil saat aplikasi dibuka;
///  - gambar disimpan oleh cached_network_image (kunci = alamat + ?v= dari Portal), jadi hanya diunduh sekali;
///  - ke server hanya menanyakan `version` (ETag). Jika banner di Portal tidak berubah, server menjawab 304 tanpa isi.
class BannerStore {
  BannerStore._();
  static final BannerStore instance = BannerStore._();

  static const _kCache = 'banners.cache.v1';
  String? _version;

  /// Banner yang tersimpan di perangkat (kosong bila belum pernah diunduh).
  Future<List<PromoItem>> cached() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_kCache);
      if (raw == null) return [];
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      _version = data['version'] as String?;
      return (data['banners'] as List).map((e) => PromoItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Tanyakan ke Portal; kembalikan daftar baru bila ada perubahan, null bila tidak berubah / gagal (pakai yang tersimpan).
  Future<List<PromoItem>?> refresh() async {
    final session = Session.instance;
    if (!session.active) return null;

    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.portalUrl}/api/mobile/banners'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${session.token}',
          if (_version != null) 'If-None-Match': '"$_version"',
        },
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 304 || res.statusCode != 200) return null;

      final data = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
      final list = (data['banners'] as List).map((e) => PromoItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      _version = data['version'] as String?;

      final p = await SharedPreferences.getInstance();
      await p.setString(_kCache, res.body);
      return list;
    } catch (_) {
      return null;     // offline / server mati: banner yang tersimpan tetap dipakai
    }
  }

  /// Hapus simpanan (saat keluar akun).
  Future<void> clear() async {
    _version = null;
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_kCache);
    } catch (_) {}
  }
}
