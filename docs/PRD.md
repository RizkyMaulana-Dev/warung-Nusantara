# PRD — Aplikasi Pemesanan Makanan UMKM ("Warung Nusantara")

Versi 1.0 · Platform: mobile (Android/iOS) · Bahasa antarmuka: Indonesia
Nama "Warung Nusantara", alamat, menu, harga, dan nama pengguna di dokumen ini adalah **contoh** dan harus diganti dengan data UMKM asli.

## 1. Ringkasan
Aplikasi pemesanan makanan untuk satu UMKM kuliner. Pelanggan melihat menu, memesan, membayar, dan melacak pesanan tanpa harus menghubungi penjual lewat chat.

## 2. Tujuan
1. Pelanggan bisa memesan dalam kurang dari 2 menit dari membuka aplikasi sampai bayar.
2. Penjual menerima pesanan yang rapi (menu, catatan, alamat, pembayaran) dan tidak perlu mencatat manual.
3. Pelanggan bisa melihat status pesanan sampai tiba.

Target ukuran keberhasilan (usulan, sesuaikan dengan kondisi usaha):
- Pesanan selesai dibayar dibanding keranjang yang dibuat: ≥ 60%.
- Waktu dari menu pertama ditambah ke keranjang sampai bayar: ≤ 2 menit.
- Pelanggan yang memesan ulang dalam 30 hari: ≥ 30%.

## 3. Pengguna
| Peran | Kebutuhan utama |
|---|---|
| Pelanggan | Memilih menu, mengatur level pedas dan tambahan, membayar, melacak pesanan |
| Pemilik UMKM (di luar cakupan desain ini) | Menerima dan mengonfirmasi pesanan, mengatur menu dan stok |

Dokumen ini hanya mencakup **aplikasi pelanggan**. Panel pemilik/admin perlu PRD terpisah.

## 4. Cakupan
**Masuk cakupan v1:** onboarding, login, katalog menu, detail menu dengan opsi, keranjang, checkout (alamat dan pembayaran), pelacakan status pesanan, profil, pengaturan.
**Belum didesain (diusulkan v1.1):** Daftar akun, Pencarian dan Filter, Riwayat Pesanan, Peta Kurir, Tambah Kartu/Metode Bayar, Voucher, Ulasan.
**Di luar cakupan:** chat dengan penjual, program reseller, multi-cabang.

## 5. Alur Utama
```
Splash ─► Welcome ─► Login ─► Beranda ─► Detail Menu ─► Keranjang ─► Checkout ─► Lacak Pesanan
                         │         │            │
                         │         ├─► Menu (daftar penuh) ─► Detail Menu
                         │         ├─► Pesanan (riwayat dan status aktif) ─► Lacak Pesanan
                         │         └─► Akun ─► Pengaturan
                         └─► (Daftar, v1.1)
```
Alur pemesanan: pilih menu → atur opsi → tambah ke keranjang → ubah jumlah → pilih alamat → pilih pembayaran → bayar → lacak.
Pengguna yang sudah login langsung masuk ke Beranda setelah Splash (Welcome dan Login dilewati).

## 6. Detail Tiap Halaman
Ukuran kanvas desain: 390 × 844 px. Nama file mengacu ke artboard di kanvas desain.

### 6.1 Splash (`Splash.dc.html`)
- **Tujuan:** menampilkan identitas saat aplikasi dimuat.
- **Elemen:** logo (lingkaran 96 px berisi ikon mangkuk), nama usaha di tengah.
- **Perilaku:** tampil 1,5–2 detik sambil memeriksa sesi login. Tanpa tombol.
- **Navigasi:** sesi valid → Beranda. Tidak ada sesi → Welcome.
- **Kondisi khusus:** tanpa internet tetap lanjut ke Welcome/Login; tampilkan pesan saat butuh data.

### 6.2 Welcome (`Welcome.dc.html`)
- **Tujuan:** pengenalan singkat bagi pengguna baru.
- **Elemen:** ilustrasi piring di panel atas, indikator halaman (3 titik), judul "Selamat datang di Warung Nusantara", paragraf singkat, tombol "Lanjut".
- **Perilaku:** geser kiri/kanan untuk berpindah slide; tombol "Lanjut" pindah slide, dan di slide terakhir menuju Login.
- **Kondisi khusus:** hanya tampil pertama kali aplikasi dibuka.

