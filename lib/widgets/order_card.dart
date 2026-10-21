import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../state/order_store.dart';

/// Kartu ringkas pesanan, dipakai di tab Pesanan dan Riwayat.
class OrderCard extends StatelessWidget {
  final OrderData order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selesai = order.selesai;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSize.listItemRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSize.listItemRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.listItemRadius),
            border: Border.all(
              color: selesai ? AppColors.divider : AppColors.accent,
              width: selesai ? 1 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selesai
                          ? AppColors.primaryTint
                          : AppColors.badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      selesai
                          ? Icons.receipt_long_outlined
                          : Icons.soup_kitchen_outlined,
                      color: selesai ? AppColors.primary : AppColors.badgeText,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: AppText.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.waktuRingkas,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: AppText.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selesai
                          ? AppColors.primaryTint
                          : AppColors.badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: AppText.w700,
                        color: selesai
                            ? AppColors.primary
                            : AppColors.badgeText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s10),
              Text(
                order.lines
                    .map((line) => '${line.jumlah}× ${line.nama}')
                    .join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: AppText.w400,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.cabang,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: AppText.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    formatRupiah(order.total),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: AppText.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
