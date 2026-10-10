import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

/// Tarik ke bawah untuk memuat ulang. Setiap bagian layar yang punya data dari server mendaftarkan fungsi muat-ulangnya
/// (mis. banner, absensi hari ini); satu tarikan di Beranda menjalankan semuanya dan menunggu sampai selesai.
class Refresh {
  Refresh._();

  static final _callbacks = <Future<void> Function()>{};

  /// Dinaikkan setelah muat ulang selesai supaya bagian layar yang membaca Session ikut digambar ulang.
  static final rev = ValueNotifier<int>(0);

  static void add(Future<void> Function() fn) => _callbacks.add(fn);
  static void remove(Future<void> Function() fn) => _callbacks.remove(fn);

  static Future<void> run() async {
    await Future.wait(_callbacks.toList().map((fn) async {
      try {
        await fn();
      } catch (_) {}
    }));
    rev.value++;
  }
}

/// Membungkus daftar yang bisa digulir dengan tarik-untuk-memuat-ulang. Tetap bisa ditarik walau isinya pendek.
class PullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  const PullToRefresh({super.key, required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        color: C.blue,
        backgroundColor: Colors.white,
        displacement: 56,
        child: child,
      );
}

/// Mouse dan trackpad ikut bisa menggeser/menarik (di Chrome bawaannya hanya sentuhan), supaya tarik-segarkan dan geser banner bisa dicoba di laptop.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus};
}
