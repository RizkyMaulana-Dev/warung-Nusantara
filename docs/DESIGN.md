# DESIGN.md — Panduan Desain Aplikasi Warung Nusantara

Semua angka dalam piksel (px) pada kanvas 390 × 844. Nilai ini sama dengan yang dipakai di desain, jadi bisa langsung dipindah ke kode (CSS, Flutter, React Native).

## 1. Prinsip
1. **Bersih dan hangat:** latar putih/abu muda, satu warna utama hijau tua, satu aksen kuning kunyit.
2. **Satu aksi utama per layar:** tombol terbesar dan berwarna penuh hanya satu.
3. **Mudah ditekan:** semua target sentuh minimal 44 × 44 px.
4. **Terbaca:** kontras teks minimal 4,5:1.
5. **Bahasa Indonesia sehari-hari,** singkat, tanpa singkatan yang membingungkan.

## 2. Warna
| Token | Hex | Dipakai untuk |
|---|---|---|
| primary | `#14532D` | Tombol utama, chip aktif, header/bar bawah, harga, tautan |
| primary-soft | `#1F6B3B` | Elemen dekoratif di atas primary, tombol sekunder di header |
| primary-tint | `#E7F1EA` | Latar ikon, tombol "Ubah" |
| on-primary-muted | `#BFE3CB` | Teks kecil di atas latar primary |
| accent | `#F59E0B` | Tombol tambah, promo, poin, tahap aktif di linimasa |
| on-accent | `#1B2420` | Teks dan ikon di atas aksen (jangan putih, kontras kurang) |
| text | `#1B2420` | Teks utama |
| text-secondary | `#5B6460` | Teks pendukung, deskripsi, label |
| surface | `#FFFFFF` | Kartu, lembar, latar layar |
| surface-soft | `#F1F3F7` | Latar kartu menu, kolom isian, tombol sekunder |
| background | `#F5F6F3` | Latar layar Menu, Profil, Pengaturan |
| divider | `#E6E9E5` | Garis pemisah (alternatif `#EEF0ED` di dalam kartu) |
| success | `#15803D` | Teks "Tersedia", penghematan |
| error | `#B42318` | Tombol/teks "Keluar", pesan galat |
| badge-bg / badge-text | `#FEF3C7` / `#7A4B00` | Label "Terlaris" |

Aturan: jangan menambah warna baru. Jangan memakai putih di atas `accent`. Status tidak boleh dibedakan dengan warna saja; tambahkan ikon atau teks.

## 3. Tipografi
Font: **Plus Jakarta Sans** (Google Fonts), bobot 400, 500, 600, 700, 800. Cadangan: `system-ui, sans-serif`.

| Gaya | Ukuran | Bobot | Tinggi baris | Letter-spacing | Contoh |
|---|---|---|---|---|---|
| Wordmark | 30 | 800 | 1,2 | −0,6 | Nama di Splash |
| Judul halaman besar (H1) | 28 | 800 | 1,15–1,2 | −0,6 | "Pesan Makan Favoritmu", "Selamat datang kembali" |
| Judul halaman (H1 sedang) | 24 | 800 | 1,2 | −0,4 | "Menu", "Akun", nama di Detail |
| Judul halaman kecil | 22 | 800 | 1,2 | 0 | "Keranjang" |
| Judul header bar | 17 | 700 | 44 (satu baris) | 0 | "Checkout", "Detail Pesanan" |
| Judul bagian (H2) | 17 | 800 | 1,3 | 0 | "Menu Populer" |
| Judul bagian kecil | 15–16 | 800 | 1,3 | 0 | "Deskripsi", "Alamat" |
| Nama menu (kartu grid) | 14 | 700 | 1,3 | 0 | "Ayam Geprek" |
| Nama menu (daftar) | 14–15 | 700 | 1,3 | 0 | di Keranjang |
| Harga | 14 | 800 | 1,2 | 0 | "Rp 22.000" |
| Total (bar bawah) | 20 | 800 | 1,2 | 0 | "Rp 54.000" |
| Teks isi | 13–14 | 400 | 1,55 | 0 | deskripsi, paragraf |
| Teks pendukung | 12 | 400–500 | 1,4 | 0 | takaran, catatan opsi |
| Label kolom isian | 12 | 600 | 1,2 | 0 | "Email atau nomor HP" |
| Teks tombol utama | 15 | 700 | 1 | 0 | "Masuk", "Bayar" |
| Teks chip/tombol kecil | 13 | 600 | 1 | 0 | "Nasi", "Ubah" |
| Label navigasi bawah | 11 | 600 (aktif 800) | 1 | 0 | "Beranda" |
| Keterangan kecil | 11 | 400 | 1,2 | 0 | "Harga", "Total" di bar bawah |

