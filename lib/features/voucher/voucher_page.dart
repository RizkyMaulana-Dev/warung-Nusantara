import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/voucher_store.dart';
import '../../widgets/button.dart';

/// Daftar voucher promo. Kode bisa disalin dan voucher bisa dipakai
/// saat checkout.
class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  void _salin(BuildContext context, VoucherData voucher) {
    Clipboard.setData(ClipboardData(text: voucher.kode));
    showAppMessage(context, 'Kode ${voucher.kode} disalin.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher & Promo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: VoucherStore.instance,
        builder: (context, _) {
          final dipilih = VoucherStore.instance.dipilih;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s20),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppSize.cardRadius),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer,
                      color: AppColors.primary,
                      size: 26,
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hemat lebih banyak',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: AppText.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pilih satu voucher, lalu pakai saat checkout.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: AppText.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (dipilih != null) ...[
                const SizedBox(height: AppSpacing.s12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s14,
                    vertical: AppSpacing.s10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppColors.badgeText,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          'Voucher ${dipilih.kode} siap dipakai.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: AppText.w600,
                            color: AppColors.badgeText,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => VoucherStore.instance.hapus(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.badgeText,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Lepas'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.s20),
              for (final voucher in VoucherStore.instance.semua) ...[
                _buildVoucher(context, voucher, dipilih?.kode == voucher.kode),
                const SizedBox(height: AppSpacing.s12),
              ],
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Satu pesanan hanya bisa memakai satu voucher.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: AppText.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVoucher(
    BuildContext context,
    VoucherData voucher,
    bool terpilih,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
        border: Border.all(
          color: terpilih ? AppColors.primary : AppColors.divider,
          width: terpilih ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.judul,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: AppText.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      voucher.keterangan,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: AppText.w400,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        voucher.kode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: AppText.w800,
                          letterSpacing: 0.4,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      'Min. ${formatRupiah(voucher.minimalBelanja)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: AppText.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Salin kode',
                icon: const Icon(
                  Icons.copy,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => _salin(context, voucher),
                constraints: const BoxConstraints(
                  minWidth: AppSize.touchTarget,
                  minHeight: AppSize.touchTarget,
                ),
              ),
              const SizedBox(width: AppSpacing.s4),
              SmallButton(
                text: terpilih ? 'Dipakai' : 'Pakai',
                backgroundColor: terpilih
                    ? AppColors.primary
                    : AppColors.primaryTint,
                textColor: terpilih ? Colors.white : AppColors.primary,
                onPressed: terpilih
                    ? null
                    : () {
                        VoucherStore.instance.pilih(voucher);
                        showAppMessage(
                          context,
                          'Voucher ${voucher.kode} dipakai saat checkout.',
                        );
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
