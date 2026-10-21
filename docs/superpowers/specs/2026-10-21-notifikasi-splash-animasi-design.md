# Desain: Notifikasi dalam aplikasi, feedback yang bisa digeser, animasi halus, dan splash animatif

Tanggal: 2026-10-21
Status: menunggu persetujuan

## 1. Alasan

Aplikasi sekarang tidak punya cara memberi tahu pengguna kalau pesanannya berubah
status: perubahan hanya terlihat kalau pengguna membuka halaman Lacak pesanan. Selain
itu tiga hal mengganggu: (a) notifikasi singkat (toast) tidak bisa ditutup pengguna,
(b) tanda centang pada chip filter tidak terlihat karena warnanya gelap di atas latar
hijau, dan (c) perpindahan tampilan terasa kaku karena muncul mendadak tanpa animasi.
Splash juga masih statis padahal sudah ada animasi yang dibuat khusus.

## 2. Sasaran

1. Pusat notifikasi di dalam aplikasi: ikon lonceng + angka jumlah notifikasi yang
   belum dibaca, dan panel kecil berisi daftar notifikasi saat lonceng diketuk.
2. Notifikasi dibuat pada tiga momen pesanan: pesanan dibuat, pesanan sedang diantar
   kurir, dan pesanan selesai.
3. Angka di lonceng hilang setelah panel dibuka (dianggap terbaca).
4. Notifikasi singkat (berhasil/gagal) bisa ditutup dengan menggeser ke samping atau
   ke bawah.
5. Tanda centang pada chip filter terlihat jelas saat chip dipilih.
6. Animasi halus pada interaksi dan perubahan tampilan: panel lonceng membesar dari
   kecil ke ukuran penuh, badge angka ikut membesar/mengecil, toast masuk dan keluar
   dengan geser halus, dan hasil daftar ikut beranimasi saat filter/pencarian berubah.
7. Splash memakai animasi `assets/splash/splash-warung-nusantara.gif`.
8. Artefak rilis (non-debug): APK release + web release.

## 3. Bukan sasaran

- Tidak ada notifikasi sistem/OS: tidak memakai `flutter_local_notifications`, tidak ada
  notifikasi saat aplikasi ditutup atau di latar belakang.
- Notifikasi tidak disimpan antar-restart aplikasi (in-memory, sama seperti store lain).
- Tab utama tetap instan (`IndexedStack` dipertahankan); tidak ada animasi perpindahan tab.
- Tidak menyentuh logika keranjang, harga, voucher, alamat, atau pembayaran.

## 4. Anti-sasaran (gagal walaupun secara teknis jalan)

- Animasi yang menahan pengguna: tidak ada animasi yang memperlambat navigasi atau
  menahan aksi, kecuali splash yang memang tontonan.
- Timer menggantung: tidak boleh ada timer yang masih hidup setelah alur selesai di
  lingkungan tes (penyebab tes gagal).
- Mengubah token desain yang sudah ada (warna, radius, ukuran sentuh minimal 44×44).

## 5. Batasan

- Flutter/Dart, data mock lokal tanpa API.
- Pola store: `ChangeNotifier` singleton in-memory.
- Semua teks Indonesia singkat dan mudah; pesan negatif selalu menyertakan solusi.
- 8 tes widget yang ada harus tetap hijau; `flutter analyze` harus bersih.

## 6. Keputusan kamu (dari percakapan ini)

- Notifikasi ada di dalam aplikasi: lonceng, angka belum dibaca, dan panel kecil berisi
  daftar notifikasi saat lonceng diketuk.
- Angka pada lonceng hilang ketika panel dibuka.
- Notifikasi singkat dapat digeser ke bawah atau ke samping untuk ditutup.
- Tanda centang pada filter harus terlihat (masalah kontras).
- Animasi ditambahkan ke semua interaksi/perubahan tampilan, contoh: panel lonceng
  membesar dari kecil, dan animasi saat mengubah filter.
- Splash memakai GIF yang sudah ditaruh di `assets/splash/`.
- Build non-debug supaya tidak lag.

