import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/state/voucher_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('voucher hasil tukar poin disimpan ke SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    await VoucherStore.instance.muat();

    await VoucherStore.instance.tambahVoucherPoin();

    final prefs = await SharedPreferences.getInstance();
    final data =
        jsonDecode(prefs.getString('voucher_tambahan')!) as List<dynamic>;

    expect(data, hasLength(1));
    expect((data.single as Map<String, dynamic>)['kode'], 'POIN10');
  });

  test('muat memulihkan voucher hasil tukar poin', () async {
    SharedPreferences.setMockInitialValues({
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

    await VoucherStore.instance.muat();

    expect(VoucherStore.instance.punyaVoucherPoin, isTrue);
    expect(
      VoucherStore.instance.semua.where((voucher) => voucher.kode == 'POIN10'),
      hasLength(1),
    );
  });

  test('tambahVoucherPoin menolak voucher kedua', () async {
    SharedPreferences.setMockInitialValues({});
    await VoucherStore.instance.muat();

    expect(await VoucherStore.instance.tambahVoucherPoin(), isTrue);
    expect(await VoucherStore.instance.tambahVoucherPoin(), isFalse);
    expect(
      VoucherStore.instance.semua.where((voucher) => voucher.kode == 'POIN10'),
      hasLength(1),
    );
  });
}
