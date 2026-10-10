import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:akpsatu/l10n/lang.dart';
import 'package:akpsatu/screens/profile.dart';
import 'package:akpsatu/theme.dart';
import 'package:flutter/material.dart' hide Text;

void main() {
  SharedPreferences.setMockInitialValues({});
  widgetTests();
  final l = L.instance;

  test('Indonesia: teks apa adanya, konteks dibuang', () {
    l.lang = AppLang.id;
    expect(tr('Beranda'), 'Beranda');
    expect(tr('Masuk|login'), 'Masuk');
    expect(tr('Jam kerja · 07:00 – 17:00'), 'Jam kerja · 07:00 – 17:00');
  });

  test('English', () {
    l.lang = AppLang.en;
    expect(tr('Beranda'), 'Home');
    expect(tr('Masuk'), 'Check-in');
    expect(tr('Masuk|login'), 'Sign in');
    expect(tr('Jam kerja · 07:00 – 17:00'), 'Working hours · 07:00 – 17:00');
    expect(tr('Masuk 06:20 · Pulang --:--'), 'Check-in 06:20 · Check-out --:--');
    expect(tr('12 catatan · terbaru di atas'), '12 records · newest first');
    expect(tr('3 hasil untuk "cuti"'), '3 results for "cuti"');
    expect(tr('Slip Gaji segera hadir'), 'Payslip is coming soon');
    expect(tr('Pengajuan cuti'), 'Pengajuan cuti'); // tidak salah cocok pola
    expect(tr('Rabu, 7 Oktober 2026 · Data terakhir'), 'Wednesday, 7 October 2026 · Latest record');
    expect(tr('Teks yang tidak ada di kamus'), 'Teks yang tidak ada di kamus');
  });

  test('한국어', () {
    l.lang = AppLang.ko;
    expect(tr('Beranda'), '홈');
    expect(tr('Masuk|login'), '로그인');
    expect(tr('Masuk 06:20 · Pulang 19:00'), '출근 06:20 · 퇴근 19:00');
    expect(tr('3 hasil untuk "cuti"'), '"cuti" 검색 결과 3건');
    expect(tr('Token dikirim ke e***@gmail.com'), 'e***@gmail.com(으)로 인증 코드를 보냈습니다');
    expect(tr('Kirim ulang (25s)'), '다시 보내기 (25초)');
  });

  test('format tanggal', () {
    final d = DateTime(2026, 10, 8);
    l.lang = AppLang.id;
    expect(l.longDate(d), 'Kamis, 8 Oktober 2026');
    l.lang = AppLang.en;
    expect(l.longDate(d), 'Thursday, 8 October 2026');
    expect(l.monthYear(d), 'October 2026');
    l.lang = AppLang.ko;
    expect(l.longDate(d), '2026년 10월 8일 목요일');
    expect(l.monthYear(d), '2026년 10월');
    expect(l.shortDate(d), '2026년 10월 8일');
  });
}

// Uji widget: halaman nyata ikut berganti bahasa tanpa dibangun ulang manual.
void widgetTests() {
  testWidgets('Profil berganti bahasa langsung (ID → KO → EN)', (tester) async {
    L.instance.lang = AppLang.id;
    await tester.pumpWidget(LangScope(child: MaterialApp(theme: buildTheme(), home: const Scaffold(body: ProfilePage()))));
    expect(find.text('Detail Profil'), findsOneWidget);
    expect(find.text('Bahasa'), findsOneWidget);

    await L.instance.set(AppLang.ko);
    await tester.pump();
    expect(find.text('프로필 상세'), findsOneWidget);
    expect(find.text('언어'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    expect(find.text('Detail Profil'), findsNothing);

    await L.instance.set(AppLang.en);
    await tester.pump();
    expect(find.text('Profile Details'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    await L.instance.set(AppLang.id);
  });
}
