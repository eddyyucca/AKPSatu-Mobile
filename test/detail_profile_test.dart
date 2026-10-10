import 'package:akpsatu/l10n/lang.dart';
import 'package:akpsatu/screens/profile.dart';
import 'package:akpsatu/theme.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _full() => {
      'employee_no': '32601949',
      'name': 'EDDY',
      'job': {
        'division': 'IT DIV', 'department': 'IT', 'section': 'SEKSI A', 'position': 'SUPERVISOR IT', 'grade': '5 - STAFF', 'status': 'ACTIVE',
        'hire_date': '2018-03-01', 'service_length': '8 thn 7 bln', 'point_of_hire': 'MAKASSAR', 'mcu_date': '2026-02-01', 'village_recommendation': 'DESA A',
      },
      'summary': {'age': '36 TAHUN 4 BULAN', 'service_length': '8 TAHUN 7 BULAN', 'total_experience': '2 TAHUN 0 BULAN', 'completeness': 90},
      'contract': {'type': 'PKWT 1', 'start_date': '2026-03-01', 'end_date': '2027-02-28', 'days_remaining': 143},
      'personal': {
        'gender': 'L', 'birth_place': 'MAKASSAR', 'birth_date': '1990-05-12', 'religion': 'ISLAM', 'marital_status': 'MENIKAH', 'email': 'eddy@x.test', 'phone': '0812',
        'mother_name': 'IBU EDDY', 'father_name': 'BAPAK EDDY',
        'address': {'street': 'JL. MERDEKA 1', 'regency': 'KOTA KENDARI'},
      },
      'documents': {'nik_ktp': '7371000000000001', 'npwp': '11.222.333.4-555.000', 'bank': 'BRI', 'bank_account_no': '1234567890', 'bank_account_name': 'EDDY', 'shirt_size': 'L'},
      'educations': [
        {'level': 'S1', 'school': 'UNHAS', 'field_of_study': 'INFORMATIKA', 'year_enrolled': 2008, 'year_graduated': 2012}
      ],
      'experiences': [
        {'company': 'PT LAMA', 'position': 'STAFF IT', 'start_date': '2013-01-01', 'end_date': '2015-01-01', 'duration': '2 TAHUN 0 BULAN'},
        {'company': 'PT BARU', 'position': 'LEAD', 'start_date': '2015-02-01', 'end_date': null, 'duration': '11 TAHUN 8 BULAN'},
      ],
      'contracts': [
        {'type': 'PKWT 1', 'start_date': '2026-03-01', 'end_date': '2027-02-28'}
      ],
      'promotions': [
        {'effective_date': '2026-06-01', 'from_position': 'STAFF IT', 'from_grade': '4 - STAFF', 'to_position': 'SUPERVISOR IT', 'to_grade': '5 - STAFF'}
      ],
    };

Future<void> _open(WidgetTester tester, Map<String, dynamic> data) async {
  tester.view.physicalSize = const Size(900, 5000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(LangScope(child: MaterialApp(theme: buildTheme(), home: DetailProfileScreen(loader: () async => data))));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    L.instance.lang = AppLang.id;
  });

  testWidgets('menampilkan semua bagian data karyawan', (tester) async {
    await _open(tester, _full());
    for (final t in ['DATA PEKERJAAN', 'KONTRAK', 'DATA PRIBADI', 'KONTAK & ALAMAT', 'DOKUMEN & BANK', 'PENDIDIKAN', 'PENGALAMAN KERJA', 'RIWAYAT KONTRAK', 'RIWAYAT PROMOSI']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.text('IBU EDDY'), findsOneWidget);
    expect(find.text('Laki-laki'), findsOneWidget);
    expect(find.text('UNHAS'), findsOneWidget);
    expect(find.text('143 hari'), findsOneWidget);
    expect(find.text('STAFF IT → SUPERVISOR IT'), findsOneWidget);
    expect(find.textContaining('Sekarang'), findsOneWidget); // pengalaman yang masih berjalan
  });

  testWidgets('nomor dokumen & rekening disamarkan sampai ditekan Tampilkan', (tester) async {
    await _open(tester, _full());
    expect(find.text('•••• 0001'), findsOneWidget);
    expect(find.text('•••• 7890'), findsOneWidget);
    expect(find.text('7371000000000001'), findsNothing);

    await tester.tap(find.text('Tampilkan'));
    await tester.pump();
    expect(find.text('7371000000000001'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Sembunyikan'), findsOneWidget);
  });

  testWidgets('server lama (tanpa data baru) tetap tampil tanpa error', (tester) async {
    final old = _full()
      ..remove('summary')
      ..remove('documents')
      ..remove('educations')
      ..remove('experiences')
      ..remove('contracts')
      ..remove('promotions');
    await _open(tester, old);
    expect(tester.takeException(), isNull);
    expect(find.text('DATA PEKERJAAN'), findsOneWidget);
    expect(find.text('DATA PRIBADI'), findsOneWidget);
    expect(find.text('DOKUMEN & BANK'), findsNothing);
    expect(find.text('PENDIDIKAN'), findsNothing);
  });

  testWidgets('berbahasa Korea', (tester) async {
    L.instance.lang = AppLang.ko;
    await _open(tester, _full());
    expect(find.text('업무 정보'), findsOneWidget); // DATA PEKERJAAN
    expect(find.text('학력'), findsOneWidget);
    expect(find.text('남성'), findsOneWidget);
    expect(find.text('어머니 성함'), findsOneWidget);
    expect(find.text('143일'), findsOneWidget);
    expect(find.textContaining('2년 0개월'), findsWidgets);
  });
}
