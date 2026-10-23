import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Poin loyalitas sederhana.
/// - Didapat per transaksi (1 poin / Rp 1.000, dibulatkan).
/// - Berkurang saat menu-rate-voucher (100 poin → Rp 10.000) dipakai.
class LoyaltyPointStore extends ChangeNotifier {
  LoyaltyPointStore._();

  static final LoyaltyPointStore instance = LoyaltyPointStore._();

  int _poin = 0;

  int get poin => _poin;

  bool get cukupTukar => _poin >= 100;

  /// 1 poin per Rp 1.000 (dibulatkan ke bawah).
  void tambahDariTotal(int totalRupiah) {
    final didapat = (totalRupiah / 1000).floor();
    if (didapat <= 0) return;
    _poin += didapat;
    _simpan();
    notifyListeners();
  }

  void kurangi(int jumlah) {
    if (jumlah <= 0) return;
    _poin = (_poin - jumlah).clamp(0, _poin);
    _simpan();
    notifyListeners();
  }

  void reset() {
    _poin = 0;
    _simpan();
    notifyListeners();
  }

  Future<void> muat() async {
    try {
      final prefs =
          await SharedPreferences.getInstance().timeout(const Duration(seconds: 5));
      _poin = prefs.getInt('loyalty_poin') ?? 0;
      notifyListeners();
    } catch (e, st) {
      debugPrint('LoyaltyPointStore.muat error: $e\n$st');
    }
  }

  Future<void> _simpan() async {
    try {
      final prefs =
          await SharedPreferences.getInstance().timeout(const Duration(seconds: 5));
      await prefs.setInt('loyalty_poin', _poin);
    } catch (e, st) {
      debugPrint('LoyaltyPointStore._simpan error: $e\n$st');
    }
  }
}
