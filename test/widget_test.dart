import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/data/menu_data.dart';
import 'package:umkm_pesanan/features/bantuan/pusat_bantuan_page.dart';
import 'package:umkm_pesanan/main.dart';
import 'package:umkm_pesanan/state/cart_store.dart';
import 'package:umkm_pesanan/state/order_store.dart';
import 'package:umkm_pesanan/state/voucher_store.dart';

void main() {
  // Kanal yang dipakai url_launcher untuk membuka tautan eksternal.
  const kanalUrlLauncher = MethodChannel('plugins.flutter.io/url_launcher');

  setUpAll(() {
    // Font dibundel di assets; jangan ambil dari internet saat tes.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    CartStore.instance.kosongkan();
    OrderStore.instance.kosongkan();
    VoucherStore.instance.hapus();
  });

  Future<void> bukaBeranda(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'is_first_launch': false,
      'is_logged_in': true,
      'cabang_id': 'cabang-1',
    });
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  }

  Future<void> bukaPusatBantuan(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PusatBantuanPage()));
    await tester.pumpAndSettle();

    final tombol = find.text('Chat WhatsApp');
    await tester.ensureVisible(tombol);
    await tester.pumpAndSettle();
    await tester.tap(tombol);
    await tester.pumpAndSettle();
  }

  testWidgets('Pembukaan pertama: splash GIF lalu welcome', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    // Splash pertama kali menampilkan GIF animatif dari aset.
    final gambar = tester.widget<Image>(find.byType(Image).first);
    expect(
      (gambar.image as AssetImage).assetName,
      'assets/splash/splash-warung-nusantara.gif',
    );

    // Nama warung tetap terbaca untuk pembaca layar.
    expect(find.bySemanticsLabel('Warung Nusantara'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di Warung Nusantara'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
  });

  testWidgets('Pengguna login langsung ke beranda dan bisa pindah tab', (
    tester,
  ) async {
    await bukaBeranda(tester);

    expect(find.text('Pesan Makan Favoritmu'), findsOneWidget);
    expect(find.text('Warung Nusantara - Senen'), findsOneWidget);

    // Pindah ke tab Menu.
    await tester.tap(find.text('Menu'));
    await tester.pump();

    expect(find.text('Cari menu...'), findsOneWidget);
    expect(find.text('Menu'), findsNWidgets(2)); // judul AppBar + label nav
  });

  testWidgets('Pencarian menu menyaring hasil', (tester) async {
    await bukaBeranda(tester);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Es Teh');
    await tester.pumpAndSettle();

    expect(find.text('Es Teh Manis'), findsOneWidget);
    expect(find.text('Nasi Goreng Kampung'), findsNothing);
    expect(find.text('Hasil untuk "Es Teh"'), findsOneWidget);
  });

  testWidgets('Topping, jumlah, dan keranjang terhubung', (tester) async {
    await bukaBeranda(tester);

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayam Geprek Spesial'));
    await tester.pumpAndSettle();

    expect(find.text('Sesuaikan pesananmu'), findsOneWidget);

    final keju = find.textContaining('Keju parut').first;
    await tester.ensureVisible(keju);
    await tester.pumpAndSettle();
    await tester.tap(keju);
    await tester.pump();

    final tambahJumlah = find.byTooltip('Tambah jumlah');
    await tester.ensureVisible(tambahJumlah);
    await tester.pumpAndSettle();
    await tester.tap(tambahJumlah);
    await tester.pump();

    expect(find.text('Rp 54.000'), findsOneWidget);

    await tester.tap(find.text('Tambah ke keranjang'));
    await tester.pumpAndSettle();

    expect(find.text('Ayam Geprek Spesial masuk keranjang.'), findsOneWidget);

    await tester.tap(find.text('Lihat'));
    await tester.pumpAndSettle();

    expect(find.text('Keranjang (2)'), findsOneWidget);
    expect(find.textContaining('Keju parut'), findsOneWidget);
    expect(find.text('Rp 62.000'), findsOneWidget);
  });

  testWidgets('Checkout membuat pesanan dan mengosongkan keranjang', (
    tester,
  ) async {
    CartStore.instance.tambah(daftarMenu.first, jumlah: 1);
    await bukaBeranda(tester);

    await tester.tap(find.byTooltip('Keranjang').first);
    await tester.pumpAndSettle();

    expect(find.text('Keranjang (1)'), findsOneWidget);

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Alamat pengantaran'), findsOneWidget);
    expect(find.text('Metode pembayaran'), findsOneWidget);

    await tester.tap(find.text('Bayar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    expect(find.text('Detail pesanan'), findsOneWidget);
    expect(find.text('Pesanan sedang diproses'), findsOneWidget);
    expect(CartStore.instance.lines, isEmpty);
    expect(OrderStore.instance.semua, isNotEmpty);

    // Habiskan durasi notifikasi agar tidak ada timer tersisa saat tes selesai.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Pesanan masih berjalan, jadi timer auto-advance 'Diantar kurir' ikut
    // dibatalkan; kalau tidak, tes gagal karena timer masih hidup.
    OrderStore.instance.kosongkan();
  });

  testWidgets('Pesanan selesai pindah ke riwayat', (tester) async {
    CartStore.instance.tambah(daftarMenu.first, jumlah: 1);
    await bukaBeranda(tester);

    // Tambah ke keranjang -> checkout -> bayar -> lacak.
    await tester.tap(find.byTooltip('Keranjang').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bayar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    final nomorPesanan = OrderStore.instance.semua.first.id;
    expect(find.text('Pesanan sedang diproses'), findsOneWidget);

    // Pesanan diterima -> status berubah jadi selesai.
    await tester.tap(find.text('Pesanan sudah diterima'));
    await tester.pumpAndSettle();

    expect(find.text('Pesanan selesai'), findsOneWidget);
    expect(OrderStore.instance.semua.first.selesai, isTrue);

    // Kembali ke beranda, lalu lihat riwayat dari tab Akun.
    await tester.tap(find.text('Kembali ke beranda'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();

    final menuRiwayat = find.text('Riwayat pesanan');
    await tester.ensureVisible(menuRiwayat.first);
    await tester.pumpAndSettle();
    await tester.tap(menuRiwayat.first);
    await tester.pumpAndSettle();

    expect(find.text('Riwayat masih kosong.'), findsNothing);
    expect(find.text(nomorPesanan), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('Chat WhatsApp membuka tautan wa.me', (tester) async {
    final panggilan = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      kanalUrlLauncher,
      (call) async {
        panggilan.add(call);
        return true;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        kanalUrlLauncher,
        null,
      ),
    );

    await bukaPusatBantuan(tester);

    expect(panggilan, hasLength(1));
    expect(panggilan.single.method, 'launch');
    final argumen = panggilan.single.arguments as Map<Object?, Object?>;
    final url = argumen['url'] as String;
    expect(url, startsWith('https://wa.me/6281234567890'));
    expect(url, contains('Halo+Warung+Nusantara'));
    // WhatsApp berhasil dibuka, jadi tidak ada pesan cadangan.
    expect(find.textContaining('tidak bisa dibuka'), findsNothing);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('Chat WhatsApp menyalin nomor dan memberi solusi saat gagal', (
    tester,
  ) async {
    final salinan = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      kanalUrlLauncher,
      (call) async => false,
    );
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') salinan.add(call);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        kanalUrlLauncher,
        null,
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await bukaPusatBantuan(tester);

    // WhatsApp tidak tersedia: pengguna diberi tahu salah + solusi yang tetap
    // bisa dipakai walau WhatsApp tidak terpasang.
    expect(
      find.text(
        'WhatsApp tidak bisa dibuka. Nomor sudah disalin, buka WhatsApp Web atau telepon warung.',
      ),
      findsOneWidget,
    );

    // Nomor benar-benar disalin, bukan hanya diklaim di pesan.
    expect(salinan, hasLength(1));
    final isi = salinan.single.arguments as Map<Object?, Object?>;
    expect(isi['text'], '+62 812-3456-7890');

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
