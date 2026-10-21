# Notifikasi dalam aplikasi, animasi halus, splash animatif — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambahkan pusat notifikasi dalam aplikasi (lonceng + angka belum dibaca + panel beranimasi), feedback yang bisa digeser, perbaikan kontras centang filter, animasi halus pada perubahan tampilan, dan splash animatif dari GIF, lalu menghasilkan build release.

**Architecture:** Notifikasi hidup di store in-memory baru (`NotificationStore`) yang diisi `OrderStore` pada tiga momen pesanan. Status pesanan bertambah satu tahap ('Diantar kurir') yang dijadwalkan `Timer` di dalam store, dengan durasi satu konstanta agar bisa diperpendek di tes. Panel lonceng dan toast memakai `OverlayEntry` + `AnimationController` supaya animasi skala/geser mulus dan tidak memblokir.

**Tech Stack:** Flutter/Dart, `ChangeNotifier` singleton, `OverlayEntry`, `AnimationController`, `google_fonts` (Plus Jakarta Sans, sudah dibundel), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-10-21-notifikasi-splash-animasi-design.md`

## Global Constraints

- Data tetap mock lokal; tanpa API, tanpa `flutter_local_notifications`, tanpa notifikasi OS.
- Token desain tidak berubah: primary `#14532D`, accent `#F59E0B`, ukuran sentuh minimal 44×44, radius kartu 18, radius tombol 26.
- Semua teks Indonesia singkat; pesan negatif selalu menyertakan solusi.
- Tab utama tetap instan (`IndexedStack` dipertahankan, tanpa animasi perpindahan tab).
- Store tetap singleton `ChangeNotifier` in-memory (notifikasi tidak disimpan antar-restart).
- Tidak ada timer yang masih hidup di akhir tes.
- Folder ini **bukan git repo**: langkah commit diganti langkah verifikasi + catatan ledger di `.superpowers/sdd/final-polish/progress.md`.
- `flutter analyze` harus bersih; seluruh tes (8 lama + baru) harus hijau.

## Review Focus

1. Pesanan dibiarkan aktif lalu store dibersihkan → timer 30 detik tidak boleh menembak setelahnya.
2. Panel lonceng dibiarkan terbuka lalu pengguna berpindah halaman → panel tidak boleh tertinggal di layar.
3. Daftar notifikasi panjang (mis. 12 item) dan skala teks 1,3 → panel tetap bisa digulir, tanpa overflow.
4. Toast baru datang saat toast lama sedang digeser → tetap hanya satu toast, tanpa overlay menggantung.
5. Pengguna membuka panel lonceng berulang kali dengan cepat → angka belum dibaca tidak muncul kembali dan tidak ada panel ganda.

---

### Task 1: Store notifikasi

**Files:**
- Create: `lib/state/notification_store.dart`
- Test: `test/notification_store_test.dart`

**Interfaces:**
- Consumes: — (task pertama)
- Produces: `class AppNotification { final String id; final String judul; final String isi; final DateTime waktu; final bool dibaca; const AppNotification({required String id, required String judul, required String isi, required DateTime waktu, bool dibaca = false}); String get waktuRingkas; }` dan `class NotificationStore extends ChangeNotifier { static final NotificationStore instance; List<AppNotification> get semua; int get jumlahBelumDibaca; void tambah(AppNotification n); void tandaiSemuaDibaca(); void kosongkan(); }`

- [ ] **Step 1: Tulis tes yang gagal**

```dart
// test/notification_store_test.dart
test('menambah notifikasi menaikkan jumlah belum dibaca', () {
  NotificationStore.instance.kosongkan();
  NotificationStore.instance.tambah(notifikasi('n1'));
  expect(NotificationStore.instance.semua, hasLength(1));
  expect(NotificationStore.instance.jumlahBelumDibaca, 1);
});

test('tandaiSemuaDibaca mengosongkan hitungan dan menandai semua terbaca', () {
  NotificationStore.instance.kosongkan();
  NotificationStore.instance.tambah(notifikasi('n1'));
  NotificationStore.instance.tambah(notifikasi('n2'));
  NotificationStore.instance.tandaiSemuaDibaca();
  expect(NotificationStore.instance.jumlahBelumDibaca, 0);
  expect(NotificationStore.instance.semua.every((n) => n.dibaca), isTrue);
});

test('notifikasi terbaru berada di paling atas', () {
  NotificationStore.instance.kosongkan();
  NotificationStore.instance.tambah(notifikasi('lama'));
  NotificationStore.instance.tambah(notifikasi('baru'));
  expect(NotificationStore.instance.semua.first.id, 'baru');
});
```

