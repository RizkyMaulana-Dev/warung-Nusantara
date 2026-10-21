import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pesanan/state/notification_store.dart';
import 'package:umkm_pesanan/widgets/notification_bell.dart';
import 'package:umkm_pesanan/widgets/notification_panel.dart';

AppNotification _notifikasi(int ke) => AppNotification(
  id: 'n$ke',
  judul: 'Pesanan dibuat',
  isi: 'Pesanan O-$ke sedang disiapkan warung.',
  waktu: DateTime(2026, 10, 21, 14, 30),
);

Widget _halaman({double skalaTeks = 1.0, GlobalKey<NavigatorState>? kunci}) {
  final appBar = AppBar(
    title: const Text('Beranda'),
    actions: const [NotificationBell()],
  );
  return MaterialApp(
    navigatorKey: kunci,
    navigatorObservers: [NotificationPanelObserver()],
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(skalaTeks)),
        child: Scaffold(
          appBar: appBar,
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Halaman lain')),
                ),
              ),
              child: const Text('buka halaman lain'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => NotificationStore.instance.kosongkan());

  testWidgets('lonceng menampilkan angka, panel terbuka, dan angka hilang', (
    tester,
  ) async {
    NotificationStore.instance.tambah(_notifikasi(1));
    await tester.pumpWidget(_halaman());

    // Angka jumlah notifikasi belum dibaca.
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Pesanan dibuat'), findsOneWidget);
    expect(find.text('1'), findsNothing); // angka ikut hilang
    expect(NotificationStore.instance.jumlahBelumDibaca, 0);
  });

  testWidgets('panel tertutup saat pengguna pindah halaman', (tester) async {
    NotificationStore.instance.tambah(_notifikasi(1));
    final kunciNavigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_halaman(kunci: kunciNavigator));

    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan dibuat'), findsOneWidget);

    // Pindah halaman tanpa lewat penghalang panel (mis. dari tombol lain),
    // supaya yang diuji benar-benar penutup otomatisnya.
    kunciNavigator.currentState!.push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('Halaman lain')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pesanan dibuat'), findsNothing);
    expect(find.text('Halaman lain'), findsOneWidget);
  });

  testWidgets('daftar panjang dan teks besar tetap rapi tanpa overflow', (
    tester,
  ) async {
    for (var i = 0; i < 12; i++) {
      NotificationStore.instance.tambah(_notifikasi(i));
    }
    await tester.pumpWidget(_halaman(skalaTeks: 1.3));

    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Pesanan dibuat'), findsWidgets);
    // Daftar bisa digulir: item terakhir belum tentu terlihat, tapi tetap
    // bisa dicapai lewat gulir.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('membuka panel berulang kali tidak menggandakan panel', (
    tester,
  ) async {
    NotificationStore.instance.tambah(_notifikasi(1));
    await tester.pumpWidget(_halaman());

    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsOneWidget);

    // Ketuk area luar untuk menutup.
    await tester.tapAt(const Offset(20, 400));
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsNothing);

    await tester.tap(find.byTooltip('Notifikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('1'), findsNothing); // tidak ada angka lagi
  });
}
