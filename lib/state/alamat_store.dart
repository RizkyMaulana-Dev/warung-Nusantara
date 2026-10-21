import 'package:flutter/foundation.dart';

class AlamatData {
  final String id;
  final String label;
  final String detail;
  final bool utama;

  const AlamatData({
    required this.id,
    required this.label,
    required this.detail,
    this.utama = false,
  });

  AlamatData copyWith({bool? utama}) {
    return AlamatData(
      id: id,
      label: label,
      detail: detail,
      utama: utama ?? this.utama,
    );
  }
}

class AlamatStore extends ChangeNotifier {
  AlamatStore._();

  static final AlamatStore instance = AlamatStore._();

  final List<AlamatData> _daftar = [
    const AlamatData(
      id: 'alamat-rumah',
      label: 'Rumah',
      detail: 'Jl. Kramat Raya No. 12, Senen, Jakarta Pusat',
      utama: true,
    ),
    const AlamatData(
      id: 'alamat-kantor',
      label: 'Kantor',
      detail: 'Jl. Jend. Sudirman Kav. 1, Jakarta Pusat',
    ),
  ];

  List<AlamatData> get daftar => List.unmodifiable(_daftar);

  AlamatData? get utama {
    for (final alamat in _daftar) {
      if (alamat.utama) return alamat;
    }
    return _daftar.isEmpty ? null : _daftar.first;
  }

  void tambah({required String label, required String detail}) {
    final baru = AlamatData(
      id: 'alamat-${DateTime.now().microsecondsSinceEpoch}',
      label: label.trim(),
      detail: detail.trim(),
      utama: _daftar.isEmpty,
    );
    _daftar.add(baru);
    notifyListeners();
  }

  void jadikanUtama(String id) {
    final index = _daftar.indexWhere((alamat) => alamat.id == id);
    if (index < 0) return;
    for (var i = 0; i < _daftar.length; i++) {
      _daftar[i] = _daftar[i].copyWith(utama: i == index);
    }
    notifyListeners();
  }

  void hapus(String id) {
    final cocok = _daftar.where((alamat) => alamat.id == id);
    if (cocok.isEmpty) return;
    final terhapus = cocok.first;
    _daftar.removeWhere((alamat) => alamat.id == id);
    if (terhapus.utama && _daftar.isNotEmpty) {
      _daftar[0] = _daftar[0].copyWith(utama: true);
    }
    notifyListeners();
  }
}
