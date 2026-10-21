import 'package:flutter/foundation.dart';

/// Satu pemberitahuan di dalam aplikasi (bukan notifikasi sistem).
/// Notifikasi hanya hidup selama aplikasi berjalan, sama seperti keranjang.
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

  String get waktuRingkas {
    String dua(int nilai) => nilai.toString().padLeft(2, '0');
    return '${dua(waktu.day)}/${dua(waktu.month)}/${waktu.year} '
        '${dua(waktu.hour)}.${dua(waktu.minute)}';
  }
}

/// Daftar notifikasi: sumber angka di lonceng dan isi panel notifikasi.
class NotificationStore extends ChangeNotifier {
  NotificationStore._();

  static final NotificationStore instance = NotificationStore._();

  final List<AppNotification> _daftar = [];

  List<AppNotification> get semua => List.unmodifiable(_daftar);

  int get jumlahBelumDibaca => _daftar.where((n) => !n.dibaca).length;

  /// Notifikasi terbaru selalu di paling atas.
  void tambah(AppNotification notifikasi) {
    _daftar.insert(0, notifikasi);
    notifyListeners();
  }

  void tandaiSemuaDibaca() {
    if (jumlahBelumDibaca == 0) return;
    for (var i = 0; i < _daftar.length; i++) {
      if (_daftar[i].dibaca) continue;
      _daftar[i] = _daftar[i].disalin(dibaca: true);
    }
    notifyListeners();
  }

  void kosongkan() {
    if (_daftar.isEmpty) return;
    _daftar.clear();
    notifyListeners();
  }
}