### 6.3 Login (`Login.dc.html`)
- **Elemen:** tombol kembali, judul "Selamat datang kembali", kolom "Email atau nomor HP", kolom "Kata sandi", kotak centang "Simpan kata sandi", tautan "Lupa kata sandi?", tombol "Masuk", tombol "Google", tautan "Daftar".
- **Validasi:** kolom wajib diisi; email/nomor HP harus format benar; kata sandi minimal 8 karakter.
- **Status:** tombol "Masuk" menampilkan indikator muat saat proses; pesan galat di bawah kolom jika gagal ("Email atau kata sandi salah").
- **Navigasi:** berhasil → Beranda; "Daftar" → Daftar (v1.1).

### 6.4 Beranda (`Main.dc.html`)
- **Tujuan:** jalan pintas ke menu populer.
- **Elemen:** judul "Pesan Makan Favoritmu", tombol cari (lingkaran 48 px), chip kategori (Nasi, Ayam, Minuman, Camilan), judul "Menu Populer" dengan tautan "Lihat semua", grid kartu menu 2 kolom, bar navigasi bawah.
- **Kartu menu:** gambar, nama, takaran, harga, tombol tambah cepat.
- **Perilaku:** chip memfilter grid; ketuk kartu → Detail Menu; ketuk tombol tambah → masuk keranjang dengan opsi bawaan dan tampilkan konfirmasi singkat.
- **Kondisi khusus:** menu habis tampil dengan label "Habis" dan tombol tambah nonaktif; daftar kosong menampilkan teks "Menu belum tersedia."

### 6.5 Menu (`Menu.dc.html`)
- **Tujuan:** daftar menu lengkap per kategori.
- **Elemen:** judul, kolom cari, chip kategori, grid 2 kolom, bar keranjang melayang ("2 item · Rp 42.000" + "Lihat keranjang"), navigasi bawah.
- **Perilaku:** bar keranjang hanya muncul jika keranjang tidak kosong; ketuk → Keranjang.
- **Catatan desain:** layar ini masih memakai gaya lama dan perlu diselaraskan.

### 6.6 Detail Menu (`Detail.dc.html`)
- **Elemen:** gambar menu (area 330 px), tombol kembali, nama, status ketersediaan, stepper jumlah, deskripsi, ulasan, bar bawah (harga dan tombol "Tambah ke keranjang").
- **Opsi pesanan (v1.1):** level pedas (Tidak pedas, Sedang, Pedas), tambahan (telur dadar +Rp 4.000, tempe +Rp 3.000), catatan untuk penjual.
- **Perilaku:** harga di bar bawah berubah mengikuti jumlah dan tambahan; tombol "Tambah ke keranjang" lalu kembali ke halaman sebelumnya dengan konfirmasi.
- **Kondisi khusus:** menu habis → tombol nonaktif dengan teks "Habis".

### 6.7 Keranjang (`Keranjang.dc.html`)
- **Elemen:** tombol kembali, judul, daftar item (gambar, nama, catatan opsi, harga, stepper), baris ongkir, bar bawah (total dan tombol "Checkout").
- **Perilaku:** stepper mengubah jumlah; jumlah 0 menghapus item (minta konfirmasi); total dihitung ulang langsung.
- **Kondisi khusus:** keranjang kosong menampilkan "Keranjangmu masih kosong" dan tombol "Lihat Menu".
- **Aturan:** minimal belanja ditentukan UMKM (contoh promo gratis ongkir: Rp 50.000).

### 6.8 Checkout (`Checkout.dc.html`)
- **Elemen:** header "Checkout", bagian Alamat (Rumah, Kantor, "Tambah baru"), bagian Pembayaran (QRIS, Transfer bank, Bayar di tempat), bar bawah (total pembayaran dan tombol "Bayar").
- **Perilaku:** satu alamat dan satu metode pembayaran wajib terpilih; "Bayar" membuat pesanan lalu menuju Lacak Pesanan.
- **Pembayaran:** QRIS menampilkan kode QR dan batas waktu bayar; Bayar di tempat langsung membuat pesanan berstatus "Menunggu konfirmasi".
- **Kondisi khusus:** pembayaran gagal atau kedaluwarsa → pesan jelas dan opsi coba lagi; pesanan tidak dibuat.

