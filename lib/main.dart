import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

void main() => runApp(const AkpSatuApp());

class AkpSatuApp extends StatelessWidget {
  const AkpSatuApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AKPSatu',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        initialRoute: R.login,
        routes: routes,
      );
}
