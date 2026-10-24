import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  AlamatData copyWith({String? label, String? detail, bool? utama}) {
    return AlamatData(
      id: id,
      label: label ?? this.label,
      detail: detail ?? this.detail,
      utama: utama ?? this.utama,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'detail': detail,
    'utama': utama,
  };

  factory AlamatData.fromJson(Map<String, dynamic> json) {
    return AlamatData(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      utama: json['utama'] as bool? ?? false,
    );
  }
}

class AlamatStore extends ChangeNotifier {
  AlamatStore._();

  static final AlamatStore instance = AlamatStore._();

  static const _kunci = 'alamat_daftar';

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

  /// Muat daftar alamat tersimpan dari penyimpanan lokal.
  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kunci);
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as List<dynamic>;
      final hasil = data
          .map((e) => AlamatData.fromJson(e as Map<String, dynamic>))
          .where((alamat) => alamat.id.isNotEmpty)
          .toList();
      if (hasil.isEmpty) return;
      _daftar
        ..clear()
        ..addAll(hasil);
      notifyListeners();
    } catch (e, st) {
      debugPrint('AlamatStore.muat error: $e\n$st');
    }
  }

  Future<void> _simpan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kunci,
        jsonEncode(_daftar.map((alamat) => alamat.toJson()).toList()),
      );
    } catch (e, st) {
      debugPrint('AlamatStore._simpan error: $e\n$st');
    }
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
    _simpan();
  }

  void ubah({
    required String id,
    required String label,
    required String detail,
  }) {
    final index = _daftar.indexWhere((alamat) => alamat.id == id);
    if (index < 0) return;
    _daftar[index] = _daftar[index].copyWith(
      label: label.trim(),
      detail: detail.trim(),
    );
    notifyListeners();
    _simpan();
  }

  void jadikanUtama(String id) {
    final index = _daftar.indexWhere((alamat) => alamat.id == id);
    if (index < 0) return;
    for (var i = 0; i < _daftar.length; i++) {
      _daftar[i] = _daftar[i].copyWith(utama: i == index);
    }
    notifyListeners();
    _simpan();
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
    _simpan();
  }
}