## 7. Keputusan saya (silakan dicek, ini yang paling mudah salah)

- **R1 — cara "diantar" terjadi (paling berkonsekuensi):** status pesanan bertambah satu
  tahap. 'Sedang dimasak' → otomatis setelah 30 detik → 'Diantar kurir' → pengguna
  mengetuk "Pesanan sudah diterima" → 'Selesai'. Notifikasi muncul di tiga momen itu.
  Cara ini dipilih karena tidak menambah tombol di layar dan tetap mempertahankan
  konfirmasi manual yang sudah ada. Alternatif yang saya tinggalkan: tombol "Simulasi
  kurir" di halaman lacak. Biaya bila salah: notifikasi "diantar" muncul tanpa pengguna
  melakukan apa pun, dan alur terasa butuh ~30 detik.
- **R2 — timer tidak menggantung:** timer otomatis hidup di dalam `OrderStore` (singleton),
  jadi tetap berjalan walaupun pengguna berpindah halaman atau tab — itu justru inti
  fiturnya (pengguna tidak sedang membuka halaman Lacak saat status berubah). Timer
  hanya dibatalkan saat pesanan selesai, saat store dibersihkan (`kosongkan()`, dipakai
  `setUp` tes), dan saat aplikasi uji berakhir. Durasi auto-advance diletakkan sebagai
  satu konstanta agar bisa diperpendek di tes. Biaya bila salah: notifikasi "diantar"
  tidak muncul kalau timer ikut mati saat pengguna pindah halaman.
- **R3 — letak lonceng:** di app bar yang sama dengan ikon keranjang (Beranda, Menu,
  Pesanan) memakai satu widget yang dipakai ulang, supaya selalu terjangkau.
  Biaya bila salah: lonceng muncul di tiga tempat, bukan satu.
- **R4 — panel:** `OverlayEntry` + animasi skala 0,85 → 1,0 dan fade, ~180 ms, menutup
  saat menyentuh area luar, dan beranimasi mengecil dulu sebelum dilepas.
  Biaya bila salah: panel terasa sedikit lambat (180 ms).
- **R5 — splash:** latar splash disamakan dengan warna latar GIF yaitu `#165630`
  (hasil sampel sudut gambar; hampir sama dengan primary `#14532D`) supaya GIF menyatu
  tanpa kotak terlihat. Teks "Warung Nusantara" yang sekarang statis dihapus karena
  frame akhir GIF sudah memuat logo + nama. Splash tampil 3 detik (durasi GIF), lalu
  berpindah setelah pemeriksaan sesi selesai. Biaya bila salah: peluncuran terasa 1
  detik lebih lama daripada sekarang.
- **R6 — penyimpanan:** notifikasi in-memory saja (hilang saat aplikasi ditutup),
  konsisten dengan store lain. Biaya bila salah: notifikasi lama tidak muncul lagi
  setelah aplikasi dibuka ulang.
- **R7 — animasi daftar:** saat filter/pencarian berubah, daftar hasil berganti dengan
  cross-fade 200 ms (bukan animasi posisi), supaya tetap ringan di daftar panjang.
  Biaya bila salah: transisi terasa sederhana, bukan mewah.

## 8. Rancangan teknis

### 8.0 Keputusan yang saya ambil setelah pemeriksaan independen (silakan dicek)

- **P1 — tes boleh disesuaikan, perilakunya tidak boleh hilang.** "8 tes lama tetap
  hijau" saya artikan sebagai *perilaku yang diuji tetap benar*, bukan berkasnya beku.
  Dua tes akan disentuh secara minimal: (a) "Checkout membuat pesanan..." sekarang
  meninggalkan pesanan yang masih berjalan, sehingga timer 30 detik masih hidup saat
  tes berakhir dan tes akan gagal — tes itu akan membersihkan timer lewat `kosongkan()`
  di akhir (atau memakai durasi pendek), dan (b) tes splash mengubah pemeriksaan teks
  menjadi pemeriksaan aset GIF (lihat P2). Biaya bila salah: dua tes milik saya sendiri
  berubah bentuk walau maksud pengujiannya tetap sama.
