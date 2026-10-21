/// Model data cabang UMKM (multi-cabang).
class Cabang {
  final String id;
  final String nama;
  final String alamat;
  final double latitude;
  final double longitude;
  final bool isAktif;
  final int jarakMeter; // jarak berdasarkan jalan (diisi oleh service)

  Cabang({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    this.isAktif = true,
    this.jarakMeter = 0,
  });

  factory Cabang.fromJson(Map<String, dynamic> json) {
    return Cabang(
      id: json['id'] as String,
      nama: json['nama'] as String,
      alamat: json['alamat'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isAktif: json['is_aktif'] as bool? ?? true,
      jarakMeter: json['jarak_meter'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
      'is_aktif': isAktif,
      'jarak_meter': jarakMeter,
    };
  }

  /// Format jarak untuk ditampilkan (mis. "1,2 km" atau "450 m")
  String get jarakDisplay {
    if (jarakMeter < 1000) {
      return '$jarakMeter m';
    }
    final km = jarakMeter / 1000;
    return '${km.toStringAsFixed(1)} km';
  }
}

/// Daftar cabang contoh (mock data). Ganti dengan data asli dari API.
List<Cabang> cabangContoh = [
  Cabang(
    id: 'cabang-1',
    nama: 'Warung Nusantara - Senen',
    alamat: 'Jl. Kramat Raya No. 12, Senen, Jakarta Pusat',
    latitude: -6.1751,
    longitude: 106.8306,
    isAktif: true,
  ),
  Cabang(
    id: 'cabang-2',
    nama: 'Warung Nusantara - Mangga Besar',
    alamat: 'Jl. Mangga Besar Raya No. 5, Jakarta Barat',
    latitude: -6.1481,
    longitude: 106.8104,
    isAktif: true,
  ),
  Cabang(
    id: 'cabang-3',
    nama: 'Warung Nusantara - Cikini',
    alamat: 'Jl. Cikini Raya No. 43, Jakarta Pusat',
    latitude: -6.1925,
    longitude: 106.8315,
    isAktif: true,
  ),
];
