import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import 'app_image.dart';
import 'button.dart';

/// Kartu menu untuk grid (2 kolom).
/// Tinggi total ±200 px: gambar 100 px + nama + takaran + harga + tombol tambah.
class MenuCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String portion;
  final int price;
  final bool isAvailable;
  final bool isPopular;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  const MenuCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.portion,
    required this.price,
    this.isAvailable = true,
    this.isPopular = false,
    this.onTap,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area gambar (tinggi 100, radius 14)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSize.imageAreaRadius),
                  ),
                  child: AppImage(
                    url: imageUrl,
                    height: 100,
                    width: double.infinity,
                  ),
                ),
                if (isPopular)
                  Positioned(top: 8, left: 8, child: _buildBadge('Terlaris')),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: const Center(
                        child: Text(
                          'Habis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s10),
            // Nama (14/700)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: AppText.w700,
                  height: 1.3,
                  color: AppColors.text,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            // Takaran (12, text-secondary)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                portion,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: AppText.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            // Baris harga + tombol tambah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatRupiah(price),
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: AppText.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isAvailable)
                    QuickAddButton(onPressed: onAdd)
                  else
                    const SizedBox(
                      width: AppSize.addButtonSize,
                      height: AppSize.addButtonSize,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgeBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: AppText.w700,
          color: AppColors.badgeText,
        ),
      ),
    );
  }
}
