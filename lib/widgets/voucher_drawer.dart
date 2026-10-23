import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../state/cart_store.dart';
import '../state/voucher_store.dart';
import '../widgets/button.dart';

/// Drawer bawah: daftar voucher yang bisa dipilih, plus ringkasan
/// subtotal & biaya lain. Bisa digeser manual (drag handle di atas).
class VoucherDrawer extends StatelessWidget {
  final CartStore cart;

  const VoucherDrawer({super.key, required this.cart});

  Future<void> _pilih(BuildContext context, VoucherData voucher,
      {bool lagi = false}) async {
    if (lagi) {
      VoucherStore.instance.hapus();
    } else {
      VoucherStore.instance.pilih(voucher);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.42,
      maxChildSize: 0.9,
      expand: false,
      // Indikator drag: pegangan di atas supaya jelas bisa digeser.
      builder: (context, scrollController) {
        return AnimatedBuilder(
          animation: VoucherStore.instance,
          builder: (context, _) {
            final dipilih = VoucherStore.instance.dipilih;
            final subtotal = cart.subtotal;
            final ongkir = cart.ongkir;
            final diskon = VoucherStore.instance.hitungDiskon(subtotal);
            final total = subtotal + ongkir - diskon;

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Drag handle (indikator bisa digeser manual).
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s10),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // Ringkasan subtotal + biaya lain
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan biaya',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: AppText.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        _baris('Subtotal', formatRupiah(subtotal)),
                        _baris('Ongkir', '+${formatRupiah(ongkir)}'),
                        if (diskon > 0)
                          _baris(
                            'Diskon voucher',
                            '-${formatRupiah(diskon)}',
                            warna: AppColors.primary,
                          ),
                        const SizedBox(height: AppSpacing.s6),
                        _baris('Total', formatRupiah(total), tebal: true),
                      ],
                    ),
                  ),
                  const Divider(height: AppSpacing.s16),
                  // Daftar voucher
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s20,
                          vertical: AppSpacing.s8),
                      children: [
                        for (final voucher
                            in VoucherStore.instance.semua)
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.s10),
                            child: _barisVoucher(
                              voucher,
                              terpilih: dipilih?.kode == voucher.kode,
                              onPilih: () => _pilih(context, voucher),
                              onLepas: () => _pilih(context, voucher,
                                  lagi: true),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _baris(String label, String nilai,
      {bool tebal = false, Color warna = AppColors.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: tebal ? 14 : 12,
                fontWeight: tebal ? AppText.w800 : AppText.w400,
                color: tebal ? AppColors.text : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            nilai,
            style: GoogleFonts.plusJakartaSans(
              fontSize: tebal ? 15 : 12,
              fontWeight: tebal ? AppText.w800 : AppText.w600,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barisVoucher(
    VoucherData voucher, {
    required bool terpilih,
    required VoidCallback onPilih,
    required VoidCallback onLepas,
  }) {
    final layak =
        cart.subtotal >= voucher.minimalBelanja;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSize.listItemRadius),
        border: Border.all(
          color: terpilih ? AppColors.primary : AppColors.divider,
          width: terpilih ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.judul,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: AppText.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  layak
                      ? 'Kode ${voucher.kode} · Min. ${formatRupiah(voucher.minimalBelanja)}'
                      : 'Kode ${voucher.kode} · Butuh ${formatRupiah(voucher.minimalBelanja - cart.subtotal)} lagi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: AppText.w400,
                    color: layak
                        ? AppColors.textSecondary
                        : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          terpilih
              ? SmallButton(
                  text: 'Lepas',
                  backgroundColor: AppColors.surfaceSoft,
                  textColor: AppColors.textSecondary,
                  onPressed: onLepas,
                )
              : SmallButton(
                  text: 'Pakai',
                  onPressed: layak ? onPilih : null,
                ),
        ],
      ),
    );
  }
}

/// Buka drawer voucher di atas layar aktif.
void bukaVoucherDrawer(BuildContext context, CartStore cart) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => VoucherDrawer(cart: cart),
  );
}
