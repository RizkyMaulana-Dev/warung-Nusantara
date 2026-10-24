import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/state/alamat_store.dart';
import 'package:umkm_pesanan/state/metode_bayar_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AlamatStore', () {
    test(
      'ubah memperbarui label dan detail tanpa mengubah status utama',
      () async {
        SharedPreferences.setMockInitialValues({
          'alamat_daftar': jsonEncode([
            {
              'id': 'a-1',
              'label': 'Rumah',
              'detail': 'Jl. Lama No. 1, Jakarta',
              'utama': true,
            },
            {
              'id': 'a-2',
              'label': 'Kantor',
              'detail': 'Jl. Sudirman No. 2, Jakarta',
              'utama': false,
            },
          ]),
        });
        await AlamatStore.instance.muat();

        AlamatStore.instance.ubah(
          id: 'a-1',
          label: 'Rumah Baru',
          detail: 'Jl. Baru No. 10, Jakarta',
        );
        await Future<void>.delayed(Duration.zero);

        final alamat = AlamatStore.instance.daftar.first;
        expect(alamat.label, 'Rumah Baru');
        expect(alamat.detail, 'Jl. Baru No. 10, Jakarta');
        expect(alamat.utama, isTrue);
        expect(AlamatStore.instance.utama?.id, 'a-1');

        final prefs = await SharedPreferences.getInstance();
        final data =
            jsonDecode(prefs.getString('alamat_daftar')!) as List<dynamic>;
        expect((data.first as Map<String, dynamic>)['label'], 'Rumah Baru');
      },
    );

    test('hapus alamat utama mempromosikan alamat berikutnya', () async {
      SharedPreferences.setMockInitialValues({
        'alamat_daftar': jsonEncode([
          {
            'id': 'a-1',
            'label': 'Rumah',
            'detail': 'Jl. Lama No. 1, Jakarta',
            'utama': true,
          },
          {
            'id': 'a-2',
            'label': 'Kantor',
            'detail': 'Jl. Sudirman No. 2, Jakarta',
            'utama': false,
          },
        ]),
      });
      await AlamatStore.instance.muat();

      AlamatStore.instance.hapus('a-1');

      expect(AlamatStore.instance.daftar, hasLength(1));
      expect(AlamatStore.instance.utama?.id, 'a-2');
    });
  });

  group('MetodeBayarStore', () {
    test(
      'ubah memperbarui nama dan keterangan tanpa mengubah status utama',
      () async {
        SharedPreferences.setMockInitialValues({
          'metode_bayar_daftar': jsonEncode([
            {
              'id': 'm-1',
              'nama': 'QRIS',
              'detail': 'Bayar dengan dompet digital',
              'utama': true,
            },
            {
              'id': 'm-2',
              'nama': 'Transfer Bank',
              'detail': 'Transfer ke rekening warung',
              'utama': false,
            },
          ]),
        });
        await MetodeBayarStore.instance.muat();

        MetodeBayarStore.instance.ubah(
          id: 'm-1',
          nama: 'QRIS Baru',
          detail: 'Pindai kode QR di kasir',
        );
        await Future<void>.delayed(Duration.zero);

        final metode = MetodeBayarStore.instance.daftar.first;
        expect(metode.nama, 'QRIS Baru');
        expect(metode.detail, 'Pindai kode QR di kasir');
        expect(metode.utama, isTrue);
        expect(MetodeBayarStore.instance.utama?.id, 'm-1');

        final prefs = await SharedPreferences.getInstance();
        final data = jsonDecode(
          prefs.getString('metode_bayar_daftar')!,
        ) as List<dynamic>;
        expect((data.first as Map<String, dynamic>)['nama'], 'QRIS Baru');
      },
    );

    test('hapus metode utama mempromosikan metode berikutnya', () async {
      SharedPreferences.setMockInitialValues({
        'metode_bayar_daftar': jsonEncode([
          {
            'id': 'm-1',
            'nama': 'QRIS',
            'detail': 'Bayar dengan dompet digital',
            'utama': true,
          },
          {
            'id': 'm-2',
            'nama': 'Transfer Bank',
            'detail': 'Transfer ke rekening warung',
            'utama': false,
          },
        ]),
      });
      await MetodeBayarStore.instance.muat();

      MetodeBayarStore.instance.hapus('m-1');

      expect(MetodeBayarStore.instance.daftar, hasLength(1));
      expect(MetodeBayarStore.instance.utama?.id, 'm-2');
    });
  });
}
