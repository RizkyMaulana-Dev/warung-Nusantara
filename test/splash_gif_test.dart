import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/main.dart';
import 'package:umkm_pesanan/state/cart_store.dart';
import 'package:umkm_pesanan/state/order_store.dart';
import 'package:umkm_pesanan/state/voucher_store.dart';

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

void main() {
  setUp(() {
    CartStore.instance.kosongkan();
    OrderStore.instance.kosongkan();
    VoucherStore.instance.hapus();
  });

  testWidgets('splash menampilkan aset GIF dan tetap mengenalkan nama warung', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());

    // Gambar GIF adalah Image.asset pertama di pohon.
    final gambar = tester.widget<Image>(find.byType(Image).first);
    expect(
      (gambar.image as AssetImage).assetName,
      'assets/splash/splash-warung-nusantara.gif',
    );

    // Nama warung tetap terbaca untuk pembaca layar.
    expect(find.bySemanticsLabel('Warung Nusantara'), findsOneWidget);

    // Majukan waktu sampai splash selesai supaya timer tidak tersisa.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'halaman Lacak menampilkan status diantar setelah waktu berjalan',
    (tester) async {
      // Durasi sangat pendek supaya tes tidak memakan waktu lama.
      OrderStore.durasiDiantar = const Duration(seconds: 5);
      await bukaBeranda(tester);

      // Buat pesanan: menu -> detail -> keranjang -> checkout.
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      final kartu = find.text('Nasi Goreng Kampung');
      await tester.ensureVisible(kartu.first);
      await tester.pumpAndSettle();
      await tester.tap(kartu.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah ke keranjang'));
      await tester.pumpAndSettle();

      // Toast muncul dengan aksi "Lihat" → pindah ke halaman keranjang.
      await tester.tap(find.text('Lihat'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bayar'));
      await tester.pumpAndSettle();

      // Checkout langsung membuka halaman Lacak.
      // Sebelum timer: status 'Sedang dimasak'.
      expect(find.text('Detail pesanan'), findsOneWidget);
      expect(find.text('Pesanan sedang diproses'), findsOneWidget);

      // Majukan jam palsu melewati durasiDiantar.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      // Setelah timer: status 'Diantar kurir'.
      expect(find.text('Pesanan sedang diantar'), findsOneWidget);
      expect(
        find.text('Kurir sedang membawa pesananmu ke alamat tujuan.'),
        findsOneWidget,
      );
    },
  );
}
