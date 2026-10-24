import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/features/profile/profile_page.dart';
import 'package:umkm_pesanan/state/loyalty_point_store.dart';
import 'package:umkm_pesanan/state/voucher_store.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('tukar poin menolak saat voucher poin sudah ada', (tester) async {
    SharedPreferences.setMockInitialValues({
      'loyalty_poin': 100,
      'voucher_tambahan': jsonEncode([
        {
          'kode': 'POIN10',
          'judul': 'Potongan Rp 10.000',
          'keterangan': 'Hasil tukar 100 poin loyalitas.',
          'minimalBelanja': 20000,
          'potongan': 10000,
        },
      ]),
    });
    await LoyaltyPointStore.instance.muat();
    await VoucherStore.instance.muat();

    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
    await tester.pumpAndSettle();

    final tombol = find.text('Tukar');
    await tester.ensureVisible(tombol);
    await tester.pumpAndSettle();
    await tester.tap(tombol);
    await tester.pumpAndSettle();

    expect(find.text('Tukar poin'), findsNothing);
    expect(find.textContaining('sudah ada'), findsOneWidget);
    expect(LoyaltyPointStore.instance.poin, 100);

    // Habiskan durasi toast supaya tidak ada timer tersisa saat tes selesai.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
