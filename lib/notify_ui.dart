import 'package:flutter/material.dart' hide Text;
import 'api/notifications.dart';
import 'app_keys.dart';
import 'routes.dart';
import 'theme.dart';
import 'widgets.dart';

/// Banner di dalam aplikasi saat notifikasi baru ditemukan (aplikasi sedang terbuka). Diketuk "Lihat" membuka layar Notifikasi.
void showNotificationBanner(List<AppNotification> fresh) {
  final messenger = messengerKey.currentState;
  if (messenger == null || fresh.isEmpty) return;
  final first = fresh.first;
  final more = fresh.length - 1;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.navy,
      duration: const Duration(seconds: 7),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(first.title, style: ts(14, w: FontWeight.w800, c: Colors.white)),
        const SizedBox(height: 2),
        Text(first.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(12, c: C.pale, h: 1.4)),
        if (more > 0) ...[const SizedBox(height: 2), Text('+$more notifikasi lainnya', style: ts(12, w: FontWeight.w700, c: Colors.white))],
      ]),
      action: SnackBarAction(label: 'Lihat', textColor: Colors.white, onPressed: () => navigatorKey.currentState?.pushNamed(R.notifikasi)),
    ));
}
