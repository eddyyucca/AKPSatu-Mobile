import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../api/banners.dart';
import '../api/notifications.dart';
import '../l10n/lang.dart';
import '../pattern.dart';
import '../refresh.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';
import 'requests.dart';

const _trashPath = 'M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _sec(String t) => Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 0), child: Text(t, style: ts(13, w: FontWeight.w700, c: C.muted).copyWith(letterSpacing: .3)));

  Widget _menu(List<Widget> rows) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: Column(children: rows),
      );

  Widget _row(String label, Widget icon, Color bg, VoidCallback onTap, {bool first = false, String? sub}) => InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Center(child: icon)),
            const Gap(0, w: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: ts(15, w: FontWeight.w600)),
                if (sub != null) Text(sub, style: ts(12, c: C.muted)),
              ]),
            ),
            const Ic('chevron', size: 18, stroke: 2, color: C.muted),
          ]),
        ),
      );

  /// Pilih bahasa aplikasi (Indonesia / English / 한국어). Berlaku langsung dan tersimpan di perangkat.
  Future<void> _pickLanguage(BuildContext context) => sheet<void>(
        context,
        (ctx) => ListenableBuilder(
          listenable: L.instance,
          builder: (ctx, _) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pilih Bahasa', style: ts(18, w: FontWeight.w800)),
            const Gap(4),
            Text('Pilih bahasa yang dipakai di aplikasi.', style: ts(13, c: C.muted)),
            const Gap(12),
            for (final l in AppLang.values)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await L.instance.set(l);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(children: [
                    Container(
                      width: 40,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: l == L.instance.lang ? C.blue : C.chip, borderRadius: BorderRadius.circular(8)),
                      child: Text(l.badge, style: ts(12, w: FontWeight.w800, c: l == L.instance.lang ? Colors.white : C.muted)),
                    ),
                    const Gap(0, w: 14),
                    Expanded(child: Text(l.label, style: ts(16, w: l == L.instance.lang ? FontWeight.w700 : FontWeight.w500))),
                    if (l == L.instance.lang) const Ic('check', color: C.blue, stroke: 2.2),
                  ]),
                ),
              ),
          ]),
        ),
      );

  Future<void> _confirm(BuildContext context, {required String title, required String text, required String ok, required VoidCallback onOk, Color color = C.red}) => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: ts(18, w: FontWeight.w800)),
          content: Text(text, style: ts(14, c: C.text2, h: 1.5)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: ts(14, w: FontWeight.w700, c: C.muted))),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                onOk();
              },
              child: Text(ok, style: ts(14, w: FontWeight.w700, c: color)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(children: [
          BrandHeader(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
            child: Column(children: [
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFDCE7FB), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                child: Text(Session.instance.name.isEmpty ? 'EA' : Session.instance.initials, style: ts(30, w: FontWeight.w800, c: C.blueFg)),
              ),
              const Gap(10),
              Text(Session.instance.nameOr('Eddy Adha Saputra'), textAlign: TextAlign.center, style: ts(22, w: FontWeight.w800, c: Colors.white, h: 1.4)),
              Text(Session.instance.name.isEmpty ? 'Supervisor IT · IT Department' : Session.instance.headline, textAlign: TextAlign.center, style: ts(14, c: C.pale, h: 1.4)),
              const Gap(10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(99)),
                child: Text('NIK ${Session.instance.nikOr('32601949')}', style: ts(12, w: FontWeight.w700, c: const Color(0xFFDCE7FB)).copyWith(letterSpacing: 1)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sec('PENGATURAN PROFIL'),
              const Gap(10),
              _menu([
                _row('Detail Profil', const Ic('user', color: C.blue), C.blueSoft, () => Navigator.pushNamed(context, R.detailProfil), first: true, sub: 'Data pekerjaan & data pribadi'),
                _row('Ubah Password', const Ic('lock', color: C.purple), C.purpleBg, () => Navigator.pushNamed(context, R.ubahPassword)),
              ]),
              const Gap(10),
              _sec('PREFERENSI'),
              const Gap(10),
              _menu([
                ListenableBuilder(
                  listenable: L.instance,
                  builder: (context, _) => _row('Bahasa', const Ic('globe', color: C.blue), C.blueSoft, () => _pickLanguage(context), first: true, sub: L.instance.lang.label),
                ),
                _row('Kebijakan Privasi', const Ic('shield', color: C.teal), C.tealBg, () => Navigator.pushNamed(context, R.privasi)),
                _row(
                  'Hapus Riwayat',
                  const Ic.path(_trashPath, color: C.orange),
                  C.orangeBg,
                  () => _confirm(
                    context,
                    title: 'Hapus riwayat?',
                    text: 'Riwayat pencarian dan aktivitas terakhir di perangkat ini akan dihapus. Data absensi, cuti, dan formulir yang sudah terkirim tidak terpengaruh.',
                    ok: 'Hapus',
                    onOk: () => toast(context, 'Riwayat berhasil dihapus'),
                  ),
                ),
              ]),
              const Gap(20),
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: C.red, width: 1.5)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _confirm(
                    context,
                    title: 'Keluar dari akun?',
                    text: 'Anda perlu masuk kembali dengan NIK dan password.',
                    ok: 'Keluar',
                    onOk: () async {
                      await Api.instance.logout();
                      NotificationCenter.instance.reset();
                      await BannerStore.instance.clear();
                      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false);
                    },
                  ),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Ic('logout', color: C.red), const Gap(0, w: 8), Text('Keluar', style: ts(16, w: FontWeight.w700, c: C.red))]),
                  ),
                ),
              ),
              const Gap(14),
              Center(child: Text('AKPSatu v1.0.0', style: ts(12, c: C.muted))),
            ]),
          ),
        ]),
      );
}

