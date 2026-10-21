import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/main.dart';
import 'package:umkm_pesanan/features/welcome/welcome_page.dart';
import 'package:umkm_pesanan/features/login/login_page.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Welcome: slide terakhir langsung ke Login, tanpa memaksa pilih cabang',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.text('Selamat datang di Warung Nusantara'), findsOneWidget);

      // Dua slide Lanjut, lalu Mulai.
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mulai'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Langsung di Login; tidak ada CabangPage di jalan.
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Selamat datang kembali'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_first_launch'), isFalse);
      expect(prefs.getString('cabang_id'), 'cabang-1');
    },
  );

  testWidgets('Mulai tidak ter-disable setelah gagal; bisa dicoba lagi', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();

    // Tekan Mulai dua kali cepat: harus tetap valid, tidak hang.
    await tester.tap(find.text('Mulai'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
