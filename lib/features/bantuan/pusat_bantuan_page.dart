import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../widgets/button.dart';

/// Pusat bantuan berisi FAQ singkat dan kontak warung.
class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  static const List<Map<String, String>> _faq = [
    {
      'tanya': 'Bagaimana cara memesan?',
      'jawab': 'Buka tab Menu, pilih makanan, atur topping, lalu ketuk Tambah ke keranjang. Setelah itu buka keranjang dan ketuk Checkout.',
    },
    {
      'tanya': 'Bagaimana mengubah alamat pengantaran?',
      'jawab': 'Buka Akun > Alamat tersimpan. Kamu bisa menambah alamat baru atau menjadikan alamat lain sebagai alamat utama.',
    },
    {
      'tanya': 'Metode pembayaran apa saja yang tersedia?',
      'jawab': 'Kami menerima QRIS, transfer bank, dan bayar di tempat. Kamu bisa menambah metode lain di Akun > Metode pembayaran.',
    },
    {
      'tanya': 'Pesanan saya belum datang. Apa yang harus dilakukan?',
      'jawab': 'Buka tab Pesanan untuk melihat status terbaru. Jika status sudah Diantar, tunggu 10 menit lagi. Bila masih belum tiba, hubungi warung lewat tombol di bawah.',
    },
    {
      'tanya': 'Apakah bisa memilih cabang lain?',
      'jawab': 'Bisa. Buka Akun > Ganti cabang, lalu pilih cabang yang kamu inginkan. Menu dan ongkir akan mengikuti cabang tersebut.',
    },
  ];

  void _salin(BuildContext context, String teks, String pesan) {
    Clipboard.setData(ClipboardData(text: teks));
    showAppMessage(context, pesan);
  }

  static const String _nomorWhatsApp = '6281234567890';
  static const String _nomorWhatsAppTampil = '+62 812-3456-7890';
  static const String _pesanWhatsApp =
      'Halo Warung Nusantara, saya mau bertanya soal pesanan saya.';

  /// Buka chat WhatsApp lewat tautan wa.me. Kalau tautan tidak bisa dibuka sama
  /// sekali, nomor warung disalin dan pengguna diarahkan ke WhatsApp Web atau
  /// telepon supaya tetap bisa menghubungi warung.
  Future<void> _chatWhatsApp(BuildContext context) async {
    final uri = Uri.https('wa.me', '/$_nomorWhatsApp', {
      'text': _pesanWhatsApp,
    });
    var terbuka = false;
    try {
      terbuka = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      terbuka = false;
    }
    if (!context.mounted || terbuka) return;
    // Salin dulu sampai selesai, baru beri tahu: pesannya mengklaim nomor
    // sudah tersalin, jadi klaim itu harus benar.
    await Clipboard.setData(const ClipboardData(text: _nomorWhatsAppTampil));
    if (!context.mounted) return;
    showAppMessage(context, AppMessages.gagalBukaWhatsApp, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat bantuan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        children: [
          Text(
            'Pertanyaan yang sering muncul',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: AppText.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSize.listItemRadius),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < _faq.length; i++) ...[
                  ExpansionTile(
                    title: Text(
                      _faq[i]['tanya']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: AppText.w700,
                        color: AppColors.text,
                      ),
                    ),
                    iconColor: AppColors.primary,
                    collapsedIconColor: AppColors.textSecondary,
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      0,
                      AppSpacing.s16,
                      AppSpacing.s16,
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _faq[i]['jawab']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: AppText.w400,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (i < _faq.length - 1)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Text(
            'Masih butuh bantuan?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: AppText.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppSize.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warung Nusantara siap membantu setiap hari, 08.00–21.00.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: AppText.w400,
                    height: 1.5,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                SecondaryButton(
                  text: 'Chat WhatsApp',
                  onPressed: () => _chatWhatsApp(context),
                ),
                const SizedBox(height: AppSpacing.s10),
                SmallButton(
                  text: 'Salin email bantuan',
                  onPressed: () => _salin(
                    context,
                    'bantuan@warungnusantara.id',
                    'Email bantuan disalin.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
