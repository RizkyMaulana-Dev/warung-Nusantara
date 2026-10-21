import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/data/menu_data.dart';
import 'package:umkm_pesanan/main.dart';
import 'package:umkm_pesanan/state/cart_store.dart';
import 'package:umkm_pesanan/state/order_store.dart';
import 'package:umkm_pesanan/state/voucher_store.dart';
import 'package:umkm_pesanan/widgets/cart_icon_button.dart';

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

  testWidgets('mengganti filter memudarkan daftar hasil secara halus', (
    tester,
  ) async {
    await bukaBeranda(tester);
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();

    expect(
      find.byType(SliverFadeTransition),
      findsOneWidget,
      reason: 'Daftar hasil dibungkus animasi pudar.',
    );

    await tester.tap(find.text('Nasi'));
    await tester.pump(); // mulai animasi
    await tester.pump(const Duration(milliseconds: 60));

    final memudar = tester.widget<SliverFadeTransition>(
      find.byType(SliverFadeTransition),
    );
    expect(
      memudar.opacity.value,
      lessThan(1),
      reason: 'Hasil filter baru harus memudar masuk, bukan muncul mendadak.',
    );

    await tester.pumpAndSettle();
    final selesai = tester.widget<SliverFadeTransition>(
      find.byType(SliverFadeTransition),
    );
    expect(selesai.opacity.value, 1);
    expect(find.text('Nasi Goreng Kampung'), findsOneWidget);
  });

  testWidgets('badge keranjang tumbuh dengan animasi, bukan muncul mendadak', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: AppBar(actions: const [CartIconButton()])),
      ),
    );

    expect(find.text('1'), findsNothing);

    CartStore.instance.tambah(daftarMenu.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));

    final skalaBadge = find.ancestor(
      of: find.text('1'),
      matching: find.byType(ScaleTransition),
    );
    expect(
      skalaBadge,
      findsWidgets,
      reason: 'Badge harus muncul lewat animasi skala.',
    );
    final nilaiSkala = tester
        .widgetList<ScaleTransition>(skalaBadge)
        .map((animasi) => animasi.scale.value)
        .toList();
    expect(
      nilaiSkala.any((nilai) => nilai < 1),
      isTrue,
      reason: 'Badge harus tumbuh perlahan, bukan langsung penuh.',
    );
    expect(find.text('1'), findsOneWidget);

    await tester.pumpAndSettle();
    CartStore.instance.kosongkan();
    await tester.pumpAndSettle();
  });
}
