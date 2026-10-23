import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/pengaturan_store.dart';

/// Pengaturan notifikasi dan preferensi aplikasi.
class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final PengaturanStore _store = PengaturanStore.instance;

  void _ubahPromo(bool nilai) {
    _store.setNotifPromo(nilai);
    setState(() {});
  }

  void _ubahPesanan(bool nilai) {
    _store.setNotifPesanan(nilai);
    setState(() {});
  }

  void _ubahHematData(bool nilai) {
    _store.setHematData(nilai);
    setState(() {});
    showAppMessage(
      context,
      nilai ? 'Mode hemat data aktif.' : 'Mode hemat data dimatikan.',
    );
  }

  void _bukaInfo(String judul, String isi) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(judul),
        content: SingleChildScrollView(
          child: Text(
            isi,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        children: [
          _judulBagian('Notifikasi'),
          _buildSwitch(
            title: 'Promo dan voucher',
            subtitle: 'Info diskon terbaru dari warung.',
            value: _store.notifPromo,
            onChanged: _ubahPromo,
          ),
          _buildSwitch(
            title: 'Status pesanan',
            subtitle: 'Kabar saat pesanan dikonfirmasi dan diantar.',
            value: _store.notifPesanan,
            onChanged: _ubahPesanan,
          ),
          const SizedBox(height: AppSpacing.s20),
          _judulBagian('Aplikasi'),
          _buildSwitch(
            title: 'Hemat data',
            subtitle: 'Muat gambar menu dengan kualitas lebih ringan.',
            value: _store.hematData,
            onChanged: _ubahHematData,
          ),
          const SizedBox(height: AppSpacing.s8),
          _buildInfoTile(
            icon: Icons.info_outline,
            title: 'Tentang aplikasi',
            onTap: () => _bukaInfo(
              'Warung Nusantara',
              'Aplikasi pemesanan makanan untuk UMKM lokal. '
                  'Pesan menu favorit, pilih cabang terdekat, dan pantau '
                  'status pesanan langsung dari HP.\n\nVersi 1.0.3',
            ),
          ),
          _buildInfoTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan privasi',
            onTap: () => _bukaInfo(
              'Kebijakan privasi',
              'Kami hanya menyimpan nama, nomor HP, dan alamat yang kamu '
                  'isikan untuk keperluan pengantaran pesanan. Data tidak '
                  'dibagikan ke pihak lain tanpa izinmu.',
            ),
          ),
          const Divider(height: 32, color: AppColors.divider),
          Text(
            'Versi aplikasi 1.0.3',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: AppText.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _judulBagian(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s4),
      child: Text(
        teks,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: AppText.w800,
          color: AppColors.text,
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: AppText.w600,
          color: AppColors.text,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: AppText.w400,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: AppText.w400,
          color: AppColors.text,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 20,
      ),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
