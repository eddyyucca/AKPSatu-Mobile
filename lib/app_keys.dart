import 'package:flutter/material.dart';

/// Kunci global agar bagian non-layar (mis. pemeriksa notifikasi) bisa menampilkan banner dan membuka layar.
final navigatorKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();
