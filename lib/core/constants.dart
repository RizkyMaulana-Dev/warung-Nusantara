import 'package:flutter/material.dart';

// =============================================================================
// WARNA (Token sesuai DESIGN.md)
// =============================================================================
class AppColors {
  static const Color primary = Color(0xFF14532D); // hijau tua
  static const Color primarySoft = Color(0xFF1F6B3B); // elemen dekoratif
  static const Color primaryTint = Color(0xFFE7F1EA); // latar ikon, tombol Ubah
  static const Color onPrimaryMuted = Color(
    0xFFBFE3CB,
  ); // teks kecil di atas hijau

  static const Color accent = Color(0xFFF59E0B); // kuning kunyit
  static const Color onAccent = Color(0xFF1B2420); // teks di atas kuning

  static const Color text = Color(0xFF1B2420); // teks utama
  static const Color textSecondary = Color(0xFF5B6460); // teks pendukung

  static const Color surface = Color(0xFFFFFFFF); // kartu, lembar
  static const Color surfaceSoft = Color(
    0xFFF1F3F7,
  ); // latar kartu menu, kolom isian
  static const Color background = Color(0xFFF5F6F3); // latar layar
  static const Color divider = Color(0xFFE6E9E5); // garis pemisah

  static const Color success = Color(0xFF15803D); // Tersedia
  static const Color error = Color(0xFFB42318); // galat

  static const Color badgeBg = Color(0xFFFEF3C7); // label Terlaris
  static const Color badgeText = Color(0xFF7A4B00);
}

// =============================================================================
// TYPOGRAFI (font Plus Jakarta Sans)
// =============================================================================
class AppText {
  static const String fontFamily = 'Plus Jakarta Sans';

  // Bobot
  static const FontWeight w400 = FontWeight.w400;
  static const FontWeight w500 = FontWeight.w500;
  static const FontWeight w600 = FontWeight.w600;
  static const FontWeight w700 = FontWeight.w700;
  static const FontWeight w800 = FontWeight.w800;
}

// =============================================================================
// SPASI (skala 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 36)
// =============================================================================
class AppSpacing {
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s36 = 36;

  // Margin layar kiri-kanan
  static const double screenMargin = 20.0;
  // Padding atas konten
  static const double contentTopPadding = 24.0;
}

// =============================================================================
// UKURAN KOMPONEN
// =============================================================================
class AppSize {
  static const double touchTarget = 44.0; // minimal 44x44 px
  static const double buttonHeight = 52.0; // tombol utama/sekunder
  static const double smallButtonHeight = 40.0;
  static const double iconButtonSize = 44.0;
  static const double addButtonSize = 44.0;
  static const double bottomActionBarHeight = 92.0;
  static const double bottomNavHeight = 76.0;
  static const double headerHeight = 104.0;
  static const double cardRadius = 18.0;
  static const double listItemRadius = 16.0;
  static const double inputRadius = 14.0;
  static const double buttonRadius = 26.0;
  static const double smallButtonRadius = 20.0;
  static const double imageAreaRadius = 14.0;
}

// =============================================================================
// FORMAT RUPIAH
// =============================================================================
String formatRupiah(int amount) {
  return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}