- [ ] **Step 2: Jalankan tes, pastikan gagal**

Run: `flutter test test/notification_store_test.dart`
Expected: gagal kompilasi — `NotificationStore` belum ada.

- [ ] **Step 3: Implementasi `lib/state/notification_store.dart`**

Pola sama seperti `lib/state/order_store.dart` (singleton `_()` + `static final instance`), `tambah` memakai `_daftar.insert(0, n)`, `waktuRingkas` seperti `OrderData.waktuRingkas`.

- [ ] **Step 4: Jalankan tes, pastikan lulus**

Run: `flutter test test/notification_store_test.dart`
Expected: PASS 3 tes.

### Task 2: Tahap 'Diantar kurir' + notifikasi tiga momen

**Files:**
- Modify: `lib/state/order_store.dart`
- Test: `test/order_notifikasi_test.dart`

**Interfaces:**
- Consumes: `NotificationStore.instance.tambah` (Task 1).
- Produces: `OrderData.tahapAktif` (`int`: 'Sedang dimasak' → 2, 'Diantar kurir' → 3, 'Selesai' → 5); `OrderStore.durasiDiantar` (static `Duration`, bawaan 30 detik); `OrderStore.ubahStatus(String id, String status)`, `OrderStore.selesaikan(String id)`, `OrderStore.kosongkan()` membatalkan timer.
- Notifikasi yang dibuat: judul `Pesanan dibuat` / `Pesanan diantar kurir` / `Pesanan selesai`.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
// test/order_notifikasi_test.dart — pakai testWidgets agar jam palsu tersedia
testWidgets('pesanan baru langsung menambah notifikasi "Pesanan dibuat"', (tester) async {
  await tester.pumpWidget(const SizedBox());
  OrderStore.durasiDiantar = const Duration(seconds: 5);
  OrderStore.instance.tambah(pesananContoh(id: 'O-1'));
  expect(NotificationStore.instance.jumlahBelumDibaca, 1);
  expect(NotificationStore.instance.semua.first.judul, 'Pesanan dibuat');
  OrderStore.instance.kosongkan();
});

testWidgets('setelah durasi, status jadi Diantar kurir dan notifikasi bertambah', (tester) async {
  await tester.pumpWidget(const SizedBox());
  OrderStore.durasiDiantar = const Duration(seconds: 5);
  OrderStore.instance.tambah(pesananContoh(id: 'O-1'));
  await tester.pump(const Duration(seconds: 6));
  expect(OrderStore.instance.semua.first.status, 'Diantar kurir');
  expect(OrderStore.instance.semua.first.tahapAktif, 3);
  expect(NotificationStore.instance.semua.first.judul, 'Pesanan diantar kurir');
  OrderStore.instance.kosongkan();
});

testWidgets('selesaikan menambah notifikasi "Pesanan selesai" dan menghentikan timer', (tester) async {
  await tester.pumpWidget(const SizedBox());
  OrderStore.durasiDiantar = const Duration(seconds: 5);
  OrderStore.instance.tambah(pesananContoh(id: 'O-1'));
  OrderStore.instance.selesaikan('O-1');
  expect(OrderStore.instance.semua.first.status, 'Selesai');
  expect(NotificationStore.instance.semua.first.judul, 'Pesanan selesai');
  await tester.pump(const Duration(seconds: 10)); // timer sudah dibatalkan
  expect(NotificationStore.instance.semua, hasLength(2));
});

