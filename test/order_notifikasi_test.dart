import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pesanan/state/notification_store.dart';
import 'package:umkm_pesanan/state/order_store.dart';

OrderData _pesanan({String id = 'O-1', String status = 'Sedang dimasak'}) =>
    OrderData(
      id: id,
      waktu: DateTime(2026, 10, 21, 14, 30),
      lines: const [
        OrderLine(
          nama: 'Ayam Geprek Spesial',
          opsi: '',
          jumlah: 1,
          hargaSatuan: 22000,
        ),
      ],
      subtotal: 22000,
      ongkir: 8000,
      diskon: 0,
      total: 30000,
      alamat: 'Jl. Melati 1',
      pembayaran: 'QRIS',
      cabang: 'Warung Nusantara - Senen',
      status: status,
    );

void main() {
  setUp(() {
    NotificationStore.instance.kosongkan();
    OrderStore.instance.kosongkan();
    OrderStore.durasiDiantar = const Duration(seconds: 5);
  });

  tearDown(() => OrderStore.instance.kosongkan());

  testWidgets('pesanan baru menambah notifikasi "Pesanan dibuat"', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());

    OrderStore.instance.tambah(_pesanan());

    expect(NotificationStore.instance.jumlahBelumDibaca, 1);
    expect(NotificationStore.instance.semua.first.judul, 'Pesanan dibuat');
    expect(OrderStore.instance.semua.first.status, 'Sedang dimasak');
    expect(OrderStore.instance.semua.first.tahapAktif, 2);

    // Timer auto-advance dibatalkan di dalam badan tes: binding Flutter
    // menganggap tes gagal kalau masih ada timer hidup saat tes berakhir.
    OrderStore.instance.kosongkan();
  });

  testWidgets(
    'setelah durasi, status jadi "Diantar kurir" dan notifikasi muncul',
    (tester) async {
      await tester.pumpWidget(const SizedBox());
      OrderStore.instance.tambah(_pesanan());

      await tester.pump(const Duration(seconds: 6));

      expect(OrderStore.instance.semua.first.status, 'Diantar kurir');
      expect(OrderStore.instance.semua.first.tahapAktif, 3);
      expect(
        NotificationStore.instance.semua.first.judul,
        'Pesanan diantar kurir',
      );
      expect(NotificationStore.instance.jumlahBelumDibaca, 2);
    },
  );

  testWidgets('selesaikan menambah notifikasi dan menghentikan timer', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    OrderStore.instance.tambah(_pesanan());

    OrderStore.instance.selesaikan('O-1');

    expect(OrderStore.instance.semua.first.status, 'Selesai');
    expect(OrderStore.instance.semua.first.tahapAktif, 5);
    expect(NotificationStore.instance.semua.first.judul, 'Pesanan selesai');

    // Timer sudah dibatalkan, jadi tidak ada notifikasi tambahan.
    await tester.pump(const Duration(seconds: 10));
    expect(NotificationStore.instance.semua, hasLength(2));
  });

  testWidgets(
    'kosongkan membatalkan timer sehingga tidak ada notifikasi susulan',
    (tester) async {
      await tester.pumpWidget(const SizedBox());
      OrderStore.instance.tambah(_pesanan());

      OrderStore.instance.kosongkan();

      await tester.pump(const Duration(seconds: 10));

      // Hanya notifikasi saat pesanan dibuat, bukan notifikasi "diantar".
      expect(NotificationStore.instance.jumlahBelumDibaca, 1);
      expect(OrderStore.instance.semua, isEmpty);
    },
  );
}
