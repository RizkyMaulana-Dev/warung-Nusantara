import 'package:flutter/foundation.dart';

class VoucherData {
  final String kode;
  final String judul;
  final String keterangan;
  final int minimalBelanja;
  final int potongan;

  const VoucherData({
    required this.kode,
    required this.judul,
    required this.keterangan,
    required this.minimalBelanja,
    required this.potongan,
  });
}

const List<VoucherData> daftarVoucher = [
  VoucherData(
    kode: 'HEMAT10',
    judul: 'Potongan Rp 10.000',
    keterangan: 'Berlaku untuk semua menu. Tidak bisa digabung.',
    minimalBelanja: 50000,
    potongan: 10000,
  ),
  VoucherData(
    kode: 'MAKAN5',
    judul: 'Potongan Rp 5.000',
    keterangan: 'Khusus pesanan makan siang.',
    minimalBelanja: 30000,
    potongan: 5000,
  ),
  VoucherData(
    kode: 'BARU15',
    judul: 'Potongan Rp 15.000',
    keterangan: 'Voucher pengguna baru, sekali pakai.',
    minimalBelanja: 75000,
    potongan: 15000,
  ),
  VoucherData(
    kode: 'NGETEH',
    judul: 'Potongan Rp 4.000',
    keterangan: 'Cocok untuk pesan minuman favoritmu.',
    minimalBelanja: 20000,
    potongan: 4000,
  ),
];

class VoucherStore extends ChangeNotifier {
  VoucherStore._();

  static final VoucherStore instance = VoucherStore._();

  final List<VoucherData> _tambahan = [];
  VoucherData? _dipilih;

  VoucherData? get dipilih => _dipilih;

  bool get adaVoucher => _dipilih != null;

  /// Voucher bawaan ditambah voucher hasil tukar poin.
  List<VoucherData> get semua =>
      List.unmodifiable([...daftarVoucher, ..._tambahan]);

  bool get punyaVoucherPoin =>
      _tambahan.any((voucher) => voucher.kode == 'POIN10');

  void tambahVoucherPoin() {
    if (punyaVoucherPoin) return;
    _tambahan.add(
      const VoucherData(
        kode: 'POIN10',
        judul: 'Potongan Rp 10.000',
        keterangan: 'Hasil tukar 100 poin loyalitas.',
        minimalBelanja: 20000,
        potongan: 10000,
      ),
    );
    notifyListeners();
  }

  void pilih(VoucherData voucher) {
    _dipilih = voucher;
    notifyListeners();
  }

  void hapus() {
    if (_dipilih == null) return;
    _dipilih = null;
    notifyListeners();
  }

  int hitungDiskon(int subtotal) {
    final voucher = _dipilih;
    if (voucher == null) return 0;
    if (subtotal < voucher.minimalBelanja) return 0;
    return voucher.potongan;
  }
}
