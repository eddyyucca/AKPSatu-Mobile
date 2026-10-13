# AKPSatu Mobile v0.1

Aplikasi mobile karyawan AKP (Flutter). Login memakai akun **Portal AKPSatu** (NIK + password yang sama dengan web),
dan modul HRIS hanya menampilkan data **karyawan yang sedang login**.

## Menjalankan

```
flutter pub get
flutter run            # atau F5 di IDE
```

- Semua layanan memakai server online: Portal `https://portal.lameruru.web.id`, HRIS `https://hris.lameruru.web.id`, Komplain GA `https://komplain.lameruru.web.id`. Tidak ada layanan lokal yang dibutuhkan, termasuk untuk email token verifikasi (dikirim Portal).
- Server lokal (opsional): `--dart-define=PORTAL_URL=http://10.0.2.2:8000 --dart-define=HRIS_URL=http://10.0.2.2:8001 --dart-define=KOMPLAIN_URL=http://10.0.2.2:8004` (10.0.2.2 = komputer host dari emulator; HP fisik pakai IP komputer).
- `usesCleartextTraffic` di AndroidManifest hanya dibutuhkan untuk server HTTP lokal. Hapus bila semua sudah HTTPS.

## Alur login

1. `POST {PORTAL_URL}/api/mobile/login` {username: NIK, password} -> token Bearer (umur `PORTAL_MOBILE_TTL` menit, bawaan 720).
2. Akun dengan password awal (NIK) diarahkan, setelah token, ke layar **Ubah Password** (`POST /api/mobile/password`); sebelum diganti, HRIS menolak data (kode `password_change_required`).
3. **Token verifikasi (6 digit)**: dibuat, dikirim ke email akun, dan diperiksa oleh **Portal** (`POST /api/mobile/otp/send` dan `/otp/verify`); berlaku 10 menit, maksimal 5 kali salah, kirim ulang tiap 30 detik. Aplikasi mengirim `device_id` (UUID acak per perangkat, `Session.deviceId`) saat login; bila perangkat belum dipercaya Portal menjawab `otp_required: true` dan token login hanya bisa dipakai untuk dua endpoint itu (klaim `otp=false` ditolak HRIS dan endpoint mobile lain). Setelah benar, perangkat dipercaya selama `PORTAL_MOBILE_DEVICE_TRUST_DAYS` (bawaan 180 hari), jadi login berikutnya (mis. sesi berakhir) hanya NIK + password.
4. Token login disimpan di perangkat (`lib/api/api.dart`, kelas `Session`) dan dipakai ulang saat aplikasi dibuka; jika kedaluwarsa kembali ke login. Aplikasi yang ditutup di tengah token email mulai dari login lagi.

### Pengaturan server untuk token email (Portal, `.env`)

| Kunci | Fungsi |
| --- | --- |
| `PORTAL_MOBILE_OTP` | `true` (bawaan) / `false` = matikan token email sama sekali (mis. email bermasalah) |
| `PORTAL_MOBILE_DEVICE_TRUST_DAYS` | Lama perangkat dipercaya setelah lolos token (bawaan 180; `0` = selamanya) |
| `MAILSVC_URL`, `MAILSVC_TOKEN` | Kirim lewat AKP Mail (`POST /api/v1/emails`). Kosong = lewat pengaturan email Portal sendiri (`MAIL_*`) |
| `PORTAL_MOBILE_TTL` | Umur token login (menit, bawaan 720) |

Setelah deploy: `php artisan migrate` (tabel `mobile_devices`), lalu pastikan email Portal benar-benar terkirim (`MAIL_MAILER` bukan `log`, atau `MAILSVC_*` diisi dan antrian AKP Mail jalan).

## Notifikasi

Saat pengajuan **lembur disetujui/ditolak di HRIS (web)**, pengaju menerima notifikasi di aplikasi.

- **Server (HRIS):** `OvertimeService::decide` memicu event `OvertimeDecided`; modul Mobile mencatatnya di tabel `mobile_notifications` lewat `MobileNotifier` (titik masuk tunggal untuk notifikasi baru). API: `GET /api/mobile/v1/notifications` (daftar), `/notifications/summary` (jumlah belum dibaca + id terbaru), `POST /notifications/{id}/read`, `POST /notifications/read-all`. Hanya milik karyawan yang login.
- **Aplikasi:** `NotificationCenter` (`lib/api/notifications.dart`) memeriksa `summary` tiap 30 detik selama layar utama tampil dan aplikasi terbuka, dan langsung saat aplikasi dibuka kembali. Notifikasi baru memunculkan banner di dalam aplikasi, menambah lencana lonceng di Beranda, dan masuk ke layar Notifikasi (ketuk = tandai dibaca + buka layar tujuan).
- **Belum ada:** push saat aplikasi tertutup (butuh FCM: proyek Firebase + `firebase_messaging`). Tempat menambahkannya di server: `MobileNotifier::notify`, setelah baris disimpan.
- Server lama tanpa fitur ini (404) tidak membuat error: lonceng tanpa angka dan layar Notifikasi memberi pesan jelas.

## API HRIS (semua hanya data milik sendiri)

`GET {HRIS_URL}/api/mobile/v1/` `me` | `roster?month=2026-10` | `attendance?month=2026-10` | `overtimes`;
`POST overtimes` {work_date, start_time, end_time, reason}; `POST overtimes/{id}/cancel`.
Kelas `Api` (`lib/api/api.dart`) sudah menyediakan: `profile()`, `roster(month)`, `attendance(month)`, `overtimes()`, `submitOvertime()`, `cancelOvertime()`.

## Komplain GA (lapor dan pantau)

Menu **GA & Camp > Komplain GA** (`lib/screens/komplain.dart`, API di `lib/api/komplain.dart`).
- **Semua karyawan**: buat laporan (jenis Receptionist/Housekeeping/Laundry, bangunan, kamar, uraian, sampai 6 foto dari kamera/galeri) dan lihat **Laporan Saya** beserta statusnya.
- **Petugas** (peran Portal `superadmin`, `receptionist`, `hk`, `laundry` pada modul `komplain-ga`): tab **Pantau** berisi ringkasan per status, laporan terlambat (melewati SLA), pencarian, dan filter. Petugas hanya melihat jenis laporan sesuai perannya; `superadmin` melihat semua.
- Alur token: aplikasi menukar token login dengan token khusus modul lewat `POST {PORTAL_URL}/api/mobile/app-token` {app: `komplain-ga`}, lalu memanggil `{KOMPLAIN_URL}/api/mobile/v1/` `options` | `complaints` | `complaints/{tiket}` | `monitor`; `POST complaints` (multipart, `photos[]`). Nama dan NIK pelapor selalu diambil server dari token.
- Server lokal: modul `komplain-ga` terdaftar di Portal (`apps.json` menjalankannya di port 8004); sementara menguji dari emulator pakai `KOMPLAIN_URL=http://10.0.2.2:8004`.
- Tes: `flutter test test/komplain_api_test.dart test/komplain_screens_test.dart`.

## Status layar

Sudah terhubung data asli: Login, Ubah Password, Beranda (nama/jabatan), Profil, Detail Profil, Keluar.
Layar Roster, Absensi, Pengajuan Lembur masih tampilan contoh; API-nya sudah siap dipakai (lihat kelas `Api`).
Tanpa sesi login (mis. saat uji tampilan) layar menampilkan data contoh.