Aturan teks:
- Judul tidak lebih dari 2 baris; nama menu maksimal 2 baris lalu dipotong dengan "…".
- Gunakan huruf besar hanya di awal kalimat dan nama diri (Title Case hanya untuk judul bagian seperti "Menu Populer"). Jangan memakai huruf kapital semua kecuali label bagian kecil di Pengaturan ("NOTIFIKASI", 12/700, text-secondary).
- Rata kiri untuk semua teks isi. Rata tengah hanya untuk Splash, Welcome, dan footer Login.
- Harga: "Rp 22.000" (spasi setelah Rp, titik ribuan). Harga tambahan: "+ Rp 4.000". Potongan: "− Rp 5.000".
- Jam: "09.30" (titik, 24 jam). Takaran: "1 porsi", "1 mangkuk".
- Tombol: 1–3 kata, kata kerja di depan ("Tambah ke keranjang" adalah batas terpanjang).
- Pesan galat: apa yang salah + cara memperbaiki, 1 kalimat, 12/500, warna error.

## 4. Spasi dan Grid
- Skala spasi: 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 36.
- **Margin layar:** 20 kiri dan kanan (24 pada Login dan Welcome). Padding atas konten: 24.
- **Jarak antar bagian:** 14 (kolom vertikal utama). Jarak antar elemen kecil: 6–8.
- **Grid menu:** 2 kolom, jarak 12, tiap kartu lebar ±(390 − 40 − 12) / 2 = 169.
- **Ruang bawah:** konten tidak boleh tertutup bar bawah; sisakan 92 (bar aksi) atau 76 (navigasi) ditambah 16.
- Kolom/area aman: tidak ada status bar palsu; gunakan padding aman bawaan perangkat.

## 5. Bentuk
| Elemen | Radius |
|---|---|
| Tombol utama dan chip | 26 (tinggi 52) / 20 (tinggi 40) |
| Kolom isian, tombol kotak, kartu daftar | 14 |
| Kartu grid menu | 18 |
| Area gambar dalam kartu | 14 |
| Lembar putih di bawah header | 28 (hanya sudut atas) |
| Bar bawah | 24 (hanya sudut atas) |
| Avatar, tombol ikon bulat | 50% |

Bayangan: hampir tidak dipakai. Hanya piring ilustrasi memakai `0 6px 14px rgba(27,38,68,.12)`. Pemisah memakai garis 1 px divider, bukan bayangan.

## 6. Komponen

### 6.1 Tombol
| Jenis | Tinggi | Padding horizontal | Latar | Teks | Radius |
|---|---|---|---|---|---|
| Utama | 52 | 24 | primary | putih 15/700 | 26 |
| Utama di bar hijau | 52 | 24 | putih | primary 15/700 | 26 |
| Sekunder | 52 | 24 | surface-soft | primary 14/700 | 26 |
| Tautan | 44 (area sentuh) | 0 | tanpa | primary 13/700 | – |
| Kecil (Ubah, Tukar, Hubungi) | 40 | 16 | primary-tint / aksen | 13/700 | 20 |
| Ikon bulat/kotak | 44 × 44 | – | surface-soft atau putih | ikon 20 px, stroke 2,2 | 14 atau 50% |
| Tambah cepat | 44 × 44 | – | accent | ikon "+" on-accent, stroke 2,3 | 12 |
Status: *tekan* gelapkan 8%; *nonaktif* opasitas 40% dan tanpa interaksi; *memuat* ganti teks dengan indikator putar 20 px.

### 6.2 Kolom isian
Label di atas (12/600, text-secondary, jarak 6 ke kolom). Kolom: tinggi 52, radius 14, padding horizontal 16, latar surface-soft, tanpa garis tepi, teks 14, placeholder text-secondary. Fokus: garis tepi 2 px primary. Galat: garis tepi 2 px error dan pesan 12 px di bawah (jarak 6). Jarak antar kolom 14.

### 6.3 Chip kategori
Tinggi 40, padding horizontal 18, radius 20, teks 13/600, jarak antar chip 8. Aktif: latar primary, teks putih. Tidak aktif: latar surface-soft, teks `#3A4540`. Boleh digulir horizontal.

### 6.4 Kartu menu (grid)
Latar surface-soft, radius 18, padding 10. Area gambar: tinggi 100, radius 14, latar putih. Di bawahnya: nama (14/700, margin atas 10), takaran (12, text-secondary), baris harga dan tombol tambah (margin atas 6, harga 14/800 primary di kiri, tombol 44 × 44 di kanan). Tinggi total ±200.

### 6.5 Item daftar (keranjang)
Latar surface-soft, radius 16, padding 10, jarak isi 12. Gambar 64 × 64 radius 12. Teks: nama 14/700, opsi 12 text-secondary, harga 14/800 primary. Stepper: tombol 44 × 44 radius 12, angka 14/700 lebar min 14.

### 6.6 Header bar dan lembar
Header: tinggi 104, latar primary, padding 20. Tombol kembali 44 × 44 radius 14 latar primary-soft, ikon putih. Judul 17/700 putih rata tengah. Lembar putih mulai dari y = 84 dengan radius atas 28 dan padding atas 24–28, padding samping 20.

### 6.7 Bar aksi bawah
Tinggi 92, latar primary, radius atas 24, padding horizontal 20, isi sejajar tengah dengan jarak 16. Kiri: keterangan 11 (`#BFE3CB`) di atas nilai 20/800 putih. Kanan: tombol utama putih.

