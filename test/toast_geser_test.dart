import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pesanan/core/messages.dart';

const _pesan = 'Item ditambahkan ke keranjang.';

Widget _halaman() => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => showAppMessage(context, _pesan),
          child: const Text('picu'),
        ),
      ),
    ),
  ),
);

Future<void> _bukaToast(WidgetTester tester) async {
  await tester.pumpWidget(_halaman());
  await tester.tap(find.text('picu'));
  await tester.pumpAndSettle();
  expect(find.text(_pesan), findsOneWidget);
}

void main() {
  testWidgets('toast hilang setelah digeser jauh ke samping', (tester) async {
    await _bukaToast(tester);

    await tester.drag(find.text(_pesan), const Offset(200, 0));
    await tester.pumpAndSettle();

    expect(find.text(_pesan), findsNothing);
  });

  testWidgets('toast hilang setelah digeser ke bawah', (tester) async {
    await _bukaToast(tester);

    await tester.drag(find.text(_pesan), const Offset(0, 100));
    await tester.pumpAndSettle();

    expect(find.text(_pesan), findsNothing);
  });

  testWidgets('geseran kecil mengembalikan toast ke tempatnya', (tester) async {
    await _bukaToast(tester);

    await tester.drag(find.text(_pesan), const Offset(20, 0));
    await tester.pumpAndSettle();

    expect(find.text(_pesan), findsOneWidget);

    // Habiskan durasi toast supaya tidak ada timer tersisa saat tes selesai.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('toast baru saat toast lama digeser tetap hanya satu toast', (
    tester,
  ) async {
    await _bukaToast(tester);

    // Geseran kecil: toast kembali ke posisi semula, lalu muncul toast baru.
    await tester.drag(find.text(_pesan), const Offset(20, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('picu'));
    await tester.pumpAndSettle();

    expect(find.text(_pesan), findsOneWidget);

    // Habiskan durasi toast supaya tidak ada timer tersisa saat tes selesai.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
