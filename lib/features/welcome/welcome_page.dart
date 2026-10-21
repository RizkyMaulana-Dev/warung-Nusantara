import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../widgets/app_image.dart';
import '../../widgets/button.dart';
import '../cabang/cabang_service.dart';
import '../login/login_page.dart';

/// Welcome screen: pengenalan singkat bagi pengguna baru.
/// Setelah selesai, langsung ke Login (PRD: "di slide terakhir menuju Login").
/// Pemilihan cabang otomatis (default cabang-1) supaya user tidak perlu
/// memilih dulu; bisa ganti nanti lewat Profil → Ganti Cabang.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _halamanSaatIni = 0;
  bool _isMemulai = false;

  final List<Map<String, String>> _slides = [
    {
      'judul': 'Selamat datang di Warung Nusantara',
      'pesan': 'Pesan makanan favoritmu dari cabang terdekat dengan mudah dan cepat.',
      'gambar': 'https://images.unsplash.com/photo-1567620905732-2d1ec78799c0?auto=format&fit=crop&w=800&q=80',
    },
    {
      'judul': 'Pilih menu, atur opsi, bayar',
      'pesan': 'Tambah ke keranjang, pilih alamat, dan bayar dalam kurang dari 2 menit.',
      'gambar': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=800&q=80',
    },
    {
      'judul': 'Lacak pesanan sampai tiba',
      'pesan': 'Lihat status pesanan dari dibuat sampai tiba di pintu rumahmu.',
      'gambar': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_halamanSaatIni];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Ilustrasi dari internet dengan fallback otomatis
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: AppColors.primaryTint,
                child: AppImage(
                  url: slide['gambar']!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.restaurant_menu,
                  fallbackIconSize: 80,
                ),
              ),
            ),
            // Indikator halaman (3 titik)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    width: _halamanSaatIni == index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _halamanSaatIni == index
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Konten slide (bisa digulir bila teks diperbesar)
            Expanded(
              flex: 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s24,
                            vertical: AppSpacing.s8,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _slides[_halamanSaatIni]['judul']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: AppText.w800,
                                  height: 1.2,
                                  letterSpacing: -0.6,
                                  color: AppColors.text,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              Text(
                                _slides[_halamanSaatIni]['pesan']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: AppText.w400,
                                  height: 1.55,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Tombol Lanjut
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: PrimaryButton(
                text: _halamanSaatIni == _slides.length - 1
                    ? 'Mulai'
                    : 'Lanjut',
                onPressed: _isMemulai
                    ? null
                    : () {
                        if (_halamanSaatIni == _slides.length - 1) {
                          _mulai();
                        } else {
                          setState(() {
                            _halamanSaatIni++;
                          });
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mulai() async {
    if (_isMemulai) return;
    setState(() => _isMemulai = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_launch', false);

      // Simpan cabang default (cabang-1) bila belum ada; user bisa ganti
      // nanti lewat Profil → Ganti Cabang.
      final cabangId = prefs.getString('cabang_id') ?? 'cabang-1';
      await prefs.setString('cabang_id', cabangId);

      if (!mounted) return;

      final cabangTerpilih = CabangService().getCabangById(cabangId);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginPage(cabangTerpilih: cabangTerpilih),
        ),
      );
    } catch (e, st) {
      debugPrint('Welcome _mulai error: $e\n$st');
      if (mounted) setState(() => _isMemulai = false);
      showAppMessage(context, 'Gagal menyimpan. Ketuk Mulai lagi.');
    }
  }
}