### 6.8 Navigasi bawah
Tinggi 76, latar primary, radius atas 24, 4 item rata sama. Setiap item min 64 × 44, teks 11/600 `#BFE3CB`. Aktif: teks putih 11/800 dengan garis bawah 3 px accent. Urutan tetap: Beranda, Menu, Pesanan, Akun.

### 6.9 Pilihan (radio) dan saklar
Baris radio: tinggi 56, radius 14, latar surface-soft, padding horizontal 14; judul 14/600, keterangan 12/400 text-secondary; radio 20 px accent-color primary. Saklar: lebar 44, tinggi 24; satu baris pengaturan tinggi 52.

### 6.10 Linimasa status
Tiga kolom: jam (lebar 48, 12/600 text-secondary), lingkaran 26 px, teks (judul 14/700, keterangan 12 text-secondary). Jarak antar tahap 22. Selesai: lingkaran primary + centang putih. Berjalan: lingkaran accent + centang on-accent. Berikutnya: lingkaran kosong dengan garis 2 px `#C9D0CB`.

### 6.11 Banner promo
Tinggi 112, radius 20, padding 18 × 20, latar primary dengan lingkaran dekoratif primary-soft dan accent. Label 12/600 `#BFE3CB`, judul 20/800 putih, tombol kecil accent.

### 6.12 Badge
Padding 4 × 10, radius 10, teks 11/700, warna badge-bg/badge-text.

### 6.13 Ikon
Gaya garis (stroke), ukuran 20 (16 untuk ikon sebaris dengan teks), stroke 2–2,3, ujung bulat. Ikon dekoratif diberi `aria-hidden`, ikon tombol tanpa teks wajib punya label ("Kembali", "Tambah", "Cari").

## 7. Cara Menambah Teks atau Elemen Baru
Ikuti urutan ini setiap kali menambah teks atau komponen.
1. **Tentukan perannya:** judul, isi, pendukung, harga, atau tombol. Pakai gaya dari tabel tipografi, jangan membuat ukuran baru.
2. **Pilih warna:** teks utama `text`; pendukung `text-secondary`; di atas hijau pakai putih atau `#BFE3CB`; di atas kuning pakai `#1B2420`.
3. **Pasang jarak:** jarak ke elemen sebelumnya 14 (antar bagian) atau 6–8 (antar baris teks yang berkaitan).
4. **Batasi panjang:** judul ≤ 2 baris, deskripsi ≤ 3 baris (lalu "…"), tombol 1–3 kata.
5. **Hitung tinggi:** pastikan elemen yang bisa ditekan ≥ 44 px dan tidak tertutup bar bawah.
6. **Beri keadaan:** untuk elemen interaktif tentukan normal, tekan, nonaktif, memuat, dan galat.
7. **Uji kontras:** teks 11–13 px wajib 4,5:1; judul 24 px ke atas minimal 3:1.
8. **Tulis dalam Bahasa Indonesia** dengan format harga dan jam di bagian 3.

Contoh menambah teks "Estimasi tiba 25 menit" di kartu status: gaya Teks pendukung (12/400), warna text-secondary, jarak 4 di bawah judul status, rata kiri, satu baris.

## 8. Pola Layar
| Pola | Dipakai di | Struktur |
|---|---|---|
| Layar penuh polos | Splash, Welcome, Login, Beranda, Keranjang | Latar putih, padding 24/20, konten mengalir ke bawah |
| Header + lembar | Checkout, Detail Pesanan | Header 104 hijau, lembar putih radius 28 dari y = 84, bar aksi di bawah |
| Gambar + lembar | Detail Menu | Area gambar 330 abu muda, lembar putih mulai y = 300, bar aksi 92 |
| Latar abu | Menu, Profil, Pengaturan | Latar background, kartu putih radius 18 |

Status layar yang wajib ada saat implementasi: memuat (kerangka abu), kosong (ikon + 1 kalimat + 1 tombol), galat jaringan (pesan + "Coba lagi"), dan tanpa internet.

## 9. Gerak
Durasi 150–250 ms, kurva ease-out. Tekan tombol: skala 0,97. Perpindahan layar: geser horizontal 250 ms. Lembar: naik dari bawah 250 ms. Hindari animasi dekoratif yang berulang. Hormati pengaturan "kurangi gerakan" perangkat.

## 10. Aksesibilitas
- Target sentuh ≥ 44 × 44 px; jarak antar target ≥ 8.
- Semua tombol berupa `button`, tautan berupa `a`; kolom isian punya `label`.
- Ikon tombol punya label teks alternatif.
- Jangan memakai warna sebagai satu-satunya penanda status.
- Dukung ukuran teks besar dari pengaturan sistem sampai 130% tanpa teks terpotong.

## 11. Catatan Status Desain
Layar Menu, Profil, dan Pengaturan masih memakai tata letak versi awal (kartu putih di atas latar abu, navigasi bawah terang). Warnanya sudah sama, tetapi untuk konsistensi penuh, ubah ke pola header hijau + lembar putih dan navigasi bawah hijau seperti layar lain.
