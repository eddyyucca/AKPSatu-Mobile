import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'api/api.dart';
import 'api/notifications.dart';
import 'app_keys.dart';
import 'l10n/lang.dart';
import 'notify_ui.dart';
import 'refresh.dart';
import 'routes.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.instance.restore(); // lanjutkan sesi login yang masih berlaku
  await L.instance.restore(); // bahasa pilihan pengguna
  NotificationCenter.instance.onNew = showNotificationBanner; // notifikasi baru saat aplikasi terbuka
  runApp(const AkpSatuApp());
}

class AkpSatuApp extends StatelessWidget {
  const AkpSatuApp({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: L.instance,
        builder: (context, _) => LangScope(
          child: MaterialApp(
            title: 'AKPSatu',
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: messengerKey,
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            locale: L.instance.locale,
            supportedLocales: [for (final l in AppLang.values) Locale(l.code)],
            localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
            builder: appBuilder,
            scrollBehavior: const AppScrollBehavior(),
            initialRoute: R.splash,
            routes: routes,
          ),
        ),
      );
}
