import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../l10n/lang.dart';
import '../pattern.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

InputDecoration _loginField(String hint, {Widget? suffix}) => InputDecoration(
      hintText: tr(hint),
      hintStyle: ts(16, c: const Color(0xFF757575), w: FontWeight.w400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      constraints: const BoxConstraints(minHeight: 52, maxHeight: 52),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.input)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.input)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.blue, width: 2)),
    );

/// Lanjut setelah login/verifikasi: ganti password awal bila wajib, selain itu ke beranda.
Future<void> _enterApp(BuildContext context) async {
  if (Session.instance.mustChangePassword) {
    Navigator.pushNamedAndRemoveUntil(context, R.ubahPassword, (r) => false, arguments: true);
    return;
  }
  await Api.instance.loadSummary();
  if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, R.home, (r) => false);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool show = false, loading = false;
  String? error;
  final nik = TextEditingController(), pw = TextEditingController();

  @override
  void dispose() {
    nik.dispose();
    pw.dispose();
    super.dispose();
  }

  /// Masuk memakai akun Portal (NIK + password). Akun dengan password awal diminta menggantinya dulu.
  Future<void> _login() async {
    if (loading) return;
    if (nik.text.trim().isEmpty || pw.text.isEmpty) {
      setState(() => error = 'Isi NIK dan password.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await Api.instance.login(nik.text, pw.text);
      if (!mounted) return;
      // Token email dikirim Portal dan hanya diminta sekali per perangkat; login berikutnya (mis. sesi berakhir) langsung masuk.
      if (Session.instance.pendingOtp) {
        Navigator.pushNamed(context, R.token);
      } else {
        await _enterApp(context);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _field(String label, Widget input) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: ts(13, w: FontWeight.w600, c: C.text2)),
        const Gap(6),
        input,
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.navy,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: Column(children: [
                    BrandHeader(
                      padding: const EdgeInsets.fromLTRB(28, 56, 28, 32),
                      child: Column(children: [
                        const Logo(size: 112),
                        const Gap(16),
                        Text('AKPSatu', style: ts(28, w: FontWeight.w800, c: Colors.white).copyWith(letterSpacing: -0.3)),
                        const Gap(6),
                        Text('Satu aplikasi untuk semua kebutuhan kerja karyawan AKP.', textAlign: TextAlign.center, style: ts(15, c: C.pale, h: 1.5, w: FontWeight.w400)),
                      ]),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Text('Masuk|login', style: ts(20, w: FontWeight.w800)),
                          const Gap(16),
                          _field('NIK', TextField(controller: nik, keyboardType: TextInputType.number, textInputAction: TextInputAction.next, style: ts(16, w: FontWeight.w400), decoration: _loginField('Contoh: 32601949'))),
                          const Gap(16),
                          _field(
                            'Password',
                            TextField(
                              controller: pw,
                              onSubmitted: (_) => _login(),
                              obscureText: !show,
                              style: ts(16, w: FontWeight.w400),
                              decoration: _loginField(
                                'Masukkan password',
                                suffix: IconButton(
                                  tooltip: tr('Tampilkan password'),
                                  onPressed: () => setState(() => show = !show),
                                  icon: const Ic('eye', color: C.muted),
                                ),
                              ),
                            ),
                          ),
                          if (error != null) ...[const Gap(12), Text(error!, style: ts(13, w: FontWeight.w600, c: C.red))],
                          const Gap(16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => toast(context, 'Hubungi IT Support untuk reset password'),
                              child: SizedBox(height: 40, child: Center(child: Text('Lupa password?', style: ts(14, w: FontWeight.w600, c: C.blue)))),
                            ),
                          ),
                          const Gap(16),
                          Material(
                            color: C.blue,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: loading ? null : _login,
                              child: SizedBox(height: 54, child: Center(child: loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Text('Masuk|login', style: ts(16, w: FontWeight.w700, c: Colors.white)))),
                            ),
                          ),
                          const Gap(16),
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, R.driver),
                            child: SizedBox(height: 40, child: Center(child: Text('Masuk sebagai Driver (demo)', style: ts(13, w: FontWeight.w600, c: C.blue)))),
                          ),
                          const Spacer(),
                          Center(child: Text('Butuh bantuan? Hubungi IT Support · AKPSatu v1.0.0', textAlign: TextAlign.center, style: ts(12, c: C.muted, w: FontWeight.w400))),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});
  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  String code = '';
  bool sending = false, verifying = false;
  String? error, info, masked;
  int cooldown = 0;
  Timer? ticker;

  @override
  void initState() {
    super.initState();
    _send();
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    cooldown = seconds;
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || cooldown <= 1) t.cancel();
      if (mounted) setState(() => cooldown = cooldown > 0 ? cooldown - 1 : 0);
    });
  }

  /// Sesi hilang (kedaluwarsa / token login perangkat lain): kembali ke login.
  bool _backToLogin(ApiException e) {
    if (!e.unauthenticated && e.code != 'device_mismatch') return false;
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false);
    return true;
  }

  /// Minta Portal mengirim token ke email akun.
  Future<void> _send() async {
    if (sending || cooldown > 0) return;
    setState(() {
      sending = true;
      error = null;
      info = null;
      code = '';
    });
    try {
      final r = await Api.instance.sendOtp();
      if (!mounted) return;
      setState(() {
        masked = r.email ?? masked;
        info = masked == null ? 'Token dikirim ke email Anda' : 'Token dikirim ke $masked';
        _startCooldown(r.retryAfter);
      });
    } on ApiException catch (e) {
      if (_backToLogin(e) || !mounted) return;
      setState(() {
        error = e.message;
        if (e.retryAfter != null) _startCooldown(e.retryAfter!);   // sudah terkirim barusan: tunggu sebelum kirim ulang
      });
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  /// Token diperiksa di Portal; bila benar, perangkat ini tidak diminta token lagi untuk login berikutnya.
  Future<void> _verify() async {
    if (verifying) return;
    setState(() {
      verifying = true;
      error = null;
    });
    try {
      await Api.instance.verifyOtp(code);
      if (mounted) await _enterApp(context);
    } on ApiException catch (e) {
      if (_backToLogin(e) || !mounted) return;
      setState(() {
        error = e.message;
        code = '';
      });
    } finally {
      if (mounted) setState(() => verifying = false);
    }
  }

  void press(String k) => setState(() {
        if (k == 'del') {
          if (code.isNotEmpty) code = code.substring(0, code.length - 1);
        } else if (code.length < 6) {
          code += k;
        }
      });

  Widget _key(String k, void Function(String) press) {
    if (k.isEmpty) return const SizedBox();
    return Semantics(
      button: true,
      label: k == 'del' ? 'Hapus digit' : 'Angka $k',
      child: Material(
        color: k == 'del' ? Colors.transparent : C.bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => press(k),
          child: Center(child: k == 'del' ? const Ic.path('M21 5H9l-6 7 6 7h12a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1zM12 9l6 6M18 9l-6 6', size: 24) : Text(k, style: ts(22, w: FontWeight.w600))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];
    final complete = code.length == 6;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ScrollFill(child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                label: tr('Kembali ke login'),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.maybePop(context),
                  child: const SizedBox(width: 44, height: 44, child: Center(child: Ic('back', size: 22, stroke: 2))),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: C.blueSoft, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Ic('shield', size: 28, color: C.blue)),
              ),
              const Gap(10),
              const Gap(8),
              Text('Masukkan Token', style: ts(26, w: FontWeight.w800)),
              const Gap(10),
              Text(masked == null ? 'Ketik 6 digit token verifikasi yang dikirim ke email Anda.' : 'Ketik 6 digit token verifikasi yang dikirim ke $masked. Token hanya diminta sekali di perangkat ini.', style: ts(15, c: C.muted, h: 1.5, w: FontWeight.w400)),
              if (info != null && error == null) ...[const Gap(8), Text(info!, style: ts(13, w: FontWeight.w600, c: C.blue))],
              if (error != null) ...[const Gap(8), Text(error!, style: ts(13, w: FontWeight.w600, c: C.red))],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              for (var i = 0; i < 6; i++) ...[
                if (i > 0) const Gap(0, w: 10),
                Expanded(
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: i == code.length ? C.blue : (i < code.length ? const Color(0xFF8FA6C3) : C.input), width: i == code.length ? 2 : 1),
                    ),
                    child: Text(i < code.length ? code[i] : '', style: ts(24, w: FontWeight.w800)),
                  ),
                ),
              ]
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: Text('Tidak menerima token?', style: ts(14, c: C.muted, w: FontWeight.w400))),
              InkWell(
                onTap: (sending || cooldown > 0) ? null : _send,
                child: SizedBox(height: 44, child: Center(child: Text(sending ? 'Mengirim...' : (cooldown > 0 ? 'Kirim ulang (${cooldown}s)' : 'Kirim ulang'), style: ts(14, w: FontWeight.w700, c: (sending || cooldown > 0) ? C.muted : C.blue)))),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Material(
              color: complete ? C.blue : C.line,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: complete && !verifying ? _verify : null,
                child: SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: Center(child: Text('Verifikasi & Masuk', style: ts(16, w: FontWeight.w700, c: complete ? Colors.white : C.muted))),
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(children: [
              for (var r = 0; r < 4; r++) ...[
                if (r > 0) const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: Row(children: [
                    for (var c = 0; c < 3; c++) ...[
                      if (c > 0) const SizedBox(width: 8),
                      Expanded(child: _key(keys[r * 3 + c], press)),
                    ],
                  ]),
                ),
              ],
            ]),
          ),
        ])),
      ),
    );
  }
}