class DetailProfileScreen extends StatefulWidget {
  /// Pemuat data; bawaannya mengambil dari server. Diganti hanya pada pengujian.
  final Future<Map<String, dynamic>> Function()? loader;
  const DetailProfileScreen({super.key, this.loader});
  @override
  State<DetailProfileScreen> createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  Future<Map<String, dynamic>>? future;
  bool reveal = false; // data dokumen & rekening disamarkan sampai pemilik menekan "Tampilkan"

  @override
  void initState() {
    super.initState();
    if (widget.loader != null || Session.instance.active) future = _fetch();
  }

  Future<Map<String, dynamic>> _fetch() => (widget.loader ?? Api.instance.profile)();

  Widget _sec(String t, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
        child: Row(children: [
          Expanded(child: Text(t, style: ts(13, w: FontWeight.w700, c: C.muted).copyWith(letterSpacing: .3))),
          ?trailing,
        ]),
      );

  Widget _card(List<(String, String)> rows) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Flexible(flex: 4, child: Text(rows[i].$1, style: ts(14, c: C.muted))),
                const Gap(0, w: 16),
                Flexible(flex: 5, child: Text(rows[i].$2, textAlign: TextAlign.right, style: ts(14, w: FontWeight.w600))),
              ]),
            ),
        ]),
      );

  /// Satu catatan riwayat (pendidikan, pengalaman, kontrak, promosi): judul + beberapa baris keterangan.
  Widget _record(String title, List<String> lines) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ts(14, w: FontWeight.w700, h: 1.4)),
          for (final l in lines.where((l) => l.isNotEmpty && l != '-')) ...[const Gap(2), Text(l, style: ts(13, c: C.muted, h: 1.4))],
        ]),
      );

  static String _date(Object? iso) {
    final d = DateTime.tryParse('${iso ?? ''}');
    return d == null ? '-' : L.instance.shortDate(d);
  }

  static String _v(Object? v) => (v == null || '$v'.isEmpty) ? '-' : '$v';

  static Map<String, dynamic> _map(Object? v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static List<Map<String, dynamic>> _list(Object? v) => v is List ? v.map((e) => _map(e)).toList() : const [];

  /// Samarkan nomor sensitif: tampilkan 4 karakter terakhir saja.
  String _hide(Object? v) {
    final s = _v(v);
    if (reveal || s == '-') return s;
    return s.length <= 4 ? '••••' : '•••• ${s.substring(s.length - 4)}';
  }

  String _gender(Object? g) => switch ('$g') { 'L' => 'Laki-laki', 'P' => 'Perempuan', _ => '-' };

  /// "1 Jan 2024 – 1 Jan 2025" (akhir kosong = masih berjalan).
  String _range(Object? from, Object? to) => '${_date(from)} – ${to == null ? 'Sekarang' : _date(to)}';

  List<Widget> _sample() => [
        _sec('DATA PEKERJAAN'),
        const Gap(10),
        _card(const [('NIK', '32601949'), ('Departemen', 'IT'), ('Jabatan', 'Supervisor IT'), ('Lokasi kerja', 'Site'), ('Status', 'Karyawan Tetap'), ('Tanggal bergabung', '01 Mar 2018'), ('Pola roster', '14 / 7')]),
        const Gap(10),
        _sec('DATA PRIBADI'),
        const Gap(10),
        _card(const [('Nama lengkap', 'Eddy Adha Saputra'), ('Tempat, tgl lahir', 'Makassar, 12 Mei 1990'), ('No. HP', '0812 •••• 7890'), ('Email', 'budi.santoso@email.com'), ('Mess', '[Blok / No. kamar]')]),
        const Gap(12),
        Text('Perubahan data pribadi dilakukan melalui HR Department.', style: ts(12, c: C.muted, h: 1.5)),
      ];

  Widget _block(String title, Widget body, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_sec(title, trailing: trailing), const Gap(10), body]),
      );

  /// Semua bagian data karyawan, urutannya sama dengan halaman detail karyawan di web HRIS.
  /// Bagian yang tidak dikirim server (server lama) atau kosong tidak ditampilkan.
  List<Widget> _sections(Map<String, dynamic> p) {
    final job = _map(p['job']);
    final me = _map(p['personal']);
    final sum = _map(p['summary']);
    final contract = p['contract'] is Map ? _map(p['contract']) : null;
    final docs = p['documents'] is Map ? _map(p['documents']) : null;
    final addr = _map(me['address']);
    final educations = _list(p['educations']);
    final experiences = _list(p['experiences']);
    final contracts = _list(p['contracts']);
    final promotions = _list(p['promotions']);
    final days = contract?['days_remaining'];

    return [
      _block('DATA PEKERJAAN', _card([
        ('NIK', _v(p['employee_no'])),
        ('Divisi', _v(job['division'])),
        ('Departemen', _v(job['department'])),
        ('Seksi', _v(job['section'])),
        ('Jabatan', _v(job['position'])),
        ('Grade', _v(job['grade'])),
        ('Tanggal masuk', _date(job['hire_date'])),
        ('Masa kerja', _v(sum['service_length'] ?? job['service_length'])),
        ('Status', _v(job['status'])),
        ('Status point of hire', _v(job['hire_status'])),
        ('Point of hire', _v(job['point_of_hire'])),
        ('Bandara tujuan', _v(job['destination_airport'])),
        ('Camp', _v(job['camp'])),
        ('Lokasi penempatan', _v(job['location'])),
        ('Lokasi kerja', _v(job['work_area'])),
        ('Pola shift', _v(job['shift_pattern'])),
        ('Pola roster', _v(job['roster_pattern'])),
        ('Sistem cuti', _v(job['leave_pattern'])),
        ('Tanggal MCU', _date(job['mcu_date'])),
        ('Klinik MCU', _v(job['clinic'])),
        ('Rekomendasi desa', _v(job['village_recommendation'])),
      ])),
      if (contract != null)
        _block('KONTRAK', _card([
          ('Perjanjian', _v(contract['type'])),
          ('Mulai', _date(contract['start_date'])),
          ('Berakhir pada', _date(contract['end_date'])),
          ('Sisa kontrak', days is num ? (days < 0 ? 'Berakhir' : '${days.toInt()} hari') : '-'),
        ])),
      _block('DATA PRIBADI', _card([
        ('Nama lengkap', _v(p['name'])),
        ('Jenis kelamin', _gender(me['gender'])),
        ('Agama', _v(me['religion'])),
        ('Status pernikahan', _v(me['marital_status'])),
        ('Tempat lahir', _v(me['birth_place'])),
        ('Tanggal lahir', _date(me['birth_date'])),
        ('Umur', _v(sum['age'])),
        ('Nama ibu kandung', _v(me['mother_name'])),
        ('Nama ayah', _v(me['father_name'])),
      ])),
      _block('KONTAK & ALAMAT', _card([
        ('Email', _v(me['email'])),
        ('No. HP', _v(me['phone'])),
        ('Alamat (KTP)', _v(addr['street'])),
        ('Kelurahan / Desa', _v(addr['village'])),
        ('Kecamatan', _v(addr['district'])),
        ('Kabupaten / Kota', _v(addr['regency'])),
        ('Provinsi', _v(addr['province'])),
        ('Kode pos', _v(addr['postal_code'])),
      ])),
      if (docs != null)
        _block(
          'DOKUMEN & BANK',
          _card([
            ('NIK KTP', _hide(docs['nik_ktp'])),
            ('No. Kartu Keluarga', _hide(docs['family_card_no'])),
            ('NPWP', _hide(docs['npwp'])),
            ('BPJS Ketenagakerjaan', _hide(docs['bpjs_employment_no'])),
            ('BPJS Kesehatan', _hide(docs['bpjs_health_no'])),
            ('Bank', _v(docs['bank'])),
            ('No. rekening', _hide(docs['bank_account_no'])),
            ('Nama pemilik rekening', _v(docs['bank_account_name'])),
            ('Ukuran baju', _v(docs['shirt_size'])),
            ('Ukuran celana', _v(docs['trouser_size'])),
          ]),
          trailing: InkWell(
            onTap: () => setState(() => reveal = !reveal),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), child: Text(reveal ? 'Sembunyikan' : 'Tampilkan', style: ts(13, w: FontWeight.w700, c: C.blue))),
          ),
        ),
      if (educations.isNotEmpty)
        _block('PENDIDIKAN', Column(children: [
          for (final r in educations)
            _record(_v(r['school']), [
              [r['level'], r['field_of_study']].where((e) => e != null && '$e'.isNotEmpty).join(' · '),
              [r['year_enrolled'], r['year_graduated']].where((e) => e != null && '$e'.isNotEmpty).join(' – '),
            ]),
        ])),
      if (experiences.isNotEmpty)
        _block('PENGALAMAN KERJA', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final r in experiences) _record(_v(r['company']), [_v(r['position']), '${_range(r['start_date'], r['end_date'])} · ${_v(r['duration'])}']),
          if (sum['total_experience'] != null) Padding(padding: const EdgeInsets.fromLTRB(4, 2, 4, 0), child: Text('Total pengalaman kerja sebelumnya: ${sum['total_experience']}', style: ts(12, c: C.muted))),
        ])),
      if (contracts.isNotEmpty)
        _block('RIWAYAT KONTRAK', Column(children: [
          for (final r in contracts) _record(_v(r['type']), [_range(r['start_date'], r['end_date'])]),
        ])),
      if (promotions.isNotEmpty)
        _block('RIWAYAT PROMOSI', Column(children: [
          for (final r in promotions)
            _record('${_v(r['from_position'])} → ${_v(r['to_position'])}', [
              if (r['from_grade'] != null || r['to_grade'] != null) '${_v(r['from_grade'])} → ${_v(r['to_grade'])}',
              _date(r['effective_date']),
            ]),
        ])),
      const Gap(2),
      Text('Perubahan data pribadi dilakukan melalui HR Department.', style: ts(12, c: C.muted, h: 1.5)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Tanpa sesi (mode contoh) tampilkan data contoh.
    if (future == null) return SubPage(title: 'Detail Profil', body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _sample()));
    return SubPage(
      title: 'Detail Profil',
      scroll: false,
      padding: EdgeInsets.zero,
      body: PullToRefresh(
        onRefresh: () async {
          setState(() => future = _fetch());
          try {
            await future;
          } catch (_) {}
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<Map<String, dynamic>>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()));
              }
              if (snap.hasError) {
                final e = snap.error;
                if (e is ApiException && e.unauthenticated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false);
                  });
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(children: [
                    Text('$e', textAlign: TextAlign.center, style: ts(14, c: C.red, h: 1.5)),
                    const Gap(12),
                    PrimaryButton('Coba lagi', onTap: () => setState(() => future = _fetch())),
                  ]),
                );
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: _sections(snap.data!));
            },
          ),
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final old = TextEditingController(), pw = TextEditingController(), pw2 = TextEditingController();
  bool show = false, done = false, tried = false, saving = false;
  String? serverError;

  @override
  void dispose() {
    old.dispose();
    pw.dispose();
    pw2.dispose();
    super.dispose();
  }

  String? get error {
    if (old.text.isEmpty) return 'Masukkan password saat ini.';
    if (pw.text.length < 8) return 'Password baru minimal 8 karakter.';
    if (pw.text == old.text) return 'Password baru harus berbeda dari password saat ini.';
    if (pw.text != pw2.text) return 'Konfirmasi password tidak sama.';
    return null;
  }

  Widget _field(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Fld(
          label,
          SizedBox(
            height: 48,
            child: TextField(
              controller: c,
              obscureText: !show,
              onChanged: (_) => setState(() {}),
              style: ts(15, w: FontWeight.w400),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.blue, width: 2)),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final forced = ModalRoute.of(context)?.settings.arguments == true;      // password awal wajib diganti sebelum memakai aplikasi
    if (done) {
      return SubPage(
        title: 'Ubah Password',
        body: ResultView(icon: Icons.check_circle, color: C.green, title: 'Password berhasil diubah', text: 'Gunakan password baru saat masuk berikutnya.', children: [
          PrimaryButton(forced ? 'Lanjut ke Beranda' : 'Kembali ke Profil', onTap: () async {
            if (forced) {
              await Api.instance.loadSummary();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, R.home, (r) => false);
            } else {
              Navigator.pop(context);
            }
          }),
        ]),
      );
    }
    final err = tried ? (error ?? serverError) : null;
    return SubPage(
      title: 'Ubah Password',
      bottom: PrimaryButton(saving ? 'Menyimpan...' : 'Simpan Password', height: 54, onTap: saving
          ? null
          : () async {
              setState(() {
                tried = true;
                serverError = null;
              });
              if (error != null) return;
              if (!Session.instance.active) {
                setState(() => done = true);      // mode contoh tanpa sesi
                return;
              }
              setState(() => saving = true);
              try {
                await Api.instance.changePassword(old.text, pw.text, pw2.text);
                if (mounted) setState(() => done = true);
              } on ApiException catch (e) {
                if (mounted) setState(() => serverError = e.message);
              } finally {
                if (mounted) setState(() => saving = false);
              }
            }),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _field('Password saat ini', old),
        _field('Password baru', pw),
        _field('Konfirmasi password baru', pw2),
        InkWell(
          onTap: () => setState(() => show = !show),
          child: SizedBox(height: 40, child: Row(children: [Ic('eye', color: C.muted), const Gap(0, w: 8), Text(show ? 'Sembunyikan password' : 'Tampilkan password', style: ts(14, w: FontWeight.w600, c: C.blue))])),
        ),
        if (err != null) ...[const Gap(8), Text(err, style: ts(13, w: FontWeight.w600, c: C.red))],
        const Gap(12),
        if (forced) ...[Text('Ini login pertama Anda. Ganti password awal (NIK) sebelum melanjutkan.', style: ts(13, w: FontWeight.w600, c: C.orange, h: 1.5)), const Gap(8)],
        Text('Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.', style: ts(12, c: C.muted, h: 1.5)),
      ]),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _items = [
    ('1. Pendahuluan', 'Kebijakan Privasi ini menjelaskan bagaimana aplikasi AKPSatu mengumpulkan, menggunakan, menyimpan, dan melindungi data pribadi karyawan. Dengan menggunakan aplikasi ini, Anda menyetujui praktik yang dijelaskan di sini.'),
    ('2. Data yang dikumpulkan', 'Kami dapat mengumpulkan:\n• Data identitas dan kepegawaian, seperti NIK, nama, jabatan, departemen, dan lokasi kerja.\n• Data kehadiran, jadwal kerja, cuti, dan lembur.\n• Data perangkat, seperti jenis perangkat, versi aplikasi, dan log penggunaan.\n• Data lokasi, foto, dan lampiran yang Anda kirim melalui fitur tertentu.'),
    ('3. Tujuan penggunaan data', 'Data digunakan untuk keperluan operasional perusahaan, antara lain pengelolaan absensi dan roster, proses pengajuan dan persetujuan, keselamatan dan kesehatan kerja, layanan akomodasi dan transportasi, pelatihan, serta peningkatan kualitas aplikasi.'),
    ('4. Izin perangkat', 'Aplikasi dapat meminta izin kamera, lokasi, notifikasi, dan penyimpanan. Izin hanya digunakan saat fitur terkait dipakai, misalnya memindai barcode, mengambil foto laporan, merekam aktivitas, atau mengirim pengingat. Anda dapat mengubah atau mencabut izin kapan saja melalui pengaturan perangkat.'),
    ('5. Pembagian data', 'Data tidak dijual kepada pihak ketiga. Data hanya dapat dilihat oleh pihak yang berwenang sesuai kebutuhan kerja, seperti atasan, HR, HSE, dan departemen terkait, serta dapat dibagikan kepada pihak lain bila diwajibkan oleh peraturan perundang-undangan.'),
    ('6. Penyimpanan dan keamanan', 'Kami menerapkan langkah keamanan yang wajar, termasuk pembatasan akses dan enkripsi saat pengiriman data. Data yang disimpan sementara di perangkat saat offline akan dikirim ke server dan dibersihkan setelah tersinkronisasi. Data disimpan selama diperlukan untuk tujuan di atas atau sesuai ketentuan yang berlaku.'),
    ('7. Hak Anda', 'Anda berhak mengetahui data yang tersimpan, meminta perbaikan data yang tidak akurat melalui HR Department, serta menghapus riwayat penggunaan di perangkat melalui menu Hapus Riwayat.'),
    ('8. Tanggung jawab pengguna', 'Jaga kerahasiaan password dan token verifikasi Anda. Jangan membagikan akun kepada orang lain, dan segera laporkan ke IT Support bila terjadi akses yang mencurigakan.'),
    ('9. Perubahan kebijakan', 'Kebijakan ini dapat diperbarui sewaktu-waktu. Perubahan penting akan diinformasikan melalui aplikasi.'),
    ('10. Kontak', 'Pertanyaan mengenai privasi dapat disampaikan kepada IT Support atau HR Department perusahaan.'),
  ];

  @override
  Widget build(BuildContext context) => SubPage(
        title: 'Kebijakan Privasi',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Terakhir diperbarui: 1 Oktober 2026', style: ts(12, c: C.muted)),
          const Gap(12),
          for (final s in _items) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.$1, style: ts(15, w: FontWeight.w800)),
                const Gap(6),
                Text(s.$2, style: ts(13, c: C.text2, h: 1.55)),
              ]),
            ),
          ],
        ]),
      );
}
