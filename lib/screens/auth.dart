import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool show = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.navy,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
                    child: Column(children: [
                      const Logo(size: 104),
                      const Gap(16),
                      Text('AKPSatu', style: ts(28, w: FontWeight.w800, c: Colors.white)),
                      const Gap(6),
                      Text('Satu aplikasi untuk semua kebutuhan kerja karyawan AKP.',
                          textAlign: TextAlign.center, style: ts(15, c: C.pale, h: 1.5)),
                    ]),
                  ),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: box.maxHeight - 250),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Masuk', style: ts(20, w: FontWeight.w800)),
                      const Gap(16),
                      const TextBox('NIP', hint: 'Contoh: AKP001'),
                      LabeledField(
                        'Password',
                        TextField(
                          obscureText: !show,
                          style: ts(15),
                          decoration: fieldDeco(hint: 'Masukkan password').copyWith(
                            suffixIcon: IconButton(
                              tooltip: 'Tampilkan password',
                              onPressed: () => setState(() => show = !show),
                              icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: C.muted),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () => toast(context, 'Hubungi IT Support untuk reset password'), child: Text('Lupa password?', style: ts(14, w: FontWeight.w600, c: C.blue))),
                      ),
                      const Gap(4),
                      PrimaryButton('Masuk', height: 54, onTap: () => Navigator.pushNamed(context, R.token)),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, R.driver),
                          child: Text('Masuk sebagai Driver (demo)', style: ts(13, w: FontWeight.w600, c: C.blue)),
                        ),
                      ),
                      const Gap(16),
                      Center(child: Text('Butuh bantuan? Hubungi IT Support · AKPSatu v1.0.0', textAlign: TextAlign.center, style: ts(12, c: C.muted))),
                    ]),
                  ),
                ]),
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
  bool resent = false;

  void press(String k) => setState(() {
        if (k == 'del') {
          if (code.isNotEmpty) code = code.substring(0, code.length - 1);
        } else if (code.length < 6) {
          code += k;
        }
      });

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];
    return SubPage(
      title: 'Verifikasi Token',
      scroll: false,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      body: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Masukkan Token', style: ts(22, w: FontWeight.w800)),
            const Gap(8),
            Text('Ketik 6 digit token yang dikirim ke nomor terdaftar Anda (0812 •••• 7890).', style: ts(14, c: C.muted, h: 1.5)),
          ]),
        ),
        const Gap(24),
        Row(children: [
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) const Gap(0, w: 8),
            Expanded(
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: i == code.length ? C.blue : (i < code.length ? const Color(0xFF8FA6C3) : C.input),
                    width: i == code.length ? 2 : 1,
                  ),
                ),
                child: Text(i < code.length ? code[i] : '', style: ts(24, w: FontWeight.w800)),
              ),
            ),
          ]
        ]),
        const Gap(14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Tidak menerima token? ', style: ts(14, c: C.muted)),
          GestureDetector(
            onTap: () => setState(() => resent = true),
            child: Text(resent ? 'Terkirim ulang' : 'Kirim ulang', style: ts(14, w: FontWeight.w700, c: C.blue)),
          ),
        ]),
        const Spacer(),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final k in keys)
              if (k.isEmpty)
                const SizedBox()
              else
                Material(
                  color: k == 'del' ? Colors.transparent : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => press(k),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: k == 'del' ? null : BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.line)),
                      child: k == 'del' ? const Icon(Icons.backspace_outlined) : Text(k, style: ts(22, w: FontWeight.w700)),
                    ),
                  ),
                ),
          ],
        ),
        const Gap(14),
        PrimaryButton('Verifikasi & Masuk', height: 54, onTap: code.length == 6 ? () => Navigator.pushNamedAndRemoveUntil(context, R.home, (r) => false) : null),
      ]),
    );
  }
}
