import 'package:flutter/material.dart';

class C {
  static const navy = Color(0xFF0E2A47);
  static const navy2 = Color(0xFF17385C);
  static const blue = Color(0xFF1E5BD7);
  static const blueSoft = Color(0xFFE6EEFD);
  static const blueFg = Color(0xFF1748AE);
  static const bg = Color(0xFFF3F5F9);
  static const line = Color(0xFFE3E8EF);
  static const input = Color(0xFFD5DCE6);
  static const text = Color(0xFF13223A);
  static const text2 = Color(0xFF2A3A52);
  static const muted = Color(0xFF5B6B80);
  static const chip = Color(0xFFEEF1F5);
  static const pale = Color(0xFFB9C8DD);
  static const green = Color(0xFF1F7A47);
  static const greenBg = Color(0xFFE2F4E8);
  static const greenFg = Color(0xFF1A6B3A);
  static const orange = Color(0xFFC2610C);
  static const orangeBg = Color(0xFFFFF1E0);
  static const orangeFg = Color(0xFF9A4A06);
  static const red = Color(0xFFB42318);
  static const redBg = Color(0xFFFDE8E8);
  static const purple = Color(0xFF5B32B8);
  static const purpleBg = Color(0xFFEFE9FD);
  static const teal = Color(0xFF14655F);
  static const tealBg = Color(0xFFD8F1F0);
  static const pink = Color(0xFF9C2155);
  static const pinkBg = Color(0xFFFBE3EC);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.blue, primary: C.blue, surface: Colors.white),
    scaffoldBackgroundColor: C.bg,
  );
  TextStyle? z(TextStyle? s) => s?.copyWith(letterSpacing: 0);
  final tt = base.textTheme.apply(fontFamily: 'PlusJakartaSans', bodyColor: C.text, displayColor: C.text);
  return base.copyWith(
    textTheme: tt.copyWith(
      displayLarge: z(tt.displayLarge), displayMedium: z(tt.displayMedium), displaySmall: z(tt.displaySmall),
      headlineLarge: z(tt.headlineLarge), headlineMedium: z(tt.headlineMedium), headlineSmall: z(tt.headlineSmall),
      titleLarge: z(tt.titleLarge), titleMedium: z(tt.titleMedium), titleSmall: z(tt.titleSmall),
      bodyLarge: z(tt.bodyLarge), bodyMedium: z(tt.bodyMedium), bodySmall: z(tt.bodySmall),
      labelLarge: z(tt.labelLarge), labelMedium: z(tt.labelMedium), labelSmall: z(tt.labelSmall),
    ),
    splashFactory: InkRipple.splashFactory,
  );
}

/// Membatasi skala teks sistem agar tata letak tetap rapi (0,9x – 1,15x).
Widget appBuilder(BuildContext context, Widget? child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: MediaQuery.textScalerOf(context).clamp(minScaleFactor: .9, maxScaleFactor: 1.15)),
      child: child ?? const SizedBox.shrink(),
    );