testWidgets('kosongkan membatalkan timer sehingga tidak ada notifikasi setelahnya', (tester) async {
  await tester.pumpWidget(const SizedBox());
  OrderStore.durasiDiantar = const Duration(seconds: 5);
  OrderStore.instance.tambah(pesananContoh(id: 'O-1'));
  OrderStore.instance.kosongkan();
  await tester.pump(const Duration(seconds: 10));
  expect(NotificationStore.instance.semua, hasLength(0));
});
```

`pesananContoh` adalah helper di dalam berkas tes yang membangun `OrderData` status 'Sedang dimasak'.

- [ ] **Step 2: Jalankan tes, pastikan gagal**

Run: `flutter test test/order_notifikasi_test.dart`
Expected: FAIL — `durasiDiantar`, `tahapAktif`, dan notifikasi belum ada.

- [ ] **Step 3: Implementasi di `lib/state/order_store.dart`**

Tambah `tahapAktif` pada `OrderData`, `static Duration durasiDiantar = const Duration(seconds: 30)`, `Map<String, Timer> _timer`, `ubahStatus`, dan `_catatNotifikasi(String judul, String isi)` yang memanggil `NotificationStore.instance.tambah`. `tambah()` menjadwalkan timer; `selesaikan()`/`kosongkan()`/`dispose()` membatalkan.

- [ ] **Step 4: Jalankan tes, pastikan lulus**

Run: `flutter test test/order_notifikasi_test.dart`
Expected: PASS 4 tes.

### Task 3: Lonceng, panel, dan pemasangan di app bar

**Files:**
- Create: `lib/widgets/notification_bell.dart`, `lib/widgets/notification_panel.dart`
- Modify: `lib/features/home/home_page.dart` (dekat baris 230), `lib/features/menu/menu_page.dart` (dekat baris 89), `lib/features/pesanan/pesanan_page.dart` (dekat baris 41)
- Test: `test/notifikasi_lonceng_test.dart`

**Interfaces:**
- Consumes: `NotificationStore` (Task 1), `EmptyState` (`lib/widgets/empty_state.dart`), pola `IconButtonCircle` (`lib/widgets/button.dart`).
- Produces: `class NotificationBell extends StatelessWidget { const NotificationBell(); }` (tanpa parameter) — dipasang di app bar; `void showNotificationPanel(BuildContext context, {required Rect anchor})`.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('lonceng menampilkan angka belum dibaca dan panel membuka', (tester) async {
  NotificationStore.instance.kosongkan();
  NotificationStore.instance.tambah(notifikasi('n1'));
  await tester.pumpWidget(MaterialApp(home: Scaffold(appBar: AppBar(actions: const [NotificationBell()]))));
  expect(find.text('1'), findsOneWidget);
  await tester.tap(find.byTooltip('Notifikasi'));
  await tester.pumpAndSettle();
  expect(find.text('Pesanan dibuat'), findsOneWidget);
  expect(find.text('1'), findsNothing);            // angka hilang
  expect(NotificationStore.instance.jumlahBelumDibaca, 0);
});

testWidgets('panel tertutup saat pengguna pindah halaman', (tester) async { /* buka panel, dorong rute baru, pumpAndSettle, expect panel hilang */ });

testWidgets('daftar notifikasi panjang tetap bisa digulir tanpa overflow', (tester) async { /* 12 notifikasi, skala teks 1.3, expect takeException() == null */ });

testWidgets('membuka panel berulang kali tidak menggandakan panel atau memunculkan angka lagi', (tester) async { /* buka, tutup dengan tap luar, buka lagi; expect findsOneWidget panel dan angka tetap kosong */ });
```

- [ ] **Step 2: Jalankan tes, pastikan gagal**

Run: `flutter test test/notifikasi_lonceng_test.dart`
Expected: FAIL — `NotificationBell` belum ada.

- [ ] **Step 3: Implementasi `notification_bell.dart` dan `notification_panel.dart`**

Lonceng: `AnimatedBuilder` atas `NotificationStore`, `IconButtonCircle` dengan `Icons.notifications_none`, badge angka memakai pola `cart_icon_button.dart` + `AnimatedScale`. Panel: `OverlayEntry` + penghalang transparan + `ScaleTransition` (0,85 → 1,0, `Alignment.topRight`) + `FadeTransition` 180 ms `Curves.easeOutCubic`, `ListView` berisi kartu notifikasi, `tandaiSemuaDibaca()` saat dibuka, ditutup pada tap luar dan saat rute berubah (`NavigatorObserver` lokal atau `ModalRoute.of(context)?.addLocalHistoryEntry`).

