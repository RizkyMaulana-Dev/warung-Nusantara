# Warung Nusantara

![Splash Warung Nusantara](assets/splash/splash-warung-nusantara.gif)

Aplikasi pemesanan makanan untuk UMKM kuliner. Pelanggan melihat menu, mengatur opsi, checkout, membayar, dan melacak pesanan tanpa perlu chat penjual.

Target utama Android. Target web tersedia, tetapi belum dirilis.

## Status

| Item | Nilai |
|---|---|
| Versi | **1.0.5+2006** |
| Rilis | [GitHub Release v1.0.3](https://github.com/RizkyMaulana-Dev/warung-Nusantara/releases/tag/v1.0.3) (rilis terakhir) |
| APK | `warung-nusantara-1.0.5.apk` — 55.0 MB, debug-signed, build lokal |
| Analyze | bersih |
| Test | 52/52 lulus |
| Repo | [RizkyMaulana-Dev/warung-Nusantara](https://github.com/RizkyMaulana-Dev/warung-Nusantara) |

## Fitur

### Alur sesi
- Splash GIF → Welcome 3 slide → Login → Beranda untuk pengguna baru.
- Pengguna yang sudah login langsung masuk Beranda; Welcome dan Login dilewati.
- Logout mengembalikan ke Login. Saat aplikasi dibuka lagi, pengguna yang belum login melihat Welcome.
- Login email/nomor HP, daftar akun, lupa sandi, dan login Google masih simulasi lokal.

### Menu dan pesanan
- Beranda: banner promo otomatis, pencarian, chip kategori, menu populer, dan tambah cepat ke keranjang.
- Menu: daftar lengkap, filter kategori, pencarian, dan detail menu.
- Detail menu: level pedas, tambahan, catatan, stepper jumlah, dan harga yang berubah mengikuti opsi.
- Keranjang: ubah jumlah, hapus item, ongkir, voucher, dan checkout.
- Checkout: pilih alamat, metode bayar (QRIS, transfer BCA, bayar di tempat), voucher, lalu buat pesanan.
- Lacak pesanan: linimasa 5 tahap. Status berubah otomatis ke "Diantar kurir" setelah 30 detik (simulasi), lalu pengguna menandai "Pesanan tiba". Status dan timer dipulihkan saat aplikasi dibuka lagi.
- Halaman Pesanan menampilkan pesanan aktif; Riwayat hanya menampilkan pesanan yang sudah selesai.

### Akun dan loyalitas
- Profil: ubah nama/nomor HP, poin loyalitas, alamat tersimpan (tambah/ubah/hapus), riwayat, voucher, metode bayar (tambah/ubah/hapus), ganti cabang, pusat bantuan, pengaturan, dan logout.
- Poin: 1 poin per Rp 1.000. 100 poin bisa ditukar menjadi voucher Rp 10.000. Voucher hasil tukar disimpan lokal dan tetap ada setelah aplikasi dibuka lagi.
- Voucher bawaan: `HEMAT10`, `MAKAN5`, `BARU15`, `NGETEH`.
- Penukaran voucher poin kedua ditolak selama voucher `POIN10` masih dimiliki, jadi poin tidak terpotong sia-sia.

### Multi-cabang
- 3 cabang contoh: Senen, Mangga Besar, Cikini.
- Jarak dihitung dari lokasi pengguna memakai GPS.
- Kalau izin lokasi ditolak atau GPS mati, pengguna tetap bisa memilih cabang secara manual.
- Cabang terpilih disimpan di `cabang_id`.

### Notifikasi dan pengaturan
- Notifikasi dalam aplikasi: lonceng, badge jumlah belum dibaca, dan panel notifikasi.
- Notifikasi dibuat saat pesanan dibuat, pesanan diantar, dan pesanan selesai; daftar dan status bacanya tersimpan lokal.
- Pengaturan: notifikasi promo, status pesanan, dan mode hemat data. Nilainya tersimpan lokal.
- Mode hemat data memakai URL gambar lebih kecil (Unsplash/Wikimedia), decode lebih kecil, dan filter kualitas rendah; gambar yang sudah tampil ikut menyesuaikan saat toggle diubah. Lebar Wikimedia dipetakan ke ukuran thumbnail standar (250/330/500/960/1280/1920/3840 px) agar tidak ditolak server.

### Tampilan
- Plus Jakarta Sans dibundel di aplikasi, tidak mengambil font dari internet.
- Token warna dan spasi mengikuti `docs/DESIGN.md`.
- Bottom navigation berupa capsule mengambang 60 px, item di tengah, tanpa box shadow.
- Target sentuh minimal 44×44 px; skala teks dibatasi 0,9–1,3 agar label tidak terpotong.

## Tech stack

| Bagian | Pilihan |
|---|---|
| Framework | Flutter 3.47.6, Dart 3.13.5 |
| UI | Material 3, `google_fonts` dengan font lokal |
| State | `ChangeNotifier` singleton, tanpa Provider/Riverpod |
| Penyimpanan | `shared_preferences` 2.5.6 + `shared_preferences_android` 2.5.3 |
| Lokasi | `geolocator` 13.x |
| Tautan eksternal | `url_launcher` |
| Ikon | `flutter_launcher_icons` dari frame terakhir GIF splash |

`http` dan `connectivity_plus` sudah ada di `pubspec.yaml`, tetapi belum dipakai karena belum ada layer API.

## Struktur proyek

```text
lib/
├── main.dart                  # bootstrap, theme, text scale, notification observer
├── core/
│   ├── constants.dart         # warna, tipografi, spasi, ukuran, formatRupiah
│   ├── theme.dart             # ThemeData Material 3
│   ├── image_url.dart         # transformasi URL untuk mode hemat data
│   └── messages.dart          # teks pesan + toast overlay
├── data/
│   └── menu_data.dart         # menu, kategori, banner promo (mock)
├── features/
│   ├── splash/                # routing sesi + muat store
│   ├── welcome/               # 3 slide onboarding
│   ├── login/                 # login, daftar, lupa sandi
│   ├── main/                  # MainShell: IndexedStack + BottomNav
│   ├── home/                  # Beranda
│   ├── menu/                  # daftar menu + detail
│   ├── cart/                  # keranjang
│   ├── checkout/              # alamat, pembayaran, voucher
│   ├── tracking/              # linimasa pesanan
│   ├── pesanan/               # pesanan aktif
│   ├── riwayat/               # riwayat pesanan selesai
│   ├── profile/               # akun, poin, logout
│   ├── alamat/                # CRUD alamat
│   ├── pembayaran/            # CRUD metode bayar
│   ├── voucher/               # daftar voucher
│   ├── cabang/                # pilih cabang + jarak GPS
│   ├── bantuan/               # pusat bantuan / WhatsApp
│   └── pengaturan/            # preferensi aplikasi
├── state/                     # store ChangeNotifier
└── widgets/                   # komponen reusable
```

Dokumen produk dan desain ada di `docs/`:

- `docs/PRD.md` — kebutuhan produk.
- `docs/DESIGN.md` — token, komponen, dan aturan desain.
- `docs/superpowers/specs/2026-10-21-notifikasi-splash-animasi-design.md` — desain notifikasi, toast, animasi, dan splash.

## Menjalankan

Prasyarat: Flutter 3.47+ dan Android SDK untuk build APK.

```bash
flutter pub get
flutter run
```

Perintah verifikasi:

```bash
flutter analyze
flutter test
```

Build release:

```bash
flutter build apk --release
```

Hasil: `build/app/outputs/flutter-apk/app-release.apk`.

Install ke HP yang terhubung:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Kalau muncul `INSTALL_FAILED_USER_RESTRICTED`, aktifkan **Install via USB** di opsi developer HP atau setujui prompt di layar.

Build web:

```bash
flutter build web
```

## Penyimpanan lokal

Data yang bertahan setelah aplikasi ditutup:

| Data | Kunci SharedPreferences |
|---|---|
| Sesi login | `is_logged_in` |
| Email | `email` |
| Nama pengguna | `nama_pengguna` |
| Nomor HP | `nomor_hp` |
| Ingat saya | `ingat_saya`, `email_tersimpan` |
| Cabang terpilih | `cabang_id` |
| Notifikasi promo | `notif_promo` |
| Notifikasi pesanan | `notif_pesanan` |
| Mode hemat data | `hemat_data` |
| Daftar alamat | `alamat_daftar` (JSON) |
| Daftar metode bayar | `metode_bayar_daftar` (JSON) |
| Daftar notifikasi | `notifikasi_daftar` (JSON) |
| Daftar pesanan | `pesanan_daftar` (JSON) |
| Poin loyalitas | `loyalty_poin` |
| Voucher hasil tukar poin | `voucher_tambahan` (JSON) |

Data yang masih in-memory dan hilang saat aplikasi ditutup:

- Keranjang (`CartStore`).

Notifikasi dan pesanan disimpan global karena aplikasi masih single-user demo; belum dipisahkan per akun.

`is_first_launch` masih ditulis, tetapi tidak lagi dipakai untuk menentukan halaman. Routing splash hanya memakai `is_logged_in`.

## Batasan yang perlu diketahui

- **Belum ada backend/API.** Login, daftar, lupa sandi, pembayaran, dan status pesanan semuanya simulasi lokal.
- **Pembayaran belum nyata.** QRIS tidak menampilkan kode QR; transfer dan COD hanya tercatat sebagai teks.
- **Peta kurir belum aktif.** Tombol "Lihat posisi kurir" hanya menampilkan pesan.
- **APK release masih debug-signed.** Belum siap untuk Play Store.
- **Data pribadi belum terenkripsi.** SharedPreferences menyimpan data sebagai teks biasa.
- **iOS belum dikonfigurasi.** Folder `ios/` belum ada.
- **Toggle notifikasi belum dipakai untuk menyaring notifikasi.** Nilainya tersimpan, tetapi `NotificationStore` masih selalu menambah notifikasi.
- **Voucher belum ditandai sudah terpakai**, jadi bisa dipilih lagi.
- **Deskripsi `pubspec.yaml` dan `web/manifest.json` masih default.** Nama PWA masih `umkm_pesanan`.

## Dokumentasi untuk agent berikutnya

Knowledge base lengkap ada di Obsidian:

```text
~/Documents/Obsidian Vault/01 - Projects/Warung Nusantara KB/
```

Mulai dari `Warung Nusantara KB.md`. Isinya: overview, arsitektur, fitur as-built, design system, keputusan, pelajaran, dan changelog.

## Riwayat versi

- **v1.0.5** — 24 Oktober 2026, build lokal. Voucher tukar poin kini tersimpan lokal (`voucher_tambahan`), penukaran ganda ditolak, dan gambar Wikimedia (termasuk Pisang Goreng Keju) memakai ukuran thumbnail yang didukung agar tidak gagal dimuat.
- **v1.0.4** — 24 Oktober 2026, build lokal. Persistensi notifikasi dan pesanan, CRUD lengkap alamat/metode bayar, riwayat hanya pesanan selesai, dan mode hemat data yang benar-benar mengecilkan URL + decode gambar.
- **v1.0.3** — 23 Oktober 2026. Rilis GitHub pertama. Fix crash `shared_preferences_android` di release build, sesi login persisten, alur Welcome, persistensi pengaturan, ikon launcher baru, dan bottom nav mengambang.

## Lisensi

Belum ada file lisensi eksplisit di repo ini.
