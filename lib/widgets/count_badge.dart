import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';

/// Angka jumlah di atas sebuah ikon (keranjang, lonceng notifikasi).
///
/// Muncul dan berubah lewat animasi skala kecil supaya tidak terlihat
/// mendadak, dan ikut hilang saat jumlahnya nol.
class AnimatedCountBadge extends StatelessWidget {
  final int jumlah;

  const AnimatedCountBadge({super.key, required this.jumlah});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animasi) => ScaleTransition(
        scale: animasi,
        child: FadeTransition(opacity: animasi, child: child),
      ),
      child: jumlah == 0 ? const SizedBox.shrink() : _badge(),
    );
  }

  Widget _badge() {
    return Container(
      key: ValueKey(jumlah),
      constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        jumlah > 99 ? '99+' : '$jumlah',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: AppText.w800,
          color: AppColors.onAccent,
          height: 1.2,
        ),
      ),
    );
  }
}
