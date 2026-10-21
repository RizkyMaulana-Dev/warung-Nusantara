import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../widgets/button.dart';

/// Form permintaan tautan reset kata sandi.
class LupaSandiPage extends StatefulWidget {
  const LupaSandiPage({super.key});

  @override
  State<LupaSandiPage> createState() => _LupaSandiPageState();
}

class _LupaSandiPageState extends State<LupaSandiPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showAppMessage(
      context,
      'Tautan reset dikirim. Cek kotak masuk emailmu, ya.',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa kata sandi'),
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
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              Text(
                'Masukkan email akunmu',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: AppText.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Kami akan mengirim tautan untuk membuat kata sandi baru. '
                'Tautan berlaku selama 30 menit.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: AppText.w400,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'nama@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (nilai) {
                  final teks = nilai?.trim() ?? '';
                  if (teks.isEmpty) return 'Isi email dulu, ya.';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(teks)) {
                    return 'Format email belum benar. Contoh: nama@email.com.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s20),
              PrimaryButton(
                text: 'Kirim tautan reset',
                isLoading: _isLoading,
                onPressed: _kirim,
              ),
              const SizedBox(height: AppSpacing.s16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali ke halaman masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
