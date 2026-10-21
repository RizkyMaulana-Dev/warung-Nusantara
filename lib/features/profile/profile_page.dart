import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/voucher_store.dart';
import '../../widgets/button.dart';
import '../alamat/alamat_page.dart';
import '../bantuan/pusat_bantuan_page.dart';
import '../cabang/cabang_model.dart';
import '../cabang/cabang_page.dart';
import '../login/login_page.dart';
import '../pembayaran/metode_pembayaran_page.dart';
import '../pengaturan/pengaturan_page.dart';
import '../riwayat/riwayat_pesanan_page.dart';
import '../voucher/voucher_page.dart';

/// Akun / Profil: data pengguna, poin, dan pintasan ke halaman akun.
class ProfilePage extends StatefulWidget {
  final Cabang? cabangTerpilih;
  final ValueChanged<Cabang>? onGantiCabang;

  const ProfilePage({super.key, this.cabangTerpilih, this.onGantiCabang});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nama = 'Pengguna Contoh';
  String _nomorHP = '+62 812-3456-7890';
  int _poin = 120;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nama = prefs.getString('nama_pengguna') ?? 'Pengguna Contoh';
      _nomorHP =
          prefs.getString('nomor_hp') ??
          prefs.getString('email') ??
          '+62 812-3456-7890';
      _poin = prefs.getInt('poin') ?? 120;
    });
  }

  Future<void> _keluar() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: Text(AppMessages.keluarKonfirmasi),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          PrimaryButton(
            text: 'Keluar',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginPage(cabangTerpilih: widget.cabangTerpilih),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _ubahProfil() async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: _nama);
    final hpController = TextEditingController(text: _nomorHP);

    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah profil'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Isi nama dulu, ya.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                TextFormField(
                  controller: hpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor HP',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Isi nomor HP dulu, ya.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop({
                  'nama': namaController.text.trim(),
                  'hp': hpController.text.trim(),
                });
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (hasil != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nama_pengguna', hasil['nama']!);
      await prefs.setString('nomor_hp', hasil['hp']!);
      if (!mounted) return;
      setState(() {
        _nama = hasil['nama']!;
        _nomorHP = hasil['hp']!;
      });
      showAppMessage(context, 'Profil berhasil diperbarui.');
    }

    namaController.dispose();
    hpController.dispose();
  }

  Future<void> _tukarPoin() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tukar poin'),
        content: Text(
          _poin >= 100 ? 'Tukar 100 poin dengan voucher potongan Rp 10.000?' : 'Poin kamu belum cukup. Kumpulkan minimal 100 poin dengan terus memesan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Nanti'),
          ),
          if (_poin >= 100)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Tukar'),
            ),
        ],
      ),
    );

    if (konfirmasi == true) {
      setState(() => _poin -= 100);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('poin', _poin);
      VoucherStore.instance.tambahVoucherPoin();
      if (!mounted) return;
      showAppMessage(
        context,
        'Poin ditukar. Voucher Rp 10.000 ada di halaman Voucher.',
      );
    }
  }

  void _buka(Widget halaman) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => halaman));
  }

  Future<void> _gantiCabang() async {
    final cabang = await Navigator.of(context).push<Cabang>(
      MaterialPageRoute(
        builder: (_) => CabangPage(cabangAwal: widget.cabangTerpilih),
      ),
    );
    if (cabang == null || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cabang_id', cabang.id);

    if (!mounted) return;
    if (widget.onGantiCabang != null) {
      widget.onGantiCabang!(cabang);
    } else {
      showAppMessage(context, 'Cabang diganti ke ${cabang.nama}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryTint,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    _nama,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: AppText.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    _nomorHP,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: AppText.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (widget.cabangTerpilih != null) ...[
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      widget.cabangTerpilih!.nama,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: AppText.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s12),
                  SmallButton(text: 'Ubah', onPressed: _ubahProfil),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.accent, size: 32),
                  const SizedBox(width: AppSpacing.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Poin Loyalitas',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: AppText.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_poin poin',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: AppText.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SmallButton(
                    text: 'Tukar',
                    backgroundColor: AppColors.accent,
                    textColor: AppColors.onAccent,
                    onPressed: _tukarPoin,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Alamat tersimpan',
              onTap: () => _buka(const AlamatPage()),
            ),
            _buildMenuItem(
              icon: Icons.history_outlined,
              title: 'Riwayat pesanan',
              onTap: () => _buka(
                RiwayatPesananPage(cabangTerpilih: widget.cabangTerpilih),
              ),
            ),
            _buildMenuItem(
              icon: Icons.local_offer_outlined,
              title: 'Voucher dan promo',
              onTap: () => _buka(const VoucherPage()),
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Metode pembayaran',
              onTap: () => _buka(const MetodePembayaranPage()),
            ),
            _buildMenuItem(
              icon: Icons.storefront_outlined,
              title: 'Ganti cabang',
              onTap: _gantiCabang,
            ),
            _buildMenuItem(
              icon: Icons.help_outlined,
              title: 'Pusat bantuan',
              onTap: () => _buka(const PusatBantuanPage()),
            ),
            const Divider(height: 28, color: AppColors.divider),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              onTap: () => _buka(const PengaturanPage()),
            ),
            const SizedBox(height: AppSpacing.s24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _keluar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
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
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 12,
    );
  }
}
