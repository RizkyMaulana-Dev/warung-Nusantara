import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../data/menu_data.dart';
import '../../state/cart_store.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/notification_bell.dart';
import '../cabang/cabang_model.dart';
import '../cart/cart_page.dart';
import 'detail_menu_page.dart';

/// Katalog menu lengkap dengan pencarian dan filter kategori.
/// Hanya berisi konten; navigasi bawah ditangani MainShell.
class MenuPage extends StatefulWidget {
  final Cabang? cabangTerpilih;

  const MenuPage({super.key, this.cabangTerpilih});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cariController = TextEditingController();

  /// Daftar hasil memudar masuk setiap kali filter atau pencarian berubah,
  /// supaya pergantiannya terasa halus, bukan menyentak.
  late final AnimationController _animasiHasil = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );

  String _kategoriDipilih = 'Semua';
  String _query = '';

  @override
  void dispose() {
    _cariController.dispose();
    _animasiHasil.dispose();
    super.dispose();
  }

  void _pudarkanHasil() => _animasiHasil.forward(from: 0);

  List<MenuProduk> get _hasil {
    final kataKunci = _query.trim().toLowerCase();
    return daftarMenu.where((menu) {
      final cocokKategori =
          _kategoriDipilih == 'Semua' || menu.kategori == _kategoriDipilih;
      final cocokCari =
          kataKunci.isEmpty ||
          menu.nama.toLowerCase().contains(kataKunci) ||
          menu.deskripsi.toLowerCase().contains(kataKunci);
      return cocokKategori && cocokCari;
    }).toList();
  }

  void _bukaDetail(MenuProduk menu) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DetailMenuPage(menu: menu, cabangTerpilih: widget.cabangTerpilih),
      ),
    );
  }

  void _tambahKeKeranjang(MenuProduk menu) {
    final navigator = Navigator.of(context, rootNavigator: true);
    CartStore.instance.tambah(menu);
    showAppMessage(
      context,
      '${menu.nama} masuk keranjang.',
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
    final hasil = _hasil;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const NotificationBell(
            backgroundColor: Colors.white,
            iconColor: AppColors.primary,
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s12),
            child: CartIconButton(
              cabangTerpilih: widget.cabangTerpilih,
              backgroundColor: Colors.white,
              iconColor: AppColors.primary,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildPencarian()),
          SliverToBoxAdapter(child: _buildKategori()),
          SliverToBoxAdapter(child: _buildInfo(hasil.length)),
          SliverFadeTransition(
            opacity: _animasiHasil,
            sliver: hasil.isEmpty
                ? SliverToBoxAdapter(child: _buildKosong())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      0,
                      AppSpacing.s20,
                      AppSpacing.s24,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 240,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final menu = hasil[index];
                        return MenuCard(
                          imageUrl: menu.imageUrl,
                          name: menu.nama,
                          portion: menu.takaran,
                          price: menu.harga,
                          isAvailable: menu.tersedia,
                          isPopular: menu.populer,
                          onTap: menu.tersedia ? () => _bukaDetail(menu) : null,
                          onAdd: menu.tersedia
                              ? () => _tambahKeKeranjang(menu)
                              : null,
                        );
                      }, childCount: hasil.length),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPencarian() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s16,
      ),
      child: TextField(
        controller: _cariController,
        textInputAction: TextInputAction.search,
        onChanged: (nilai) {
          setState(() => _query = nilai);
          _pudarkanHasil();
        },
        decoration: InputDecoration(
          hintText: 'Cari menu...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () {
                    _cariController.clear();
                    setState(() => _query = '');
                    _pudarkanHasil();
                  },
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildKategori() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: kategoriMenu.length,
        itemBuilder: (context, index) {
          final kategori = kategoriMenu[index];
          final isAktif = _kategoriDipilih == kategori;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? AppSpacing.s20 : AppSpacing.s8,
              right: index == kategoriMenu.length - 1 ? AppSpacing.s20 : 0,
            ),
            child: Center(
              child: ChoiceChip(
                label: Text(
                  kategori,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: AppText.w600,
                    color: isAktif ? Colors.white : const Color(0xFF3A4540),
                  ),
                ),
                selected: isAktif,
                onSelected: (_) {
                  setState(() => _kategoriDipilih = kategori);
                  _pudarkanHasil();
                },
                backgroundColor: AppColors.surfaceSoft,
                selectedColor: AppColors.primary,
                // Centang putih supaya terlihat di atas hijau tua.
                checkmarkColor: Colors.white,
                labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo(int jumlah) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _query.trim().isEmpty
                  ? 'Pilihan menu'
                  : 'Hasil untuk "${_query.trim()}"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: AppText.w800,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            '$jumlah menu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: AppText.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKosong() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s36,
        AppSpacing.s24,
        AppSpacing.s36,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Menu tidak ditemukan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: AppText.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            'Coba kata kunci lain atau pilih kategori Semua.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: AppText.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: 180,
            child: TextButton(
              onPressed: () {
                _cariController.clear();
                setState(() {
                  _query = '';
                  _kategoriDipilih = 'Semua';
                });
                _pudarkanHasil();
              },
              child: const Text('Reset pencarian'),
            ),
          ),
        ],
      ),
    );
  }
}
