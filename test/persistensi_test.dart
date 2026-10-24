import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/state/notification_store.dart';
import 'package:umkm_pesanan/state/order_store.dart';

Map<String, dynamic> _jsonPesanan({
  required String id,
  required String status,
  String waktu = '2026-10-21T14:30:00.000',
}) {
  return {
    'id': id,
    'waktu': waktu,
    'lines': [
      {
        'nama': 'Ayam Geprek Spesial',
        'opsi': '',
        'jumlah': 1,
        'hargaSatuan': 22000,
      },
    ],
    'subtotal': 22000,
    'ongkir': 8000,
    'diskon': 0,
    'total': 30000,
    'alamat': 'Rumah · Jl. Melati 1',
    'pembayaran': 'QRIS',
    'cabang': 'Warung Nusantara - Senen',
    'status': status,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationStore', () {
    test('muat memulihkan notifikasi beserta status bacanya', () async {
      SharedPreferences.setMockInitialValues({
        'notifikasi_daftar': jsonEncode([
          {
            'id': 'n-lama',
            'judul': 'Pesanan dibuat',
            'isi': 'Pesanan lama sedang disiapkan.',
            'waktu': '2026-10-21T10:05:00.000',
            'dibaca': true,
          },
          {
            'id': 'n-baru',
            'judul': 'Pesanan diantar kurir',
            'isi': 'Pesanan baru sedang diantar.',
            'waktu': '2026-10-21T10:06:00.000',
            'dibaca': false,
          },
        ]),
      });

      await NotificationStore.instance.muat();

      expect(NotificationStore.instance.semua, hasLength(2));
      expect(NotificationStore.instance.semua.first.id, 'n-baru');
      expect(NotificationStore.instance.jumlahBelumDibaca, 1);
    });

    test('tandaiSemuaDibaca menyimpan status baca ke penyimpanan', () async {
      SharedPreferences.setMockInitialValues({
        'notifikasi_daftar': jsonEncode([
          {
            'id': 'n-1',
            'judul': 'Pesanan dibuat',
            'isi': 'Pesanan sedang disiapkan.',
            'waktu': '2026-10-21T10:05:00.000',
            'dibaca': false,
          },
        ]),
      });
      await NotificationStore.instance.muat();

      NotificationStore.instance.tandaiSemuaDibaca();
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final data =
          jsonDecode(prefs.getString('notifikasi_daftar')!) as List<dynamic>;
      expect((data.first as Map<String, dynamic>)['dibaca'], isTrue);
    });
  });

  group('OrderStore', () {
    test('muat memulihkan pesanan selesai dan aktif', () async {
      SharedPreferences.setMockInitialValues({
        'pesanan_daftar': jsonEncode([
          _jsonPesanan(id: 'WN-1', status: 'Selesai'),
          _jsonPesanan(id: 'WN-2', status: 'Diantar kurir'),
        ]),
      });

      await OrderStore.instance.muat();

      expect(OrderStore.instance.semua, hasLength(2));
      expect(OrderStore.instance.riwayat.map((order) => order.id), ['WN-1']);
      expect(OrderStore.instance.aktif.map((order) => order.id), ['WN-2']);
      expect(
        OrderStore.instance.semua.first.lines.first.nama,
        'Ayam Geprek Spesial',
      );
    });

    test(
      'muat memindahkan pesanan yang lewat waktu ke diantar kurir',
      () async {
        final waktu = DateTime.now()
            .subtract(const Duration(minutes: 1))
            .toIso8601String();
        SharedPreferences.setMockInitialValues({
          'pesanan_daftar': jsonEncode([
            _jsonPesanan(
              id: 'WN-TELAT',
              status: 'Sedang dimasak',
              waktu: waktu,
            ),
          ]),
        });

        await OrderStore.instance.muat();

        expect(OrderStore.instance.semua.single.status, 'Diantar kurir');
        expect(
          NotificationStore.instance.semua.any(
            (notifikasi) => notifikasi.judul == 'Pesanan diantar kurir',
          ),
          isTrue,
        );

        OrderStore.instance.kosongkan();
      },
    );

    test('selesaikan menyimpan status selesai ke penyimpanan', () async {
      SharedPreferences.setMockInitialValues({
        'pesanan_daftar': jsonEncode([
          _jsonPesanan(id: 'WN-1', status: 'Diantar kurir'),
        ]),
      });
      await OrderStore.instance.muat();

      OrderStore.instance.selesaikan('WN-1');
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final data =
          jsonDecode(prefs.getString('pesanan_daftar')!) as List<dynamic>;
      expect((data.first as Map<String, dynamic>)['status'], 'Selesai');
      expect(OrderStore.instance.riwayat.single.id, 'WN-1');

      OrderStore.instance.kosongkan();
    });
  });
}
