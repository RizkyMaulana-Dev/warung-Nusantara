import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferensi aplikasi (notifikasi & hemat data).
/// Dimuat sekali saat splash, lalu setiap perubahan langsung disimpan
/// ke penyimpanan lokal supaya tetap ada saat aplikasi dibuka lagi.
class PengaturanStore extends ChangeNotifier {
  PengaturanStore._();

  static final PengaturanStore instance = PengaturanStore._();

  static const _kunciPromo = 'notif_promo';
  static const _kunciPesanan = 'notif_pesanan';
  static const _kunciHemat = 'hemat_data';

  bool _notifPromo = true;
  bool _notifPesanan = true;
  bool _hematData = false;

  bool get notifPromo => _notifPromo;
  bool get notifPesanan => _notifPesanan;
  bool get hematData => _hematData;

  /// Muat semua preferensi tersimpan.
  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notifPromo = prefs.getBool(_kunciPromo) ?? true;
      _notifPesanan = prefs.getBool(_kunciPesanan) ?? true;
      _hematData = prefs.getBool(_kunciHemat) ?? false;
      notifyListeners();
    } catch (e, st) {
      debugPrint('PengaturanStore.muat error: $e\n$st');
    }
  }

  Future<void> setNotifPromo(bool nilai) async {
    _notifPromo = nilai;
    notifyListeners();
    await _simpan(_kunciPromo, nilai);
  }

  Future<void> setNotifPesanan(bool nilai) async {
    _notifPesanan = nilai;
    notifyListeners();
    await _simpan(_kunciPesanan, nilai);
  }

  Future<void> setHematData(bool nilai) async {
    _hematData = nilai;
    notifyListeners();
    await _simpan(_kunciHemat, nilai);
  }

  Future<void> _simpan(String kunci, bool nilai) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kunci, nilai);
    } catch (e, st) {
      debugPrint('PengaturanStore._simpan error: $e\n$st');
    }
  }
}
