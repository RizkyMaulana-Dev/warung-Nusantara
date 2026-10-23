import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../state/order_store.dart';
import '../../widgets/button.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/order_card.dart';
import '../cabang/cabang_model.dart';
import '../riwayat/riwayat_pesanan_page.dart';
import '../tracking/tracking_page.dart';

/// Tab Pesanan: pesanan aktif dan riwayat terakhir.
class PesananPage extends StatelessWidget {
  final Cabang? cabangTerpilih;
  final VoidCallback? onPesanMenu;

  const PesananPage({super.key, this.cabangTerpilih, this.onPesanMenu});

  void _bukaDetail(BuildContext context, OrderData order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TrackingPage(pesanan: order, cabangTerpilih: cabangTerpilih),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const NotificationBell(
            backgroundColor: Colors.white,
            iconColor: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.s8),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s12),
            child: CartIconButton(
              cabangTerpilih: cabangTerpilih,
              backgroundColor: Colors.white,
              iconColor: AppColors.primary,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: OrderStore.instance,
        builder: (context, _) {
          final semua = OrderStore.instance.semua;
          if (semua.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum ada pesanan.',
              description: 'Pesanan yang kamu buat akan muncul di sini beserta statusnya.',
              actionText: onPesanMenu == null ? null : 'Pesan menu',
              onAction: onPesanMenu,
            );
          }

          final aktif = OrderStore.instance.aktif;
          final riwayat = OrderStore.instance.riwayat;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s20),
            children: [
              Text(
                'Pesanan aktif',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: AppText.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              if (aktif.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSize.listItemRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.s10),
                      Expanded(
                        child: Text(
                          'Tidak ada pesanan berjalan. Kamu bisa pesan menu lagi.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final order in aktif) ...[
                  OrderCard(
                    order: order,
                    onTap: () => _bukaDetail(context, order),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Riwayat pesanan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: AppText.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  AppTextLink(
                    text: 'Lihat semua',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RiwayatPesananPage(
                            cabangTerpilih: cabangTerpilih,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              if (riwayat.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                  child: Text(
                    'Pesanan yang sudah selesai akan tersimpan di sini.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                for (final order in riwayat.take(3)) ...[
                  OrderCard(
                    order: order,
                    onTap: () => _bukaDetail(context, order),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],
              if (onPesanMenu != null) ...[
                const SizedBox(height: AppSpacing.s12),
                SmallButton(text: 'Pesan menu lagi', onPressed: onPesanMenu),
              ],
            ],
          );
        },
      ),
    );
  }
}
