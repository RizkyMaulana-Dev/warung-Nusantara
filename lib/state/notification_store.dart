import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Satu pemberitahuan di dalam aplikasi (bukan notifikasi sistem).
class AppNotification {
  final String id;
  final String judul;
  final String isi;
  final DateTime waktu;
  final bool dibaca;

  const AppNotification({
    required this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    this.dibaca = false,
  });

  AppNotification disalin({bool? dibaca}) => AppNotification(
    id: id,
    judul: judul,
    isi: isi,
    waktu: waktu,
    dibaca: dibaca ?? this.dibaca,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'isi': isi,
    'waktu': waktu.toIso8601String(),
    'dibaca': dibaca,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      judul: json['judul'] as String? ?? '',
      isi: json['isi'] as String? ?? '',
      waktu:
          DateTime.tryParse(json['waktu'] as String? ?? '') ?? DateTime.now(),
      dibaca: json['dibaca'] as bool? ?? false,
    );
  }

  String get waktuRingkas {
    String dua(int nilai) => nilai.toString().padLeft(2, '0');
    return '${dua(waktu.day)}/${dua(waktu.month)}/${waktu.year} '
        '${dua(waktu.hour)}.${dua(waktu.minute)}';
  }
}

/// Daftar notifikasi: sumber angka di lonceng dan isi panel notifikasi.
///
/// Daftar disimpan lokal supaya tidak hilang setelah logout atau aplikasi
/// dibuka ulang.
class NotificationStore extends ChangeNotifier {
  NotificationStore._();

  static final NotificationStore instance = NotificationStore._();

  static const _kunci = 'notifikasi_daftar';
  static const _maks = 50;

  final List<AppNotification> _daftar = [];

  List<AppNotification> get semua => List.unmodifiable(_daftar);

  int get jumlahBelumDibaca => _daftar.where((n) => !n.dibaca).length;

  /// Muat notifikasi tersimpan, terbaru lebih dulu.
  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kunci);
      if (raw == null || raw.isEmpty) return;

      final data = jsonDecode(raw) as List<dynamic>;
      final hasil =
          data
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .where((notifikasi) => notifikasi.id.isNotEmpty)
              .toList()
            ..sort((a, b) => b.waktu.compareTo(a.waktu));

      if (hasil.length > _maks) {
        hasil.removeRange(_maks, hasil.length);
      }

      _daftar
        ..clear()
        ..addAll(hasil);
      notifyListeners();
    } catch (e, st) {
      debugPrint('NotificationStore.muat error: $e\n$st');
    }
  }

  /// Notifikasi terbaru selalu di paling atas.
  void tambah(AppNotification notifikasi) {
    _daftar.insert(0, notifikasi);
    if (_daftar.length > _maks) {
      _daftar.removeRange(_maks, _daftar.length);
    }
    notifyListeners();
    _simpan();
  }

  void tandaiSemuaDibaca() {
    if (jumlahBelumDibaca == 0) return;
    for (var i = 0; i < _daftar.length; i++) {
      if (_daftar[i].dibaca) continue;
      _daftar[i] = _daftar[i].disalin(dibaca: true);
    }
    notifyListeners();
    _simpan();
  }

  void kosongkan() {
    final sudahKosong = _daftar.isEmpty;
    _daftar.clear();
    if (!sudahKosong) notifyListeners();
    _simpan();
  }

  Future<void> _simpan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kunci,
        jsonEncode(_daftar.map((notifikasi) => notifikasi.toJson()).toList()),
      );
    } catch (e, st) {
      debugPrint('NotificationStore._simpan error: $e\n$st');
    }
  }
}