- **P2 — splash tidak lagi menampilkan teks statis, tetapi tetap dikenali pembaca
  layar.** Teks "Warung Nusantara" yang sekarang duplikat dengan frame akhir GIF akan
  dihapus dari tampilan, diganti `Semantics(label: 'Warung Nusantara')` supaya aksesibilitas
  tetap terjaga. Tes splash memeriksa `Image` dengan aset
  `assets/splash/splash-warung-nusantara.gif`. Biaya bila salah: satu tes harus berubah
  dan nama warung di splash bersifat gambar (bukan teks yang bisa dicari).
- **P3 — halaman Lacak pesanan ikut disesuaikan (masuk lingkup).** Kalau tidak, halaman
  itu akan menampilkan "Sedang dimasak" sementara notifikasi berkata "diantar kurir".
  Pemetaan status → tahap linimasa: 'Sedang dimasak' → tahap 2 (berjalan),
  'Diantar kurir' → tahap 3 (berjalan), 'Selesai' → kelima tahap selesai. Kartu status
  berbunyi "Pesanan sedang diantar" saat 'Diantar kurir', dan jam pada tahap yang sudah
  berjalan ikut ditampilkan. Biaya bila salah: satu berkas tambahan tersentuh.

### 8.1 Store notifikasi — `lib/state/notification_store.dart` (baru)

- `AppNotification { id, judul, isi, waktu, tipe, dibaca }`, `waktuRingkas` untuk
  tampilan ("baru saja", jam).
- Singleton `NotificationStore` (`ChangeNotifier`): `tambah(AppNotification)`,
  `tandaiSemuaDibaca()`, `jumlahBelumDibaca`, `semua`, `kosongkan()`.
- Dipanggil dari: pembuatan pesanan di checkout, transisi ke 'Diantar kurir', dan
  saat 'Selesai'.

### 8.2 Status pesanan — `lib/state/order_store.dart`

- `OrderData.status` tetap dipakai; nilai yang dikenal: 'Sedang dimasak',
  'Diantar kurir', 'Selesai'.
- Tambahan: `ubahStatus(String id, String status)` (menghasilkan `OrderData` baru),
  `selesaikan(id)` (tetap ada, sekarang memanggil `ubahStatus`), dan penjadwalan
  otomatis: saat `tambah()` dipanggil, jadwalkan `Timer(30 detik)` → 'Diantar kurir'.
- `Map<String, Timer> _timer` dibatalkan pada `selesaikan()`, `kosongkan()`, dan
  `dispose()`. Satu fungsi kecil `_catatNotifikasi` supaya teks notifikasi tidak
  tersebar dan tidak dobel.
- Durasi auto-advance diletakkan pada satu konstanta publik (`OrderStore.durasiDiantar`,
  bawaan 30 detik) supaya bisa diperpendek di tes tanpa mengubah kode produksi.
- Pemetaan status ke tahap linimasa (lihat P3) ditaruh di `order_store.dart` sebagai
  `int get tahapAktif` pada `OrderData`, supaya halaman Lacak dan notifikasi memakai
  sumber yang sama dan tidak bisa saling bertentangan.

### 8.3 Lonceng — `lib/widgets/notification_bell.dart` (baru)

- Meniru `cart_icon_button.dart`: `AnimatedBuilder` atas `NotificationStore`, badge
  angka dengan `AnimatedScale`/`AnimatedSwitcher` saat jumlah berubah, `tooltip`
  "Notifikasi", ketuk → buka panel.

### 8.4 Panel — `lib/widgets/notification_panel.dart` (baru)

- `OverlayEntry` dengan penghalang transparan layar penuh (ketuk untuk menutup).
- Animasi `ScaleTransition` (0,85 → 1,0, `Alignment.topRight`) + `FadeTransition`,
  180 ms, `Curves.easeOutCubic`; saat menutup, animasi dibalik dulu, baru dihapus.