- [ ] **Step 4: Jalankan tes, pastikan lulus**

Run: `flutter test test/notifikasi_lonceng_test.dart`
Expected: PASS 4 tes.

- [ ] **Step 5: Pasang `NotificationBell()` di tiga app bar dan jalankan analyze**

Run: `flutter analyze`
Expected: `No issues found!`

### Task 4: Toast bisa digeser untuk ditutup

**Files:**
- Modify: `lib/core/messages.dart`
- Test: `test/toast_geser_test.dart`

**Interfaces:**
- Consumes: — ; mempertahankan `void showAppMessage(BuildContext context, String message, {bool isError = false, Duration duration = const Duration(seconds: 4), String? actionLabel, VoidCallback? onAction})`.
- Produces: perilaku baru — gestur geser menutup toast; ambang 40% ukuran atau kecepatan 400 px/s.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('toast hilang setelah digeser ke samping', (tester) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(builder: (context) => TextButton(onPressed: () => showAppMessage(context, 'Item ditambahkan.'), child: const Text('picu'))))));
  await tester.tap(find.text('picu'));
  await tester.pumpAndSettle();
  expect(find.text('Item ditambahkan.'), findsOneWidget);
  await tester.drag(find.text('Item ditambahkan.'), const Offset(300, 0));
  await tester.pumpAndSettle();
  expect(find.text('Item ditambahkan.'), findsNothing);
});

testWidgets('menggeser sedikit mengembalikan toast ke posisi semula', (tester) async { /* drag 10 px, masih ada */ });

testWidgets('toast baru saat toast lama digeser tetap menyisakan satu toast', (tester) async { /* drag lalu panggil showAppMessage lagi, findsOneWidget */ });
```

- [ ] **Step 2: Jalankan tes, pastikan gagal**

Run: `flutter test test/toast_geser_test.dart`
Expected: FAIL — toast tidak menghilang setelah digeser.

- [ ] **Step 3: Implementasi di `lib/core/messages.dart`**

Pecah isi toast menjadi `_ToastCard extends StatefulWidget` dengan `AnimationController` (masuk 180 ms geser 12 px + fade), `onHorizontalDragUpdate`/`onVerticalDragUpdate` menggeser `Transform.translate`, `onDragEnd` memutuskan keluar atau kembali, dan tetap memanggil `showAppMessage` dari fungsi lama.

- [ ] **Step 4: Jalankan tes, pastikan lulus**

Run: `flutter test test/toast_geser_test.dart`
Expected: PASS 3 tes.

### Task 5: Centang chip filter terlihat

**Files:**
- Modify: `lib/features/menu/menu_page.dart:195`, `lib/features/home/home_page.dart:428`, `lib/features/menu/detail_menu_page.dart:362`
- Test: `test/chip_filter_test.dart`

**Interfaces:**
- Consumes: —
- Produces: setiap `ChoiceChip` dengan `selectedColor: AppColors.primary` memakai `checkmarkColor: Colors.white`.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('centang chip filter berwarna putih saat terpilih', (tester) async {
  // buka Menu lewat MainShell seperti tes lama (bukaBeranda), lalu:
  final chip = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
  expect(chip.every((c) => c.checkmarkColor == Colors.white), isTrue);
});
```

- [ ] **Step 2: Jalankan tes, pastikan gagal**

Run: `flutter test test/chip_filter_test.dart`
Expected: FAIL — `checkmarkColor` masih null.

- [ ] **Step 3: Tambah `checkmarkColor: Colors.white` di tiga berkas**

Samakan juga `labelPadding` agar label tidak bergeser saat centang muncul.

- [ ] **Step 4: Jalankan tes, pastikan lulus**

Run: `flutter test test/chip_filter_test.dart`
Expected: PASS.

### Task 6: Animasi halus pada perubahan tampilan

**Files:**
- Modify: `lib/features/menu/menu_page.dart`, `lib/features/home/home_page.dart`, `lib/widgets/cart_icon_button.dart`
- Test: `test/animasi_test.dart`

