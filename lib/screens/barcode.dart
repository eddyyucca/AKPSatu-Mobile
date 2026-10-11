import 'package:flutter/material.dart' hide Text;
import 'package:qr_flutter/qr_flutter.dart';
import '../api/api.dart';
import '../theme.dart';
import '../widgets.dart';
import 'shell.dart';

/// QR makan: sama persis pola `absensi-kantin` (lihat Modules kartu karyawan di sana) -- QR berisi NIK
/// polos (tanpa prefiks/JSON), error correction level H, kiosk kantin membacanya langsung sebagai NIK.
class BarcodePage extends StatelessWidget {
  const BarcodePage({super.key});

  Widget _meal(String t, String menu, String time, String badge, Tone tone, {bool first = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: ts(14, w: FontWeight.w700, h: 1.4)),
              Text(menu, style: ts(12, c: C.text2, h: 1.4)),
              Text(time, style: ts(12, c: C.muted, h: 1.4)),
            ]),
          ),
          const Gap(0, w: 12),
          Pill(badge, tone: tone),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final nik = Session.instance.nikOr('32601949');
    return Column(children: [
      const TabHeader('Barcode Makan'),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Text(Session.instance.nameOr('Eddy Adha Saputra'), style: ts(17, w: FontWeight.w800, h: 1.4)),
                Text('NIK $nik${Session.instance.headline.isEmpty ? '' : ' · ${Session.instance.headline}'}', style: ts(13, c: C.muted, h: 1.4)),
                const Gap(14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(12)),
                  child: Semantics(
                    label: 'QR code makan untuk NIK $nik',
                    // Payload = NIK polos, sama seperti kartu karyawan di absensi-kantin (qrcodejs, correctLevel H);
                    // kiosk kantin membaca string ini langsung sebagai NIK, tanpa prefiks/JSON.
                    child: QrImageView(data: nik, version: QrVersions.auto, size: 225, errorCorrectionLevel: QrErrorCorrectLevel.H, backgroundColor: Colors.white),
                  ),
                ),
                const Gap(14),
                Text('Tunjukkan QR ini ke kiosk kantin.\nNaikkan kecerahan layar bila sulit terbaca.', textAlign: TextAlign.center, style: ts(14, c: C.text2, h: 1.5)),
              ]),
            ),
            const Gap(14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Gap(12),
                Text('Menu & jatah makan hari ini', style: ts(14, w: FontWeight.w800)),
                Text('Menu dipublikasikan Dept. Kantin', style: ts(12, c: C.muted)),
                const Gap(4),
                _meal('Sarapan', 'Nasi kuning, telur balado, buah', '05:30 – 08:00 · diambil 06:12', 'Sudah diambil', Tone.ok, first: true),
                _meal('Makan Siang', 'Nasi, ayam bakar, sayur asem, tempe', '11:00 – 13:30 · diambil 12:05', 'Sudah diambil', Tone.ok),
                _meal('Makan Malam', 'Nasi, ikan kuah kuning, tumis kangkung', '17:30 – 20:30', 'Tersedia', Tone.info),
              ]),
            ),
          ]),
        ),
      ),
    ]);
  }
}
