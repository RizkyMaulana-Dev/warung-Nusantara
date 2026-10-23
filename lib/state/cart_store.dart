import 'package:flutter/foundation.dart';

import '../data/menu_data.dart';

/// Satu baris di keranjang. Opsi addon disimpan agar harga dan catatan
/// tetap sesuai saat jumlah diubah.
class CartLine {
  final String id;
  final MenuProduk produk;
  final List<AddonOption> addon;
  final String catatan;
  final int jumlah;

  const CartLine({
    required this.id,
    required this.produk,
    required this.addon,
    required this.catatan,
    required this.jumlah,
  });

  int get hargaSatuan =>
      produk.harga + addon.fold(0, (total, opsi) => total + opsi.harga);

  int get subtotal => hargaSatuan * jumlah;

  String get opsiRingkas {
    final bagian = <String>[
      ...addon.map((opsi) => opsi.nama),
      if (catatan.isNotEmpty) 'Catatan: $catatan',
    ];
    return bagian.join(', ');
  }

  List<String> get idAddon => addon.map((opsi) => opsi.id).toList()..sort();

  CartLine copyWith({int? jumlah}) {
    return CartLine(
      id: id,
      produk: produk,
      addon: addon,
      catatan: catatan,
      jumlah: jumlah ?? this.jumlah,
    );
  }
}

class CartStore extends ChangeNotifier {
  CartStore._();

  static final CartStore instance = CartStore._();

  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);

  bool get kosong => _lines.isEmpty;

  int get totalItem => _lines.fold(0, (total, line) => total + line.jumlah);

  int get subtotal => _lines.fold(0, (total, line) => total + line.subtotal);

  int get ongkir => _lines.isEmpty ? 0 : 8000;

  int get total => subtotal + ongkir;

  bool _sama(
    CartLine line,
    MenuProduk produk,
    List<AddonOption> addon,
    String catatan,
  ) {
    if (line.produk.id != produk.id) return false;
    if (line.catatan.trim() != catatan.trim()) return false;
    final idBaru = addon.map((opsi) => opsi.id).toList()..sort();
    final idLama = line.addon.map((opsi) => opsi.id).toList()..sort();
    if (idBaru.length != idLama.length) return false;
    for (var i = 0; i < idBaru.length; i++) {
      if (idBaru[i] != idLama[i]) return false;
    }
    return true;
  }

  void tambah(
    MenuProduk produk, {
    List<AddonOption> addon = const [],
    String catatan = '',
    int jumlah = 1,
  }) {
    if (!produk.tersedia || jumlah < 1) return;

    final index = _lines.indexWhere(
      (line) => _sama(line, produk, addon, catatan),
    );

    if (index >= 0) {
      final lama = _lines[index];
      _lines[index] = lama.copyWith(jumlah: lama.jumlah + jumlah);
    } else {
      _lines.insert(
        0,
        CartLine(
          id: 'line-${DateTime.now().microsecondsSinceEpoch}-${_lines.length}',
          produk: produk,
          addon: List.unmodifiable(addon),
          catatan: catatan.trim(),
          jumlah: jumlah,
        ),
      );
    }
    notifyListeners();
  }

  void tambahJumlah(String id) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index < 0) return;
    final line = _lines[index];
    _lines[index] = line.copyWith(jumlah: line.jumlah + 1);
    notifyListeners();
  }

  void kurangiJumlah(String id) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index < 0) return;
    final line = _lines[index];
    if (line.jumlah <= 1) {
      _lines.removeAt(index);
    } else {
      _lines[index] = line.copyWith(jumlah: line.jumlah - 1);
    }
    notifyListeners();
  }

  void hapus(String id) {
    _lines.removeWhere((line) => line.id == id);
    notifyListeners();
  }

  /// Ubah addon & catatan sebuah baris (jumlah tidak berubah).
  void perbarui(
    String id, {
    List<AddonOption> addon = const [],
    String catatan = '',
  }) {
    final index = _lines.indexWhere((line) => line.id == id);
    if (index < 0) return;
    final line = _lines[index];
    _lines[index] = CartLine(
      id: line.id,
      produk: line.produk,
      addon: List.unmodifiable(addon),
      catatan: catatan.trim(),
      jumlah: line.jumlah,
    );
    notifyListeners();
  }

  void kosongkan() {
    if (_lines.isEmpty) return;
    _lines.clear();
    notifyListeners();
  }
}