**Interfaces:**
- Consumes: —
- Produces: area hasil daftar dibungkus `AnimatedSwitcher` (200 ms) dengan kunci `'$kategori|$query'`; badge keranjang memakai `AnimatedScale`.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('mengganti filter memakai AnimatedSwitcher pada daftar hasil', (tester) async {
  // buka halaman Menu, ketuk chip 'Nasi', pump(100ms) -> masih ada dua daftar (transisi)
  expect(find.byType(AnimatedSwitcher), findsWidgets);
});
```

- [ ] **Step 2: Jalankan tes, pastikan gagal**

Run: `flutter test test/animasi_test.dart`
Expected: FAIL — belum ada `AnimatedSwitcher`.

- [ ] **Step 3: Bungkus area hasil dengan `AnimatedSwitcher` dan animasikan badge**

Hanya di tingkat daftar (bukan per item) supaya daftar panjang tetap ringan.

- [ ] **Step 4: Jalankan tes, pastikan lulus**

Run: `flutter test test/animasi_test.dart`
Expected: PASS.

### Task 7: Splash animatif + halaman Lacak ikut konsisten

**Files:**
- Modify: `pubspec.yaml` (daftarkan `assets/splash/`), `lib/features/splash/splash_page.dart`, `lib/features/tracking/tracking_page.dart`
- Test: `test/splash_gif_test.dart`, `test/widget_test.dart` (satu tes lama disesuaikan)

**Interfaces:**
- Consumes: `OrderData.tahapAktif` (Task 2).
- Produces: splash memuat `Image.asset('assets/splash/splash-warung-nusantara.gif')` pada latar `Color(0xFF165630)` dengan `Semantics(label: 'Warung Nusantara')`; halaman Lacak memakai `tahapAktif` dan menampilkan 'Pesanan sedang diantar' saat 'Diantar kurir'.

- [ ] **Step 1: Tulis/menyesuaikan tes yang gagal**

```dart
testWidgets('splash menampilkan aset GIF dan tetap mengenalkan nama warung', (tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const MyApp());
  final gambar = tester.widget<Image>(find.byType(Image).first);
  expect((gambar.image as AssetImage).assetName, 'assets/splash/splash-warung-nusantara.gif');
  expect(find.bySemanticsLabel('Warung Nusantara'), findsOneWidget);
});

testWidgets('halaman Lacak menampilkan status diantar setelah waktu berjalan', (tester) async { /* durasi 5s, buka tracking, pump 6s, expect 'Pesanan sedang diantar' */ });
```

Tes lama `Pembukaan pertama: splash lalu welcome` disesuaikan: pemeriksaan `find.text('Warung Nusantara')` diganti pemeriksaan aset GIF + label semantik.

- [ ] **Step 2: Jalankan tes, pastikan gagal**

Run: `flutter test test/splash_gif_test.dart`
Expected: FAIL — aset belum didaftarkan/gambar belum dipakai.

- [ ] **Step 3: Implementasi pubspec + splash + tracking**

Daftarkan `assets/splash/`, ganti isi splash, dan ubah `tracking_page.dart` agar memakai `tahapAktif` serta teks status per tahap.

- [ ] **Step 4: Jalankan seluruh tes, pastikan lulus**

Run: `flutter test`
Expected: seluruh tes (lama + baru) PASS.

### Task 8: Artefak rilis

**Files:**
- Modify: — (hanya build)
- Test: — (verifikasi bundel)

**Interfaces:**
- Consumes: seluruh perubahan Task 1-7.
- Produces: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (untuk HP), `build/web/` release.

- [ ] **Step 1: Bersihkan format dan analisis**

Run: `dart format lib test && flutter analyze`
Expected: `0 changed` (atau berkas yang dirapikan) dan `No issues found!`

- [ ] **Step 2: Jalankan seluruh tes**

Run: `flutter test`
Expected: semua PASS.

- [ ] **Step 3: Build release**

Run: `flutter build apk --release --split-per-abi` dan `flutter build web --release`
Expected: keduanya `exit 0`.

- [ ] **Step 4: Verifikasi isi artefak**

Run: `unzip -p <apk> assets/flutter_assets/AssetManifest.json | grep splash` dan grep teks notifikasi pada `build/web/main.dart.js`
Expected: aset splash dan teks notifikasi ditemukan.