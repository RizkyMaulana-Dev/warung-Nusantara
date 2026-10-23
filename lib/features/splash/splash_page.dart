import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../state/alamat_store.dart';
import '../../state/loyalty_point_store.dart';
import '../../state/metode_bayar_store.dart';
import '../../state/pengaturan_store.dart';
import '../cabang/cabang_model.dart';
import '../cabang/cabang_service.dart';
import '../main/main_shell.dart';
import '../welcome/welcome_page.dart';

/// Splash screen animatif dari GIF (3 detik).
/// Latar biru-mudah #165630 sesuai GIF; label aksesibilitas untuk pembaca layar.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timerSafety;

  @override
  void initState() {
    super.initState();
    _cekSesi();
    // Safety net: pastikan splash tidak diam >6 dtk meski timer/prefs hang.
    _timerSafety = Timer(const Duration(seconds: 6), _paksaNavigasi);
  }

  @override
  void dispose() {
    _timerSafety?.cancel();
    super.dispose();
  }

  Future<void> _cekSesi() async {
    try {
      // GIF ~3 dtk; jeda 3.5 dtk supaya animasi selesai 1 putaran.
      await Future.delayed(const Duration(milliseconds: 3500));
      // Sudah dipastikan tidak hang; matikan safety timer.
      _timerSafety?.cancel();
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 4));
      if (!mounted) return;

      // Baca status sesi lebih dulu supaya routing tidak tertahan oleh
      // pemuatan store preferensi yang lambat.
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final cabangTersimpan = _cabangTersimpan(prefs);

      // Muat preferensi tersimpan (alamat, metode bayar, poin, pengaturan)
      // paralel. Dibatasi timeout agar splash tidak macet bila store lambat.
      try {
        await Future.wait([
          AlamatStore.instance.muat(),
          MetodeBayarStore.instance.muat(),
          LoyaltyPointStore.instance.muat(),
          PengaturanStore.instance.muat(),
        ]).timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('Splash muat store error: $e');
      }
      if (!mounted) return;

      final navigator = Navigator.of(context);

      // Sudah login → langsung Beranda.
      if (isLoggedIn) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainShell(cabangTerpilih: cabangTersimpan),
          ),
        );
        return;
      }

      // Belum login → selalu lewat Welcome dulu, lalu Login.
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => WelcomePage(cabangTerpilih: cabangTersimpan),
        ),
      );
    } catch (e, st) {
      // Log supaya terlihat di logcat / flutter logs.
      debugPrint('Splash _cekSesi error: $e\n$st');
      // Fallback default: belum login → Welcome (bukan langsung Login).
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomePage()),
        );
      }
    }
  }

  void _paksaNavigasi() {
    if (!mounted) return;
    // Jika masih di splash setelah 6 dtk, tampilkan Welcome (default belum login).
    debugPrint('Splash timeout 6s — paksa navigasi ke Welcome');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
    );
  }

  Cabang? _cabangTersimpan(SharedPreferences prefs) {
    final id = prefs.getString('cabang_id');
    if (id == null) return null;

    for (final cabang in CabangService().getSemuaCabang()) {
      if (cabang.id == id) return cabang;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF165630),
      body: Semantics(
        label: 'Warung Nusantara',
        child: Center(
          // GIF animatif dari aset lokal; putar sekali (tidak looping) supaya
          // splash tidak terasa 'nge-stuck' menunggu animasi berputar terus.
          child: Image.asset(
            'assets/splash/splash-warung-nusantara.gif',
            width: 260,
            fit: BoxFit.contain,
            repeat: ImageRepeat.noRepeat,
            errorBuilder: (context, error, stackTrace) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant, size: 48, color: Colors.white),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'Warung Nusantara',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: AppText.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
