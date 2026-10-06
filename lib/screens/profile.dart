import 'package:flutter/material.dart';
import '../pattern.dart';
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
                child: Text('EA', style: ts(30, w: FontWeight.w800, c: C.blueFg)),
              ),
              const Gap(10),
              Text('Eddy Adha Saputra', style: ts(22, w: FontWeight.w800, c: Colors.white, h: 1.4)),
              Text('Supervisor IT · IT Department', style: ts(14, c: C.pale, h: 1.4)),
              const Gap(10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(99)),
                child: Text('NIK 32601949', style: ts(12, w: FontWeight.w700, c: const Color(0xFFDCE7FB)).copyWith(letterSpacing: 1)),
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
                _row('Kebijakan Privasi', const Ic('shield', color: C.teal), C.tealBg, () => Navigator.pushNamed(context, R.privasi), first: true),
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
                    text: 'Anda perlu masuk kembali dengan NIK dan token verifikasi.',
                    ok: 'Keluar',
                    onOk: () => Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false),
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

class DetailProfileScreen extends StatelessWidget {
  const DetailProfileScreen({super.key});

  Widget _sec(String t) => Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 0), child: Text(t, style: ts(13, w: FontWeight.w700, c: C.muted).copyWith(letterSpacing: .3)));

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
                Text(rows[i].$1, style: ts(14, c: C.muted)),
                const Gap(0, w: 16),
                Flexible(child: Text(rows[i].$2, textAlign: TextAlign.right, style: ts(14, w: FontWeight.w600))),
              ]),
            ),
        ]),
      );

  @override
  Widget build(BuildContext context) => SubPage(
        title: 'Detail Profil',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sec('DATA PEKERJAAN'),
          const Gap(10),
          _card(const [('NIK', '32601949'), ('Departemen', 'IT'), ('Jabatan', 'Supervisor IT'), ('Lokasi kerja', 'Site'), ('Status', 'Karyawan Tetap'), ('Tanggal bergabung', '01 Mar 2018'), ('Pola roster', '14 / 7')]),
          const Gap(10),
          _sec('DATA PRIBADI'),
          const Gap(10),
          _card(const [('Nama lengkap', 'Eddy Adha Saputra'), ('Tempat, tgl lahir', 'Makassar, 12 Mei 1990'), ('No. HP', '0812 •••• 7890'), ('Email', 'budi.santoso@email.com'), ('Mess', '[Blok / No. kamar]')]),
          const Gap(12),
          Text('Perubahan data pribadi dilakukan melalui HR Department.', style: ts(12, c: C.muted, h: 1.5)),
        ]),
      );
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final old = TextEditingController(), pw = TextEditingController(), pw2 = TextEditingController();
  bool show = false, done = false, tried = false;

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
    if (done) {
      return SubPage(
        title: 'Ubah Password',
        body: ResultView(icon: Icons.check_circle, color: C.green, title: 'Password berhasil diubah', text: 'Gunakan password baru saat masuk berikutnya.', children: [
          PrimaryButton('Kembali ke Profil', onTap: () => Navigator.pop(context)),
        ]),
      );
    }
    final err = tried ? error : null;
    return SubPage(
      title: 'Ubah Password',
      bottom: PrimaryButton('Simpan Password', height: 54, onTap: () {
        setState(() => tried = true);
        if (error == null) setState(() => done = true);
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
