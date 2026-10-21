import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/main.dart';
import 'package:umkm_pesanan/state/cart_store.dart';
import 'package:umkm_pesanan/state/order_store.dart';
import 'package:umkm_pesanan/state/voucher_store.dart';

void main() {
  setUpAll(() {
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

  void pastikanCentangPutih(WidgetTester tester, String tempat) {
    final chips = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .toList();

    expect(chips, isNotEmpty, reason: 'Chip filter harus ada di $tempat.');
    for (final chip in chips) {
      expect(
        chip.checkmarkColor,
        Colors.white,
        reason:
            'Centang chip filter di $tempat harus putih supaya '
            'terlihat di atas warna hijau.',
      );
    }
  }

  testWidgets(
    'centang chip filter berwarna putih di beranda dan halaman Menu',
    (tester) async {
      await bukaBeranda(tester);

      // Baris kategori di beranda ada di bawah: gulir dulu supaya dibangun.
      await tester.scrollUntilVisible(
        find.byType(ChoiceChip).first,
        260,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      pastikanCentangPutih(tester, 'beranda');

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      pastikanCentangPutih(tester, 'halaman Menu');
    },
  );
}
