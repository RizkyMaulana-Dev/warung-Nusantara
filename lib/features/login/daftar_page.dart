import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../widgets/button.dart';
import '../cabang/cabang_model.dart';
import '../main/main_shell.dart';

/// Form pendaftaran akun baru.
class DaftarPage extends StatefulWidget {
  final Cabang? cabangTerpilih;

  const DaftarPage({super.key, this.cabangTerpilih});

  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _sandiController = TextEditingController();
  bool _setuju = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  String? _validasiEmail(String? nilai) {
    final teks = nilai?.trim() ?? '';
    if (teks.isEmpty) return 'Isi email dulu, ya.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(teks)) {
      return 'Format email belum benar. Contoh: nama@email.com.';
    }
    return null;
  }

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_setuju) {
      showAppMessage(
        context,
        'Centang persetujuan dulu supaya akun bisa dibuat.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_pengguna', _namaController.text.trim());
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('nomor_hp', _teleponController.text.trim());
    await prefs.setBool('is_logged_in', true);

    if (!mounted) return;

    showAppMessage(context, 'Akun berhasil dibuat. Selamat memesan!');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainShell(cabangTerpilih: widget.cabangTerpilih),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar akun'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Buat akun supaya pesananmu tersimpan.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: AppText.w400,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              TextFormField(
                controller: _namaController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  hintText: 'Contoh: Siti Rahma',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (nilai) {
                  if (nilai == null || nilai.trim().isEmpty) {
                    return 'Isi nama dulu, ya.';
                  }
                  if (nilai.trim().length < 2) {
                    return 'Nama terlalu pendek. Tulis nama lengkapmu.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s14),
              TextFormField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'nama@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _validasiEmail,
              ),
              const SizedBox(height: AppSpacing.s14),
              TextFormField(
                controller: _teleponController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  hintText: '0812xxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (nilai) {
                  final angka = (nilai ?? '').replaceAll(RegExp(r'\D'), '');
                  if (angka.isEmpty) return 'Isi nomor HP dulu, ya.';
                  if (angka.length < 10 || angka.length > 15) {
                    return 'Nomor HP belum pas. Gunakan 10–15 angka.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s14),
              TextFormField(
                controller: _sandiController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Kata sandi',
                  hintText: 'Minimal 8 karakter',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Buat kata sandi dulu, ya.';
                  }
                  if (nilai.length < 8) {
                    return 'Kata sandi minimal 8 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _setuju,
                    onChanged: (nilai) =>
                        setState(() => _setuju = nilai ?? false),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Saya setuju dengan syarat layanan dan kebijakan privasi Warung Nusantara.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: AppText.w400,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),
              PrimaryButton(
                text: 'Daftar sekarang',
                isLoading: _isLoading,
                onPressed: _daftar,
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppTextLink(
                    text: 'Masuk',
                    onPressed: () => Navigator.of(context).pop(),
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
