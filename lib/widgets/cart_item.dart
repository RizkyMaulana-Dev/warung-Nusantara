import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import 'app_image.dart';

/// Item daftar keranjang dengan gambar, nama, opsi, harga, dan stepper.
class CartItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String options;
  final int price;
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;

  const CartItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.options,
    required this.price,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    this.onRemove,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppSize.listItemRadius),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar 64x64 radius 12
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                url: imageUrl,
                width: 64,
                height: 64,
                fallbackIconSize: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: AppText.w700,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (options.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      options,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: AppText.w400,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
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
                      const SizedBox(width: 8),
                      _buildStepper(),
                    ],
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: onRemove,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: AppSize.touchTarget,
                  minHeight: AppSize.touchTarget,
                ),
                tooltip: 'Hapus item',
              ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildStepper() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.remove,
                size: 20,
                color: AppColors.primary,
              ),
              onPressed: onDecrease,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
          Container(
            width: 30,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white),
            child: Text(
              quantity.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: AppText.w700,
                color: AppColors.text,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 20, color: AppColors.accent),
              onPressed: onIncrease,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
