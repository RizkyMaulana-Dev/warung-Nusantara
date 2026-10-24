import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  MetodeBayarData copyWith({String? nama, String? detail, bool? utama}) {
    return MetodeBayarData(
      id: id,
      nama: nama ?? this.nama,
      detail: detail ?? this.detail,
      utama: utama ?? this.utama,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'detail': detail,
    'utama': utama,
  };

  factory MetodeBayarData.fromJson(Map<String, dynamic> json) {
    return MetodeBayarData(
      id: json['id'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      utama: json['utama'] as bool? ?? false,
    );
  }
}

class MetodeBayarStore extends ChangeNotifier {
  MetodeBayarStore._();

  static final MetodeBayarStore instance = MetodeBayarStore._();

  static const _kunci = 'metode_bayar_daftar';

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

  /// Muat daftar metode bayar tersimpan dari penyimpanan lokal.
  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kunci);
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as List<dynamic>;
      final hasil = data
          .map((e) => MetodeBayarData.fromJson(e as Map<String, dynamic>))
          .where((metode) => metode.id.isNotEmpty)
          .toList();
      if (hasil.isEmpty) return;
      _daftar
        ..clear()
        ..addAll(hasil);
      notifyListeners();
    } catch (e, st) {
      debugPrint('MetodeBayarStore.muat error: $e\n$st');
    }
  }

  Future<void> _simpan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kunci,
        jsonEncode(_daftar.map((metode) => metode.toJson()).toList()),
      );
    } catch (e, st) {
      debugPrint('MetodeBayarStore._simpan error: $e\n$st');
    }
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
    _simpan();
  }

  void ubah({
    required String id,
    required String nama,
    required String detail,
  }) {
    final index = _daftar.indexWhere((metode) => metode.id == id);
    if (index < 0) return;
    _daftar[index] = _daftar[index].copyWith(
      nama: nama.trim(),
      detail: detail.trim().isEmpty
          ? 'Metode pembayaran tersimpan'
          : detail.trim(),
    );
    notifyListeners();
    _simpan();
  }

  void jadikanUtama(String id) {
    final index = _daftar.indexWhere((metode) => metode.id == id);
    if (index < 0) return;
    for (var i = 0; i < _daftar.length; i++) {
      _daftar[i] = _daftar[i].copyWith(utama: i == index);
    }
    notifyListeners();
    _simpan();
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
    _simpan();
  }
}