- Posisi ditentukan dari `RenderBox` lonceng yang diketuk.
- Saat panel dibuka → `tandaiSemuaDibaca()`.
- Keadaan kosong memakai `EmptyState` yang sudah ada; daftar memakai gaya kartu
  (radius 18, latar putih) dan tiap item menampilkan judul, isi, dan waktu.

### 8.5 Toast bisa digeser — `lib/core/messages.dart`

- Isi toast dipecah menjadi `StatefulWidget` dengan `AnimationController`:
  masuk (geser 12 px + fade 180 ms), saat digeser posisi mengikuti jari
  (samping atau bawah), saat dilepas: jika melewati ambang (40% lebar/tinggi atau
  kecepatan > 400 px/s) → animasi keluar lalu `OverlayEntry` dihapus; jika tidak →
  kembali ke posisi semula dengan `Curves.easeOut`.
- Menggeser membatalkan timer durasi tampil (tetap 4 detik).
- Perilaku lama dipertahankan: notifikasi baru menimpa yang lama, tidak menutupi bar
  aksi bawah.

### 8.6 Chip filter — `menu_page.dart`, `home_page.dart`, `detail_menu_page.dart`

- Tambah `checkmarkColor: Colors.white` pada setiap `ChoiceChip` yang dipilih dengan
  latar hijau, dan samakan `labelPadding` supaya label tidak bergeser saat centang
  muncul.

### 8.7 Animasi lain

- Hasil filter/pencarian: `AnimatedSwitcher` 200 ms (cross-fade) pada area daftar.
- Badge keranjang dan lonceng: `AnimatedScale`/`AnimatedSwitcher` saat jumlah berubah.
- Kartu menu: masuk dengan fade + geser 8 px saat daftar berubah, tanpa mengorbankan
  kinerja gulir (tanpa animasi per item pada daftar panjang).

### 8.8 Splash — `pubspec.yaml` + `lib/features/splash/splash_page.dart`

- Daftarkan `assets/splash/` pada bagian `assets`.
- `Image.asset('assets/splash/splash-warung-nusantara.gif')`, lebar maksimum 260,
  `BoxFit.contain`, latar `#165630`, `errorBuilder` → ikon lingkaran lama (jaring
  pengaman bila aset gagal dimuat), dan `frameBuilder` untuk fade-in halus.
- Durasi: tunggu `max(3 detik, pemeriksaan sesi)` lalu navigasi seperti sekarang.

## 9. Bukti yang akan dijalankan

- Tes widget baru: notifikasi bertambah saat pesanan dibuat dan saat selesai; angka
  belum dibaca hilang setelah lonceng dibuka dan panel terlihat; toast dapat ditutup
  dengan geser; `checkmarkColor` chip berwarna putih; splash memuat aset GIF.
- Tes tambahan untuk R1/P3: setelah waktu auto-advance dilewati, status menjadi
  'Diantar kurir', notifikasi "diantar" muncul, dan halaman Lacak menampilkan
  "Pesanan sedang diantar" beserta tahap linimasa yang benar.
- 8 tes lama tetap hijau, `flutter analyze` bersih.
- `flutter build apk --release` dan `flutter build web --release`, lalu memastikan
  bundel benar-benar memuat teks notifikasi dan aset GIF.

## 10. Risiko dan penanganannya

| Risiko | Penanganan |
|---|---|
| Timer otomatis membuat tes gagal (timer tersisa) | R2: timer dibatalkan saat selesai/bersih, durasi dapat diatur agar tes memakai waktu pendek |
| GIF 480×480 di layar besar kelihatan kecil/kotak | Latar disamakan `#165630` + `BoxFit.contain` |
| Animasi membuat daftar panjang patah-patah | Hanya cross-fade di tingkat daftar, bukan animasi tiap item |
| Panel lonceng bisa tertinggal setelah pindah halaman | Panel ditutup saat rute berubah (`NavigatorObserver`/`dispose`) |