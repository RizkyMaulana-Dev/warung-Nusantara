import 'package:flutter/foundation.dart';

class MetodeBayarData {
  final String id;
  final String nama;
  final String detail;
  final bool utama;

  const MetodeBayarData({
    required this.id,
    required this.nama,
    required this.detail,
    this.utama = false,
  });

  MetodeBayarData copyWith({bool? utama}) {
    return MetodeBayarData(
      id: id,
      nama: nama,
      detail: detail,
      utama: utama ?? this.utama,
    );
  }
}

class MetodeBayarStore extends ChangeNotifier {
  MetodeBayarStore._();

  static final MetodeBayarStore instance = MetodeBayarStore._();

  final List<MetodeBayarData> _daftar = [
    const MetodeBayarData(
      id: 'qris',
      nama: 'QRIS',
      detail: 'Bayar dengan aplikasi dompet digital',
      utama: true,
    ),
    const MetodeBayarData(
      id: 'bca',
      nama: 'Transfer Bank BCA',
      detail: 'Transfer ke rekening warung',
    ),
    const MetodeBayarData(
      id: 'cod',
      nama: 'Bayar di Tempat',
      detail: 'Bayar tunai saat pesanan tiba',
    ),
  ];

  List<MetodeBayarData> get daftar => List.unmodifiable(_daftar);

  MetodeBayarData? get utama {
    for (final metode in _daftar) {
      if (metode.utama) return metode;
    }
    return _daftar.isEmpty ? null : _daftar.first;
  }

  void tambah({required String nama, required String detail}) {
    _daftar.add(
      MetodeBayarData(
        id: 'bayar-${DateTime.now().microsecondsSinceEpoch}',
        nama: nama.trim(),
        detail: detail.trim().isEmpty
            ? 'Metode pembayaran tersimpan'
            : detail.trim(),
        utama: _daftar.isEmpty,
      ),
    );
    notifyListeners();
  }

  void jadikanUtama(String id) {
    final index = _daftar.indexWhere((metode) => metode.id == id);
    if (index < 0) return;
    for (var i = 0; i < _daftar.length; i++) {
      _daftar[i] = _daftar[i].copyWith(utama: i == index);
    }
    notifyListeners();
  }

  void hapus(String id) {
    final cocok = _daftar.where((metode) => metode.id == id);
    if (cocok.isEmpty) return;
    final terhapus = cocok.first;
    _daftar.removeWhere((metode) => metode.id == id);
    if (terhapus.utama && _daftar.isNotEmpty) {
      _daftar[0] = _daftar[0].copyWith(utama: true);
    }
    notifyListeners();
  }
}
