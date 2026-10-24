import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/alamat_store.dart';
import '../../widgets/button.dart';
import '../../widgets/empty_state.dart';

/// Daftar alamat pengantaran yang bisa ditambah, diubah, dijadikan utama,
/// atau dihapus.
class AlamatPage extends StatelessWidget {
  const AlamatPage({super.key});

  Future<void> _bukaFormAlamat(
    BuildContext context, {
    AlamatData? alamat,
  }) async {
    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _AlamatFormDialog(alamat: alamat),
    );

    if (hasil != null) {
      if (alamat == null) {
        AlamatStore.instance.tambah(
          label: hasil['label']!,
          detail: hasil['detail']!,
        );
      } else {
        AlamatStore.instance.ubah(
          id: alamat.id,
          label: hasil['label']!,
          detail: hasil['detail']!,
        );
      }
      if (context.mounted) {
        showAppMessage(
          context,
          alamat == null ? 'Alamat baru disimpan.' : 'Alamat diperbarui.',
        );
      }
    }
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
                          tooltip: 'Ubah alamat',
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () =>
                              _bukaFormAlamat(context, alamat: alamat),
                          constraints: const BoxConstraints(
                            minWidth: AppSize.touchTarget,
                            minHeight: AppSize.touchTarget,
                          ),
                        ),
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
          onPressed: () => _bukaFormAlamat(context),
        ),
      ),
    );
  }
}

class _AlamatFormDialog extends StatefulWidget {
  final AlamatData? alamat;

  const _AlamatFormDialog({this.alamat});

  @override
  State<_AlamatFormDialog> createState() => _AlamatFormDialogState();
}

class _AlamatFormDialogState extends State<_AlamatFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _detailController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.alamat?.label ?? '');
    _detailController = TextEditingController(
      text: widget.alamat?.detail ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.alamat == null ? 'Tambah alamat' : 'Ubah alamat'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _labelController,
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
                controller: _detailController,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop({
                'label': _labelController.text.trim(),
                'detail': _detailController.text.trim(),
              });
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
