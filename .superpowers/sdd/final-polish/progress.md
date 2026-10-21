# SDD ledger — plan: ringkasan checkpoint sesi "lanjutan" (tidak ada berkas rencana formal)

Pre-flight: tidak ada berkas rencana formal di repo; rencana diambil dari ringkasan
checkpoint sesi. Folder kerja bukan git repo -> tidak ada worktree/commit, jadi bukti
kemajuan disimpan sebagai perintah verifikasi + keluarannya, bukan hash commit.

## Task 1: Gambar pisang goreng pindah ke Wikimedia Commons

- Tebakan jalur thumb (`thumb/e/ea/...`) salah: HEAD -> 400. API Commons menunjukkan
  jalur benar `8/8c` dan ukuran asli 1024x768.
- Task 1: Ruling: pakai URL asli tanpa thumb 1200px — Commons mengembalikan thumburl
  *unscaled* karena gambar asli hanya 1024x768 — biaya bila salah: gambar dirender
  1024px, ukuran ini sudah memadai untuk kartu & banner.
- Verifikasi: GET dengan User-Agent + Range -> 206 image/jpeg. (429 sebelumnya adalah
  rate limit untuk HEAD tanpa User-Agent, bukan URL salah.)
- Task 1: complete (refs diperbarui di menu + banner; bukti HTTP 206 image/jpeg)

## Task 2: url_launcher + tombol WhatsApp di Pusat Bantuan (TDD)

- RED dijalankan terhadap tombol versi lama (salin nomor saja):
  `Chat WhatsApp membuka tautan wa.me` -> `Expected: length <1>, Actual: []`
  `Chat WhatsApp menyalin nomor...` -> `Found 0 widgets`
- GREEN setelah implementasi: 2/2 lulus.
- Task 2: Ruling: `launchUrl` menggantung di lingkungan flutter test (kanal platform
  tidak pernah membalas, jadi tidak ada cabang sukses maupun catch yang jalan) — tes
  mem-mock kanal `plugins.flutter.io/url_launcher` metode `launch`; biaya bila salah:
  tes menguji jalur tiruan, bukan perangkat asli (jalur asli diverifikasi lewat build
  web + pemeriksaan argumen URL di tes).
- Task 2: Ruling: cukup `launchUrl` tanpa `<queries>` di AndroidManifest — `queries`
  hanya wajib untuk `canLaunchUrl`; biaya bila salah: tombol tidak membuka WhatsApp di
  Android 11+ dan cukup ditambah satu blok `<queries>`.
- Task 2: complete (`AppMessages.gagalBukaWhatsApp`, `PusatBantuanPage._chatWhatsApp`
  dengan fallback salin nomor)

## Task 3: format + analyze + seluruh tes

- `dart format lib test` -> 0 changed; `flutter analyze` -> No issues found;
  `flutter test` -> 8/8 lulus.

## Task 4: artefak rilis

- `flutter build web --release` -> exit 0, `build/web` terisi.
- `flutter build apk --debug` -> lihat hasil di akhir.

## Task 5: verifikasi alur ujung-ke-ujung

- Tes `Pesanan selesai pindah ke riwayat`: keranjang -> checkout -> bayar -> lacak ->
  `Pesanan sudah diterima` -> Akun -> Riwayat, lulus (status `selesai` benar, nomor
  pesanan muncul di riwayat).

## Task 6: review konteks-baru (subagen `ses_ea22c0263ffeyCpYH8QxQExEEe`)

Temuan setelah dinilai ulang berdasarkan dampak ke pengguna:

- Final: fixed lisensi gambar — gambar sebelumnya CC BY-SA 2.0 (wajib atribusi) dipakai
  tanpa atribusi di UI. Diganti `Pisang_Goreng_Hangat.jpg` yang CC0/public domain
  (terverifikasi lewat API extmetadata `LicenseShortName: CC0`, `UsageTerms: Creative
  Commons Zero, Public Domain Dedication`) -> kewajiban atribusi hilang, sekaligus foto
  lebih layak (makanan memenuhi bingkai, bukan pisang tiris di jalan).
  Verifikasi: thumb 500px & 960px -> HTTP 200/206 image/jpeg. Suite 8/8 hijau.
- Final: fixed pesan cadangan tidak jujur/tidak terpakai — `gagalBukaWhatsApp` dulu
  menyuruh "tempel di kolom chat WhatsApp" padahal cabang itu jalan justru saat WhatsApp
  tidak bisa dibuka. Sekarang: `WhatsApp tidak bisa dibuka. Nomor sudah disalin, buka
  WhatsApp Web atau telepon warung.` Penyalinan nomor juga di-`await` sebelum pesan
  muncul supaya klaim "sudah disalin" benar. Verifikasi: tes
  `Chat WhatsApp menyalin nomor dan memberi solusi saat gagal` RED (teks lama tidak
  ketemu) -> GREEN, kini juga mem-mock `SystemChannels.platform` dan memastikan
  `Clipboard.setData` benar-benar dipanggil dengan `+62 812-3456-7890`.
- Final: Ruling penting #1 (fallback jarang tercapai): tetap satu kali `launchUrl` ke
  `https://wa.me/...` dan tidak menambah rantai `whatsapp://` + `canLaunchUrl` — tautan
  https selalu bisa dibuka browser (WhatsApp Web tetap jalan), dan rantai itu tidak
  mengubah apa yang dilihat pengguna, hanya menambah kode; biaya bila salah: pengguna
  tanpa WhatsApp mendarat di WhatsApp Web, bukan diarahkan di dalam aplikasi (masih wajar).
- Final: fixed dokumen usang — komentar berkas `menu_data.dart` tidak lagi mengklaim
  semua gambar Unsplash; menyebut Unsplash + Wikimedia Commons CC0.

Final: minor (deferred) yang tidak dikerjakan:
- Tombol `Chat WhatsApp` tidak punya keadaan pending/disabled; ketukan berulang
  mengantre beberapa `launchUrl` dan beberapa toast.
- `AppImage` tidak menetapkan `cacheWidth/cacheHeight`; ukuran dekode mengikuti berkas
  (fetch sudah dikecilkan lewat thumb 500/960px).
- Nama menu "Pisang Goreng Keju" sementara foto menampilkan pisang goreng polos
  (keju adalah addon, jadi masih masuk akal).
- `_salin` (salin email) masih menembak `Clipboard.setData` tanpa di-`await`; hanya jalur
  WhatsApp yang di-`await`.
- Tombol email memakai salin-ke-papan klip, bukan membuka `mailto:`.