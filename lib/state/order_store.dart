import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/cart_store.dart';
import 'notification_store.dart';

class OrderLine {
  final String nama;
  final String opsi;
  final int jumlah;
  final int hargaSatuan;

  const OrderLine({
    required this.nama,
    required this.opsi,
    required this.jumlah,
    required this.hargaSatuan,
  });

  int get subtotal => hargaSatuan * jumlah;

  factory OrderLine.fromCart(CartLine line) {
    return OrderLine(
      nama: line.produk.nama,
      opsi: line.opsiRingkas,
      jumlah: line.jumlah,
      hargaSatuan: line.hargaSatuan,
    );
  }

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'opsi': opsi,
    'jumlah': jumlah,
    'hargaSatuan': hargaSatuan,
  };

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    return OrderLine(
      nama: json['nama'] as String? ?? '',
      opsi: json['opsi'] as String? ?? '',
      jumlah: (json['jumlah'] as num?)?.toInt() ?? 0,
      hargaSatuan: (json['hargaSatuan'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderData {
  final String id;
  final DateTime waktu;
  final List<OrderLine> lines;
  final int subtotal;
  final int ongkir;
  final int diskon;
  final int total;
  final String alamat;
  final String pembayaran;
  final String cabang;
  final String status;

  const OrderData({
    required this.id,
    required this.waktu,
    required this.lines,
    required this.subtotal,
    required this.ongkir,
    required this.diskon,
    required this.total,
    required this.alamat,
    required this.pembayaran,
    required this.cabang,
    required this.status,
  });

  bool get selesai => status == 'Selesai';

  /// Tahap linimasa yang sedang berjalan (0-4), atau 5 kalau semua tahap selesai.
  /// Dipakai halaman Lacak pesanan supaya tidak bertentangan dengan notifikasi.
  int get tahapAktif {
    switch (status) {
      case 'Diantar kurir':
        return 3;
      case 'Selesai':
        return 5;
      default:
        return 2; // 'Sedang dimasak'
    }
  }

  /// Salinan pesanan dengan status baru.
  OrderData denganStatus(String statusBaru) => OrderData(
    id: id,
    waktu: waktu,
    lines: lines,
    subtotal: subtotal,
    ongkir: ongkir,
    diskon: diskon,
    total: total,
    alamat: alamat,
    pembayaran: pembayaran,
    cabang: cabang,
    status: statusBaru,
  );

  int get totalItem => lines.fold(0, (jumlah, line) => jumlah + line.jumlah);

  String get waktuRingkas {
    String dua(int nilai) => nilai.toString().padLeft(2, '0');
    return '${dua(waktu.day)}/${dua(waktu.month)}/${waktu.year} '
        '${dua(waktu.hour)}.${dua(waktu.minute)}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'waktu': waktu.toIso8601String(),
    'lines': lines.map((line) => line.toJson()).toList(),
    'subtotal': subtotal,
    'ongkir': ongkir,
    'diskon': diskon,
    'total': total,
    'alamat': alamat,
    'pembayaran': pembayaran,
    'cabang': cabang,
    'status': status,
  };

  factory OrderData.fromJson(Map<String, dynamic> json) {
    final linesRaw = json['lines'] as List<dynamic>? ?? const [];
    return OrderData(
      id: json['id'] as String? ?? '',
      waktu:
          DateTime.tryParse(json['waktu'] as String? ?? '') ?? DateTime.now(),
      lines: linesRaw
          .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
      ongkir: (json['ongkir'] as num?)?.toInt() ?? 0,
      diskon: (json['diskon'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      alamat: json['alamat'] as String? ?? '',
      pembayaran: json['pembayaran'] as String? ?? '',
      cabang: json['cabang'] as String? ?? '',
      status: json['status'] as String? ?? 'Selesai',
    );
  }
}

class OrderStore extends ChangeNotifier {
  OrderStore._();

  static final OrderStore instance = OrderStore._();

  static const _kunci = 'pesanan_daftar';

  /// Berapa lama pesanan berjalan sebelum otomatis jadi 'Diantar kurir'.
  /// Satu konstanta supaya bisa diperpendek saat pengujian.
  static Duration durasiDiantar = const Duration(seconds: 30);

  final List<OrderData> _orders = [];

  /// Timer auto-advance per id pesanan. Dibersihkan saat pesanan selesai,
  /// saat daftar dikosongkan, dan saat store dibuang.
  final Map<String, Timer> _timer = {};

  List<OrderData> get semua => List.unmodifiable(_orders);

  List<OrderData> get aktif =>
      _orders.where((order) => !order.selesai).toList();

  List<OrderData> get riwayat =>
      _orders.where((order) => order.selesai).toList();

  /// Muat pesanan tersimpan, lalu lanjutkan timer pesanan yang masih dimasak.
  ///
  /// Pesanan yang waktunya sudah lewat langsung dipindah ke 'Diantar kurir'
  /// dan dibuatkan satu notifikasi. Statusnya langsung disimpan supaya
  /// notifikasi tidak muncul berulang setiap aplikasi dibuka.
  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kunci);
      if (raw == null || raw.isEmpty) return;

      final data = jsonDecode(raw) as List<dynamic>;
      final hasil = <OrderData>[];
      for (final item in data) {
        try {
          final order = OrderData.fromJson(item as Map<String, dynamic>);
          if (order.id.isNotEmpty) hasil.add(order);
        } catch (e, st) {
          debugPrint('OrderStore.muat item error: $e\n$st');
        }
      }

      _batalkanTimer();
      _orders
        ..clear()
        ..addAll(hasil);

      if (hasil.isEmpty) {
        notifyListeners();
        return;
      }

      final sekarang = DateTime.now();
      final perluDiantar = <String>[];
      for (final order in hasil) {
        if (order.status != 'Sedang dimasak') continue;
        final sisa = durasiDiantar - sekarang.difference(order.waktu);
        if (sisa <= Duration.zero) {
          perluDiantar.add(order.id);
        } else {
          _timer[order.id] = Timer(sisa, () => tandaiDiantar(order.id));
        }
      }

      for (final id in perluDiantar) {
        tandaiDiantar(id);
      }
      notifyListeners();
    } catch (e, st) {
      debugPrint('OrderStore.muat error: $e\n$st');
    }
  }

  void tambah(OrderData order) {
    _orders.insert(0, order);
    _catatNotifikasi(
      'Pesanan dibuat',
      'Pesanan ${order.id} sedang disiapkan warung.',
    );

    if (!order.selesai) {
      _timer[order.id]?.cancel();
      _timer[order.id] = Timer(durasiDiantar, () => tandaiDiantar(order.id));
    }

    notifyListeners();
    _simpan();
  }

  /// Pesanan mulai diantar kurir (dipanggil timer atau simulasi kurir).
  void tandaiDiantar(String id) {
    final order = _cari(id);
    if (order == null || order.selesai || order.status == 'Diantar kurir') {
      return;
    }
    ubahStatus(id, 'Diantar kurir');
    _catatNotifikasi(
      'Pesanan diantar kurir',
      'Pesanan $id sedang dalam perjalanan ke alamatmu.',
    );
  }

  /// Ganti status pesanan. Timer auto-advance ikut berhenti begitu pesanan
  /// tidak lagi berjalan, supaya tidak ada notifikasi susulan.
  void ubahStatus(String id, String status) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return;

    final order = _orders[index];
    if (order.status == status) return;

    if (status == 'Diantar kurir' || status == 'Selesai') {
      _timer.remove(id)?.cancel();
    }

    _orders[index] = order.denganStatus(status);
    notifyListeners();
    _simpan();
  }

  void selesaikan(String id) {
    final order = _cari(id);
    if (order == null || order.selesai) return;

    ubahStatus(id, 'Selesai');
    _catatNotifikasi(
      'Pesanan selesai',
      'Pesanan $id sudah diterima. Terima kasih sudah memesan!',
    );
  }

  void kosongkan() {
    _batalkanTimer();
    final sudahKosong = _orders.isEmpty;
    _orders.clear();
    if (!sudahKosong) notifyListeners();
    _simpan();
  }

  @override
  void dispose() {
    _batalkanTimer();
    super.dispose();
  }

  OrderData? _cari(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  void _batalkanTimer() {
    for (final timer in _timer.values) {
      timer.cancel();
    }
    _timer.clear();
  }

  Future<void> _simpan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kunci,
        jsonEncode(_orders.map((order) => order.toJson()).toList()),
      );
    } catch (e, st) {
      debugPrint('OrderStore._simpan error: $e\n$st');
    }
  }

  /// Satu tempat untuk membuat notifikasi, supaya teksnya tidak tersebar
  /// dan tidak pernah muncul dua kali.
  void _catatNotifikasi(String judul, String isi) {
    NotificationStore.instance.tambah(
      AppNotification(
        id: 'notif-${DateTime.now().microsecondsSinceEpoch}-${_nomorNotifikasi++}',
        judul: judul,
        isi: isi,
        waktu: DateTime.now(),
      ),
    );
  }

  int _nomorNotifikasi = 0;
}
