import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/features/alamat/alamat_page.dart';
import 'package:umkm_pesanan/features/pembayaran/metode_pembayaran_page.dart';
import 'package:umkm_pesanan/features/riwayat/riwayat_pesanan_page.dart';
import 'package:umkm_pesanan/state/alamat_store.dart';
import 'package:umkm_pesanan/state/metode_bayar_store.dart';
import 'package:umkm_pesanan/state/order_store.dart';

Map<String, dynamic> _jsonPesanan({
  required String id,
  required String status,
}) {
  return {
    'id': id,
    'waktu': '2026-10-21T14:30:00.000',
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

  testWidgets('alamat bisa diubah lewat dialog tanpa overflow', (tester) async {
    SharedPreferences.setMockInitialValues({
      'alamat_daftar': jsonEncode([
        {
          'id': 'a-1',
          'label': 'Rumah',
          'detail': 'Jl. Lama No. 1, Jakarta',
          'utama': true,
        },
      ]),
    });
    await AlamatStore.instance.muat();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AlamatPage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Ubah alamat').first);
    await tester.pumpAndSettle();

    expect(find.text('Ubah alamat'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Rumah Baru');
    await tester.enterText(
      find.byType(TextFormField).last,
      'Jl. Baru No. 10, Jakarta',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(AlamatStore.instance.daftar.first.label, 'Rumah Baru');
    expect(AlamatStore.instance.utama?.id, 'a-1');
    expect(tester.takeException(), isNull);

    // Biarkan timer SnackBar selesai supaya tidak tertinggal di akhir tes.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('metode pembayaran bisa diubah lewat dialog', (tester) async {
    SharedPreferences.setMockInitialValues({
      'metode_bayar_daftar': jsonEncode([
        {
          'id': 'm-1',
          'nama': 'QRIS',
          'detail': 'Bayar dengan dompet digital',
          'utama': true,
        },
      ]),
    });
    await MetodeBayarStore.instance.muat();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: MetodePembayaranPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ubah metode').first);
    await tester.pumpAndSettle();

    expect(find.text('Ubah metode'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'QRIS Baru');
    await tester.enterText(
      find.byType(TextFormField).last,
      'Pindai kode QR di kasir',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(MetodeBayarStore.instance.daftar.first.nama, 'QRIS Baru');
    expect(MetodeBayarStore.instance.utama?.id, 'm-1');
    expect(tester.takeException(), isNull);

    // Biarkan timer SnackBar selesai supaya tidak tertinggal di akhir tes.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('riwayat hanya menampilkan pesanan yang sudah selesai', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'pesanan_daftar': jsonEncode([
        _jsonPesanan(id: 'WN-AKTIF', status: 'Diantar kurir'),
        _jsonPesanan(id: 'WN-SELESAI', status: 'Selesai'),
      ]),
    });
    await OrderStore.instance.muat();

    await tester.pumpWidget(const MaterialApp(home: RiwayatPesananPage()));
    await tester.pumpAndSettle();

    expect(find.text('WN-SELESAI'), findsOneWidget);
    expect(find.text('WN-AKTIF'), findsNothing);
    expect(tester.takeException(), isNull);

    OrderStore.instance.kosongkan();
  });
}
