import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/alamat_store.dart';
import '../../widgets/button.dart';
import '../../widgets/empty_state.dart';

/// Daftar alamat pengantaran yang bisa ditambah, dijadikan utama, atau dihapus.
class AlamatPage extends StatelessWidget {
  const AlamatPage({super.key});

  Future<void> _tambahAlamat(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final labelController = TextEditingController();
    final detailController = TextEditingController();

    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah alamat'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: labelController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Label alamat',
                    hintText: 'Contoh: Rumah',
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Isi label dulu, ya.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                TextFormField(
                  controller: detailController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Alamat lengkap',
                    hintText: 'Jalan, nomor rumah, patokan',
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Isi alamat lengkap dulu, ya.';
                    }
                    if (nilai.trim().length < 10) {
                      return 'Tulis alamat lebih lengkap supaya kurir mudah menemukan.';
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
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (hasil == true) {
      AlamatStore.instance.tambah(
        label: labelController.text,
        detail: detailController.text,
      );
      if (context.mounted) {
        showAppMessage(context, 'Alamat baru disimpan.');
      }
    }

    labelController.dispose();
    detailController.dispose();
  }

  Future<void> _hapus(BuildContext context, AlamatData alamat) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus alamat?'),
        content: Text('${alamat.label} akan dihapus dari daftar alamatmu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (yakin == true) {
      AlamatStore.instance.hapus(alamat.id);
      if (context.mounted) {
        showAppMessage(context, 'Alamat dihapus.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alamat tersimpan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: AlamatStore.instance,
        builder: (context, _) {
          final daftar = AlamatStore.instance.daftar;
          if (daftar.isEmpty) {
            return const EmptyState(
              icon: Icons.location_on_outlined,
              title: 'Belum ada alamat.',
              description:
                  'Tambahkan alamat pengantaran supaya pesananmu bisa diantar.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s20),
            itemCount: daftar.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) {
              final alamat = daftar[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSize.listItemRadius),
                  border: Border.all(
                    color: alamat.utama ? AppColors.primary : AppColors.divider,
                    width: alamat.utama ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Text(
                            alamat.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: AppText.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (alamat.utama)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Utama',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: AppText.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        const SizedBox(width: AppSpacing.s4),
                        IconButton(
                          tooltip: 'Hapus alamat',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () => _hapus(context, alamat),
                          constraints: const BoxConstraints(
                            minWidth: AppSize.touchTarget,
                            minHeight: AppSize.touchTarget,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      alamat.detail,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: AppText.w400,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (!alamat.utama) ...[
                      const SizedBox(height: AppSpacing.s8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            AlamatStore.instance.jadikanUtama(alamat.id);
                            showAppMessage(
                              context,
                              '${alamat.label} jadi alamat utama.',
                            );
                          },
                          child: const Text('Jadikan utama'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s8,
          AppSpacing.s20,
          AppSpacing.s16,
        ),
        child: PrimaryButton(
          text: 'Tambah alamat',
          onPressed: () => _tambahAlamat(context),
        ),
      ),
    );
  }
}
