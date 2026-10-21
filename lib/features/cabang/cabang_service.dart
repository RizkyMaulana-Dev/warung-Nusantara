import 'package:geolocator/geolocator.dart';

import '../cabang/cabang_model.dart';

/// Service untuk mengelola data cabang dan perhitungan jarak.
class CabangService {
  final List<Cabang> _daftarCabang = List.from(cabangContoh);

  /// Mengambil semua cabang aktif.
  List<Cabang> getSemuaCabang() {
    return _daftarCabang.where((c) => c.isAktif).toList();
  }

  /// Mengambil cabang berdasarkan ID.
  Cabang? getCabangById(String id) {
    try {
      return _daftarCabang.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Menghitung jarak garis lurus dari lokasi user ke setiap cabang (meter).
  /// Untuk produksi, ganti dengan API jarak berdasarkan jalan (Google Distance Matrix).
  List<Cabang> hitungJarakDariLokasi(Position posisiUser) {
    final hasil = <Cabang>[];
    for (final cabang in _daftarCabang.where((c) => c.isAktif)) {
      final jarak = Geolocator.distanceBetween(
        posisiUser.latitude,
        posisiUser.longitude,
        cabang.latitude,
        cabang.longitude,
      );
      hasil.add(
        Cabang(
          id: cabang.id,
          nama: cabang.nama,
          alamat: cabang.alamat,
          latitude: cabang.latitude,
          longitude: cabang.longitude,
          isAktif: cabang.isAktif,
          jarakMeter: jarak.round(),
        ),
      );
    }
    // Urutkan terdekat dulu
    hasil.sort((a, b) => a.jarakMeter.compareTo(b.jarakMeter));
    return hasil;
  }

  /// Mengambil cabang terdekat.
  Cabang? getCabangTerdekat(Position posisiUser) {
    final daftar = hitungJarakDariLokasi(posisiUser);
    return daftar.isNotEmpty ? daftar.first : null;
  }
}