### 6.9 Lacak Pesanan (`Pelacakan.dc.html`)
- **Elemen:** header "Detail Pesanan", linimasa 5 tahap (Pesanan dibuat, Dikonfirmasi, Sedang dimasak, Diantar kurir, Pesanan tiba) dengan jam tiap tahap, tombol "Lihat posisi kurir".
- **Perilaku:** tahap selesai diberi tanda centang, tahap berjalan diberi warna aksen, tahap berikutnya berupa lingkaran kosong; status diperbarui otomatis (polling atau push).
- **Kondisi khusus:** pesanan dibatalkan penjual → tampilkan alasan dan info pengembalian dana.

### 6.10 Akun / Profil (`Profil.dc.html`)
- **Elemen:** avatar dan nama, nomor HP, tombol "Ubah", kartu poin loyalitas dengan tombol "Tukar", daftar menu (Alamat tersimpan, Riwayat pesanan, Voucher dan promo, Metode pembayaran, Pusat bantuan, Pengaturan), tombol "Keluar".
- **Perilaku:** "Keluar" meminta konfirmasi lalu kembali ke Login.
- **Catatan:** program poin bersifat opsional; hapus kartu jika UMKM tidak memakainya.

### 6.11 Pengaturan (`Pengaturan.dc.html`)
- **Elemen:** saklar Notifikasi (Status pesanan, Promo dan voucher), Tampilan (Bahasa, Mode gelap), Keamanan dan info (Ubah kata sandi, Syarat dan ketentuan, Kebijakan privasi), versi aplikasi.
- **Perilaku:** saklar tersimpan seketika; notifikasi status pesanan aktif secara bawaan.

## 7. Kebutuhan Fungsional
| ID | Kebutuhan | Prioritas |
|---|---|---|
| F1 | Login email/nomor HP dan sandi; sesi tersimpan | Wajib |
| F2 | Katalog menu dengan kategori, harga, ketersediaan | Wajib |
| F3 | Keranjang: tambah, ubah jumlah, hapus, hitung total | Wajib |
| F4 | Opsi menu (level pedas, tambahan, catatan) | Wajib |
| F5 | Checkout dengan pilihan alamat dan pembayaran | Wajib |
| F6 | Pembayaran QRIS dan bayar di tempat | Wajib |
| F7 | Status pesanan 5 tahap dengan pembaruan otomatis | Wajib |
| F8 | Notifikasi perubahan status | Wajib |
| F9 | Pencarian dan filter | Sebaiknya |
| F10 | Riwayat pesanan dan pesan ulang | Sebaiknya |
| F11 | Voucher, poin loyalitas | Opsional |
| F12 | Peta posisi kurir | Opsional |

## 8. Kebutuhan Non-Fungsional
- Waktu muat layar utama ≤ 2 detik pada jaringan 4G.
- Seluruh teks kontras minimal 4,5:1 dan target sentuh minimal 44 × 44 px.
- Berfungsi pada layar 360–430 px lebar.
- Data pribadi (nomor HP, alamat) disimpan terenkripsi dan tidak dibagikan ke pihak ketiga tanpa persetujuan.
- Format mata uang Rupiah dengan titik ribuan ("Rp 22.000").

## 9. Entitas Data (ringkas)
- **Pengguna:** id, nama, email/HP, kata sandi (hash), poin.
- **Alamat:** id, pengguna, label, alamat lengkap, patokan.
- **Menu:** id, nama, kategori, harga, deskripsi, foto, tersedia (ya/tidak).
- **Opsi menu:** id, menu, nama, harga tambahan.
- **Pesanan:** id, nomor (mis. WN-0231), pengguna, alamat, metode bayar, status, total, waktu per status.
- **Item pesanan:** pesanan, menu, jumlah, opsi terpilih, catatan, harga satuan.

## 10. Status Pesanan
`dibuat → dikonfirmasi → dimasak → diantar → tiba` dan cabang `dibatalkan`.
Pesanan hanya boleh dibatalkan pelanggan sebelum status "dikonfirmasi".

## 11. Asumsi dan Pertanyaan Terbuka
- Berapa area dan tarif pengantaran, serta siapa yang mengantar (kurir sendiri atau pihak ketiga)?
- Penyedia pembayaran QRIS apa yang dipakai?
- Apakah pesanan bisa dijadwalkan untuk jam tertentu?
- Apakah aplikasi perlu bekerja tanpa login (pesan sebagai tamu)?
