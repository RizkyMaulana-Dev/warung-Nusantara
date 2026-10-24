import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/metode_bayar_store.dart';
import '../../widgets/button.dart';
import '../../widgets/empty_state.dart';

/// Metode pembayaran tersimpan: pilih utama, tambah, ubah, dan hapus.
class MetodePembayaranPage extends StatelessWidget {
  const MetodePembayaranPage({super.key});

  IconData _ikon(String nama) {
    final teks = nama.toLowerCase();
    if (teks.contains('qris')) return Icons.qr_code_2;
    if (teks.contains('transfer') || teks.contains('bank')) {
      return Icons.account_balance_outlined;
    }
    if (teks.contains('tempat') || teks.contains('tunai')) {
      return Icons.payments_outlined;
    }
    return Icons.credit_card;
  }

  Future<void> _bukaFormMetode(
    BuildContext context, {
    MetodeBayarData? metode,
  }) async {
    final hasil = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _MetodeFormDialog(metode: metode),
    );

    if (hasil != null) {
      if (metode == null) {
        MetodeBayarStore.instance.tambah(
          nama: hasil['nama']!,
          detail: hasil['detail']!,
        );
      } else {
        MetodeBayarStore.instance.ubah(
          id: metode.id,
          nama: hasil['nama']!,
          detail: hasil['detail']!,
        );
      }
      if (context.mounted) {
        showAppMessage(
          context,
          metode == null
              ? 'Metode pembayaran disimpan.'
              : 'Metode pembayaran diperbarui.',
        );
      }
    }
  }

  Future<void> _hapus(BuildContext context, MetodeBayarData metode) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus metode?'),
        content: Text('${metode.nama} akan dihapus dari daftar.'),
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
      MetodeBayarStore.instance.hapus(metode.id);
      if (context.mounted) {
        showAppMessage(context, 'Metode pembayaran dihapus.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode pembayaran'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: MetodeBayarStore.instance,
        builder: (context, _) {
          final daftar = MetodeBayarStore.instance.daftar;
          if (daftar.isEmpty) {
            return const EmptyState(
              icon: Icons.credit_card_off_outlined,
              title: 'Belum ada metode pembayaran.',
              description:
                  'Tambahkan metode supaya kamu bisa menyelesaikan pesanan.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s20),
            itemCount: daftar.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) {
              final metode = daftar[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.s14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSize.listItemRadius),
                  border: Border.all(
                    color: metode.utama ? AppColors.primary : AppColors.divider,
                    width: metode.utama ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _ikon(metode.nama),
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  metode.nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: AppText.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              if (metode.utama) ...[
                                const SizedBox(width: AppSpacing.s6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Utama',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: AppText.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            metode.detail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: AppText.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (!metode.utama)
                            TextButton(
                              onPressed: () {
                                MetodeBayarStore.instance.jadikanUtama(
                                  metode.id,
                                );
                                showAppMessage(
                                  context,
                                  '${metode.nama} jadi metode utama.',
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text('Jadikan utama'),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ubah metode',
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => _bukaFormMetode(context, metode: metode),
                      constraints: const BoxConstraints(
                        minWidth: AppSize.touchTarget,
                        minHeight: AppSize.touchTarget,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hapus metode',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: () => _hapus(context, metode),
                      constraints: const BoxConstraints(
                        minWidth: AppSize.touchTarget,
                        minHeight: AppSize.touchTarget,
                      ),
                    ),
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
          text: 'Tambah metode',
          onPressed: () => _bukaFormMetode(context),
        ),
      ),
    );
  }
}

class _MetodeFormDialog extends StatefulWidget {
  final MetodeBayarData? metode;

  const _MetodeFormDialog({this.metode});

  @override
  State<_MetodeFormDialog> createState() => _MetodeFormDialogState();
}

class _MetodeFormDialogState extends State<_MetodeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _detailController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.metode?.nama ?? '');
    _detailController = TextEditingController(
      text: widget.metode?.detail ?? '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.metode == null ? 'Tambah metode' : 'Ubah metode'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nama metode',
                  hintText: 'Contoh: Dompet digital',
                ),
                validator: (nilai) {
                  if (nilai == null || nilai.trim().isEmpty) {
                    return 'Isi nama metode dulu, ya.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              TextFormField(
                controller: _detailController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  hintText: 'Contoh: Saldo dompet digital',
                ),
                validator: (nilai) {
                  if (nilai == null || nilai.trim().isEmpty) {
                    return 'Isi keterangan singkat dulu, ya.';
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
                'nama': _namaController.text.trim(),
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
