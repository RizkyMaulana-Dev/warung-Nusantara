import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../widgets/button.dart';
import '../cabang/cabang_model.dart';
import '../main/main_shell.dart';
import 'daftar_page.dart';
import 'lupa_sandi_page.dart';

/// Login halaman: email/nomor HP dan kata sandi.
class LoginPage extends StatefulWidget {
  /// Cabang yang dipilih sebelumnya (opsional).
  final Cabang? cabangTerpilih;

  const LoginPage({super.key, this.cabangTerpilih});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sandiController = TextEditingController();
  bool _isLoading = false;
  bool _ingatSaya = false;

  @override
  void initState() {
    super.initState();
    _muatPreferensi();
  }

  Future<void> _muatPreferensi() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final ingat = prefs.getBool('ingat_saya') ?? false;
    setState(() {
      _ingatSaya = ingat;
      if (ingat) {
        _emailController.text = prefs.getString('email_tersimpan') ?? '';
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulasi login (ganti dengan API sebenarnya)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Simulasi sukses (ganti validasi asli)
    final prefs = await SharedPreferences.getInstance();
    final email = _emailController.text.trim();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('email', email);
    await prefs.setBool('ingat_saya', _ingatSaya);
    if (_ingatSaya) {
      await prefs.setString('email_tersimpan', email);
    } else {
      await prefs.remove('email_tersimpan');
    }
    final namaTersimpan = prefs.getString('nama_pengguna');
    if (namaTersimpan == null || namaTersimpan.trim().isEmpty) {
      await prefs.setString('nama_pengguna', 'Pengguna Contoh');
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainShell(cabangTerpilih: widget.cabangTerpilih),
      ),
    );
  }

  Future<void> _masukGoogle() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    final namaTersimpan = prefs.getString('nama_pengguna');
    if (namaTersimpan == null || namaTersimpan.trim().isEmpty) {
      await prefs.setString('nama_pengguna', 'Pengguna Google');
    }
    final email = _emailController.text.trim();
    await prefs.setString(
      'email',
      email.isEmpty ? 'pengguna@gmail.com' : email,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainShell(cabangTerpilih: widget.cabangTerpilih),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selamat datang kembali'),
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
              const SizedBox(height: AppSpacing.s24),
              // Kolom Email atau nomor HP
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email atau nomor HP',
                  hintText: 'Masukkan email atau nomor HP',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppMessages.kolomWajibDiisi;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s14),
              // Kolom Kata sandi
              TextFormField(
                controller: _sandiController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Kata sandi',
                  hintText: 'Masukkan kata sandi',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppMessages.kolomWajibDiisi;
                  }
                  if (value.length < 8) {
                    return AppMessages.sandiTerlaluPendek;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s10),
              // Simpan kata sandi
              Row(
                children: [
                  Checkbox(
                    value: _ingatSaya,
                    onChanged: (v) => setState(() => _ingatSaya = v ?? false),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ingat saya',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: AppText.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s10),
              AppTextLink(
                text: 'Lupa kata sandi?',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LupaSandiPage()),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s28),
              // Tombol Masuk
              PrimaryButton(
                text: 'Masuk',
                isLoading: _isLoading,
                onPressed: _masuk,
              ),
              const SizedBox(height: AppSpacing.s16),
              // Tombol Google
              OutlinedButton.icon(
                icon: const Icon(Icons.g_mobiledata, size: 20),
                label: const Text('Masuk dengan Google'),
                onPressed: _isLoading ? null : _masukGoogle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    AppSize.buttonHeight,
                  ),
                  side: const BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.buttonRadius),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              // Tautan Daftar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: AppText.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppTextLink(
                    text: 'Daftar',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DaftarPage(cabangTerpilih: widget.cabangTerpilih),
                        ),
                      );
                    },
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
