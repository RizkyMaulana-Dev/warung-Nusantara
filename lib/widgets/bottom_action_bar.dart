import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';

/// Bar aksi bawah: latar primary, radius atas 24.
/// Kiri: keterangan (11) di atas nilai (20/800 putih).
/// Kanan: tombol utama putih yang lebarnya menyesuaikan teks.
class BottomActionBar extends StatelessWidget {
  final String keterangan;
  final String nilai;
  final String tombolText;
  final VoidCallback onTombolPressed;
  final bool isLoading;

  const BottomActionBar({
    super.key,
    required this.keterangan,
    required this.nilai,
    required this.tombolText,
    required this.onTombolPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxTombolWidth = MediaQuery.sizeOf(context).width * 0.52;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        // Box shadow dihapus: ikon dan tombol tetap rapi (flat).
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSize.bottomActionBarHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              children: [
                // Kiri: keterangan + nilai. Fleksibel agar tidak meluber.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        keterangan,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: AppText.w600,
                          color: AppColors.onPrimaryMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            nilai,
                            maxLines: 1,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: AppText.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Kanan: tombol selebar teksnya, maksimal 52% layar.
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxTombolWidth),
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onTombolPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.white70,
                        disabledForegroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        minimumSize: const Size(0, 44),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSize.buttonRadius,
                          ),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                tombolText,
                                maxLines: 1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: AppText.w700,
                                ),
                              ),
                            ),
                    ),
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
