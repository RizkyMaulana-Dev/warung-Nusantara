import 'dart:async';

import 'package:flutter/foundation.dart';

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
}

class OrderStore extends ChangeNotifier {
  OrderStore._();

  static final OrderStore instance = OrderStore._();

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
    if (_orders.isEmpty) return;
    _orders.clear();
    notifyListeners();
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

  /// Satu tempat untuk membuat notifikasi, supaya teksnya tidak tersebar
  /// dan tidak pernah muncul dua kali.
  void _catatNotifikasi(String judul, String isi) {
    NotificationStore.instance.tambah(
      AppNotification(
        id: 'notif-${_nomorNotifikasi++}',
        judul: judul,
        isi: isi,
        waktu: DateTime.now(),
      ),
    );
  }

  int _nomorNotifikasi = 0;
}
