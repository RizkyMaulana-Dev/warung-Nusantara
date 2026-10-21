import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../data/menu_data.dart';
import '../../state/cart_store.dart';
import '../../widgets/app_image.dart';
import '../../widgets/bottom_action_bar.dart';
import '../cabang/cabang_model.dart';
import '../cart/cart_page.dart';

/// Detail menu: gambar, deskripsi, topping/addon, jumlah, dan catatan.
class DetailMenuPage extends StatefulWidget {
  final MenuProduk menu;
  final Cabang? cabangTerpilih;

  const DetailMenuPage({super.key, required this.menu, this.cabangTerpilih});

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  final Map<String, Set<String>> _pilihan = {};
  final TextEditingController _catatanController = TextEditingController();
  int _jumlah = 1;

  MenuProduk get _menu => widget.menu;

  @override
  void initState() {
    super.initState();
    for (final grup in _menu.addon) {
      if (!grup.multiPilih && grup.opsi.isNotEmpty) {
        _pilihan[grup.id] = {grup.opsiAwal.id};
      }
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  List<AddonOption> get _addonTerpilih {
    final hasil = <AddonOption>[];
    for (final grup in _menu.addon) {
      final dipilih = _pilihan[grup.id] ?? <String>{};
      for (final opsi in grup.opsi) {
        if (dipilih.contains(opsi.id)) hasil.add(opsi);
      }
    }
    return hasil;
  }

  int get _hargaSatuan =>
      _menu.harga + _addonTerpilih.fold(0, (total, opsi) => total + opsi.harga);

  int get _total => _hargaSatuan * _jumlah;

  bool _wajibLengkap() {
    for (final grup in _menu.addon) {
      if (grup.wajib && (_pilihan[grup.id] ?? const <String>{}).isEmpty) {
        return false;
      }
    }
    return true;
  }

  void _pilih(AddonGroup grup, AddonOption opsi) {
    setState(() {
      final terpilih = _pilihan.putIfAbsent(grup.id, () => <String>{});
      if (grup.multiPilih) {
        if (terpilih.contains(opsi.id)) {
          terpilih.remove(opsi.id);
        } else {
          terpilih.add(opsi.id);
        }
      } else {
        terpilih
          ..clear()
          ..add(opsi.id);
      }
    });
  }

  void _tambahKeKeranjang() {
    if (!_wajibLengkap()) {
      showAppMessage(
        context,
        'Lengkapi pilihan wajib dulu, lalu coba lagi.',
        isError: true,
      );
      return;
    }

    CartStore.instance.tambah(
      _menu,
      addon: _addonTerpilih,
      catatan: _catatanController.text,
      jumlah: _jumlah,
    );

    final navigator = Navigator.of(context, rootNavigator: true);
    showAppMessage(
      context,
      '${_menu.nama} masuk keranjang.',
      actionLabel: 'Lihat',
      onAction: () {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => CartPage(cabangTerpilih: widget.cabangTerpilih),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_menu.nama, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: (MediaQuery.sizeOf(context).height * 0.3)
                        .clamp(190.0, 280.0)
                        .toDouble(),
                    child: AppImage(
                      url: _menu.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fallbackIconSize: 64,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      AppSpacing.s20,
                      AppSpacing.s20,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _menu.nama,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: AppText.w800,
                                      height: 1.2,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s6),
                                  Text(
                                    '${_menu.takaran} · ${_menu.kategori}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: AppText.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                formatRupiah(_menu.harga),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: AppText.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s14),
                        Text(
                          _menu.deskripsi,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: AppText.w400,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_menu.addon.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s28),
                          Text(
                            'Sesuaikan pesananmu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: AppText.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          for (final grup in _menu.addon) ...[
                            _buildGrupAddon(grup),
                            const SizedBox(height: AppSpacing.s20),
                          ],
                        ],
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Catatan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: AppText.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        TextField(
                          controller: _catatanController,
                          maxLines: 2,
                          maxLength: 80,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: sambal dipisah',
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Jumlah',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: AppText.w800,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            _buildJumlahStepper(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        keterangan: 'Total',
        nilai: formatRupiah(_total),
        tombolText: 'Tambah ke keranjang',
        onTombolPressed: _tambahKeKeranjang,
      ),
    );
  }

  Widget _buildGrupAddon(AddonGroup grup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                grup.nama,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: AppText.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            if (grup.wajib)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Wajib',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: AppText.w700,
                    color: AppColors.badgeText,
                  ),
                ),
              ),
            if (grup.multiPilih)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s8),
                child: Text(
                  'Bisa pilih banyak',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: AppText.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s10),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final opsi in grup.opsi)
              _buildOpsiChip(
                grup,
                opsi,
                dipilih: (_pilihan[grup.id] ?? const <String>{}).contains(
                  opsi.id,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpsiChip(
    AddonGroup grup,
    AddonOption opsi, {
    required bool dipilih,
  }) {
    final label = opsi.harga > 0
        ? '${opsi.nama}  +${formatRupiah(opsi.harga)}'
        : opsi.nama;
    final chip = ChoiceChip(
      label: Text(label),
      selected: dipilih,
      onSelected: (_) => _pilih(grup, opsi),
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceSoft,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: AppText.w600,
        color: dipilih ? Colors.white : AppColors.text,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
    );
    return Semantics(button: true, label: label, child: chip);
  }

  Widget _buildJumlahStepper() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: AppSize.touchTarget,
            height: AppSize.touchTarget,
            child: IconButton(
              tooltip: 'Kurangi jumlah',
              icon: const Icon(Icons.remove, size: 18),
              color: AppColors.primary,
              onPressed: _jumlah > 1 ? () => setState(() => _jumlah--) : null,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$_jumlah',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: AppText.w700,
                color: AppColors.text,
              ),
            ),
          ),
          SizedBox(
            width: AppSize.touchTarget,
            height: AppSize.touchTarget,
            child: IconButton(
              tooltip: 'Tambah jumlah',
              icon: const Icon(Icons.add, size: 18),
              color: AppColors.primary,
              onPressed: () => setState(() => _jumlah++),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
