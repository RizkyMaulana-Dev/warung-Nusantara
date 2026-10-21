import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/order_store.dart';
import '../../widgets/button.dart';
import '../cabang/cabang_model.dart';
import '../main/main_shell.dart';

/// Lacak pesanan: ringkasan, linimasa, dan tombol konfirmasi pesanan tiba.
class TrackingPage extends StatelessWidget {
  final OrderData pesanan;
  final Cabang? cabangTerpilih;

  const TrackingPage({super.key, required this.pesanan, this.cabangTerpilih});

  OrderData _terbaru() {
    for (final order in OrderStore.instance.semua) {
      if (order.id == pesanan.id) return order;
    }
    return pesanan;
  }

  int _tahapAktif(OrderData order) => order.tahapAktif;

  String _jam(OrderData order, int index) {
    // Saat masih berjalan, hanya tahap yang sudah selesai yang diberi jam;
    // tahap yang sedang berjalan dan setelahnya masih '-'.
    if (index >= order.tahapAktif) return '-';

    const jedaMenit = [0, 5, 12, 20, 28];
    final waktu = order.waktu.add(Duration(minutes: jedaMenit[index]));
    String dua(int nilai) => nilai.toString().padLeft(2, '0');
    return '${dua(waktu.hour)}.${dua(waktu.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: OrderStore.instance,
      builder: (context, _) {
        final order = _terbaru();
        final aktif = !order.selesai;
        final tahapAktif = _tahapAktif(order);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail pesanan'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s8,
            ),
            children: [
              _buildStatus(order, aktif),
              const SizedBox(height: AppSpacing.s16),
              _buildLinimasa(order, tahapAktif),
              const SizedBox(height: AppSpacing.s16),
              _buildRincian(order),
              const SizedBox(height: AppSpacing.s16),
              _buildPengantaran(order),
              const SizedBox(height: AppSpacing.s16),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s8,
              AppSpacing.s20,
              AppSpacing.s16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (aktif) ...[
                  SecondaryButton(
                    text: 'Lihat posisi kurir',
                    onPressed: () {
                      showAppMessage(
                        context,
                        'Peta kurir belum aktif. Pantau status pesanan di halaman ini.',
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  PrimaryButton(
                    text: 'Pesanan sudah diterima',
                    onPressed: () {
                      OrderStore.instance.selesaikan(order.id);
                      showAppMessage(
                        context,
                        'Pesanan ditandai selesai. Terima kasih!',
                      );
                    },
                  ),
                ] else
                  PrimaryButton(
                    text: 'Kembali ke beranda',
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) =>
                              MainShell(cabangTerpilih: cabangTerpilih),
                        ),
                        (route) => false,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatus(OrderData order, bool aktif) {
    final statusJudul = order.selesai
        ? 'Pesanan selesai'
        : order.status == 'Diantar kurir'
        ? 'Pesanan sedang diantar'
        : 'Pesanan sedang diproses';
    final statusKeterangan = order.selesai
        ? 'Terima kasih sudah memesan di Warung Nusantara.'
        : order.status == 'Diantar kurir'
        ? 'Kurir sedang membawa pesananmu ke alamat tujuan.'
        : 'Perkiraan tiba 20\u201330 menit lagi.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              order.selesai
                  ? Icons.check_circle_outline
                  : order.status == 'Diantar kurir'
                  ? Icons.delivery_dining
                  : Icons.soup_kitchen_outlined,
              color: AppColors.accent,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusJudul,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: AppText.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  statusKeterangan,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: AppText.w400,
                    height: 1.4,
                    color: AppColors.onPrimaryMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinimasa(OrderData order, int tahapAktif) {
    final tahap = [
      {
        'judul': 'Pesanan dibuat',
        'keterangan': 'Pesanan kamu sudah diterima warung.',
      },
      {
        'judul': 'Dikonfirmasi',
        'keterangan': 'Warung menyiapkan bahan pesananmu.',
      },
      {
        'judul': 'Sedang dimasak',
        'keterangan': 'Makanan sedang dimasak, sebentar lagi siap.',
      },
      {
        'judul': 'Diantar kurir',
        'keterangan': 'Pesanan dalam perjalanan ke alamatmu.',
      },
      {
        'judul': 'Pesanan tiba',
        'keterangan': 'Pesanan sampai dan siap disantap.',
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status pesanan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: AppText.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          for (var i = 0; i < tahap.length; i++)
            _buildTahap(
              judul: tahap[i]['judul']!,
              keterangan: tahap[i]['keterangan']!,
              jam: _jam(order, i),
              status: i < tahapAktif
                  ? 'selesai'
                  : i == tahapAktif
                  ? 'berjalan'
                  : 'berikutnya',
              isLast: i == tahap.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildTahap({
    required String judul,
    required String keterangan,
    required String jam,
    required String status,
    required bool isLast,
  }) {
    final selesai = status == 'selesai';
    final berjalan = status == 'berjalan';

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Text(
                jam,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: AppText.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selesai
                    ? AppColors.primary
                    : berjalan
                    ? AppColors.accent
                    : Colors.white,
                shape: BoxShape.circle,
                border: selesai || berjalan
                    ? null
                    : Border.all(color: const Color(0xFFC9D0CB), width: 2),
              ),
              child: selesai
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : berjalan
                  ? const Icon(
                      Icons.more_horiz,
                      size: 14,
                      color: AppColors.onAccent,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.s10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: AppText.w700,
                        color: berjalan ? AppColors.badgeText : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      keterangan,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: AppText.w400,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 55, bottom: AppSpacing.s6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 2,
                height: 16,
                color: selesai ? AppColors.primary : const Color(0xFFC9D0CB),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRincian(OrderData order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rincian pesanan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: AppText.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                order.id,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: AppText.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          for (final line in order.lines) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${line.jumlah}×',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: AppText.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.nama,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: AppText.w600,
                          color: AppColors.text,
                        ),
                      ),
                      if (line.opsi.isNotEmpty)
                        Text(
                          line.opsi,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: AppText.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  formatRupiah(line.subtotal),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: AppText.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s10),
          ],
          const Divider(height: 16, color: AppColors.divider),
          _barisRingkas('Subtotal', order.subtotal),
          const SizedBox(height: 4),
          _barisRingkas('Ongkir', order.ongkir),
          if (order.diskon > 0) ...[
            const SizedBox(height: 4),
            _barisRingkas(
              'Diskon voucher',
              -order.diskon,
              warna: AppColors.primary,
            ),
          ],
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: AppText.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              Text(
                formatRupiah(order.total),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: AppText.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barisRingkas(String label, int nilai, {Color? warna}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: AppText.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          nilai < 0 ? '-${formatRupiah(-nilai)}' : formatRupiah(nilai),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: AppText.w600,
            color: warna ?? AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildPengantaran(OrderData order) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengantaran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: AppText.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          _barisInfo(Icons.location_on_outlined, order.alamat),
          const SizedBox(height: AppSpacing.s8),
          _barisInfo(Icons.store_outlined, order.cabang),
          const SizedBox(height: AppSpacing.s8),
          _barisInfo(Icons.payment_outlined, order.pembayaran),
        ],
      ),
    );
  }

  Widget _barisInfo(IconData icon, String teks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            teks,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
