import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../data/menu_data.dart';
import '../../state/cart_store.dart';
import '../../widgets/app_image.dart';
import '../../widgets/button.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/notification_bell.dart';
import '../cabang/cabang_model.dart';
import '../cart/cart_page.dart';
import '../menu/detail_menu_page.dart';
import '../menu/menu_page.dart';

/// Beranda: banner promo, pencarian, filter kategori, dan menu populer.
/// Hanya berisi konten; navigasi bawah ditangani MainShell.
class BerandaPage extends StatefulWidget {
  final Cabang? cabangTerpilih;
  final VoidCallback? onLihatSemuaMenu;
  final VoidCallback? onGantiCabang;

  const BerandaPage({super.key, this.cabangTerpilih, this.onLihatSemuaMenu, this.onGantiCabang});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cariController = TextEditingController();
  final PageController _bannerController = PageController(
    viewportFraction: 0.9,
  );
  Timer? _bannerTimer;

  /// Daftar menu memudar masuk setiap kali filter atau pencarian berubah.
  late final AnimationController _animasiHasil = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );

  String _kategoriDipilih = 'Semua';
  String _query = '';
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_bannerController.hasClients) return;
      final berikut = (_bannerIndex + 1) % bannerPromo.length;
      _bannerController.animateToPage(
        berikut,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _cariController.dispose();
    _animasiHasil.dispose();
    super.dispose();
  }

  void _pudarkanHasil() => _animasiHasil.forward(from: 0);

  List<MenuProduk> get _menuTampil {
    final kataKunci = _query.trim().toLowerCase();
    final dasar = (_kategoriDipilih == 'Semua' && kataKunci.isEmpty)
        ? menuPopuler
        : daftarMenu;

    return dasar.where((menu) {
      final cocokKategori =
          _kategoriDipilih == 'Semua' || menu.kategori == _kategoriDipilih;
      final cocokCari =
          kataKunci.isEmpty ||
          menu.nama.toLowerCase().contains(kataKunci) ||
          menu.deskripsi.toLowerCase().contains(kataKunci);
      return cocokKategori && cocokCari;
    }).toList();
  }

  String get _judulBagian {
    if (_query.trim().isNotEmpty) return 'Hasil pencarian';
    if (_kategoriDipilih != 'Semua') return 'Menu $_kategoriDipilih';
    return 'Menu Populer';
  }

  void _bukaSemuaMenu() {
    if (widget.onLihatSemuaMenu != null) {
      widget.onLihatSemuaMenu!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MenuPage(cabangTerpilih: widget.cabangTerpilih),
        ),
      );
    }
  }

  void _bukaDetail(MenuProduk menu) {
    // Jika menu sudah di keranjang, buka detail untuk edit addon/catatan.
    final line = CartStore.instance.lines
        .cast<CartLine?>()
        .firstWhere(
          (l) => l?.produk.id == menu.id,
          orElse: () => null,
        );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailMenuPage(
          menu: menu,
          cabangTerpilih: widget.cabangTerpilih,
          editLine: line,
        ),
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
    final menuTampil = _menuTampil;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s20)),
          SliverToBoxAdapter(child: _buildHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),
          SliverToBoxAdapter(child: _buildPencarian()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),
          SliverToBoxAdapter(child: _buildBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),
          SliverToBoxAdapter(child: _buildKategori()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),
          SliverToBoxAdapter(child: _buildJudul(menuTampil.length)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s12)),
          SliverFadeTransition(
            opacity: _animasiHasil,
            sliver: menuTampil.isEmpty
                ? SliverToBoxAdapter(child: _buildKosong())
                : AnimatedBuilder(
                    animation: CartStore.instance,
                    builder: (context, _) {
                      return SliverPadding(
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
                        final menu = menuTampil[index];
                        final line = CartStore.instance.lines
                            .cast<CartLine?>()
                            .firstWhere(
                              (l) => l?.produk.id == menu.id,
                              orElse: () => null,
                            );
                        return MenuCard(
                          imageUrl: menu.imageUrl,
                          name: menu.nama,
                          portion: menu.takaran,
                          price: menu.harga,
                          isAvailable: menu.tersedia,
                          isPopular: menu.populer,
                          inCart: line != null,
                          cartLine: line,
                          onTap: menu.tersedia ? () => _bukaDetail(menu) : null,
                          onAdd: menu.tersedia
                              ? () => _tambahKeKeranjang(menu)
                              : null,
                        );
                      }, childCount: menuTampil.length),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final namaCabang = widget.cabangTerpilih?.nama ?? 'Cabang terdekat';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: widget.onGantiCabang,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.store,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            namaCabang,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: AppText.w600,
                              color: AppColors.textSecondary,
                              decoration: widget.onGantiCabang != null
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.onGantiCabang != null)
                          const Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  'Pesan Makan Favoritmu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: AppText.w800,
                    height: 1.15,
                    letterSpacing: -0.6,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          const NotificationBell(),
          const SizedBox(width: AppSpacing.s12),
          CartIconButton(cabangTerpilih: widget.cabangTerpilih),
        ],
      ),
    );
  }

  Widget _buildPencarian() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: TextField(
        controller: _cariController,
        textInputAction: TextInputAction.search,
        onChanged: (nilai) {
          setState(() => _query = nilai);
          _pudarkanHasil();
        },
        decoration: InputDecoration(
          hintText: 'Cari menu favoritmu',
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

  Widget _buildBanner() {
    return Column(
      children: [
        SizedBox(
          height: 184,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: bannerPromo.length,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final banner = bannerPromo[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: GestureDetector(
                  onTap: () {
                    final menu = menuById(banner.menuId);
                    if (menu != null) _bukaDetail(menu);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage(
                          url: banner.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xD91B2420),
                                Color(0x991B2420),
                                Color(0x1A1B2420),
                              ],
                              stops: [0, 0.58, 1],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  banner.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: AppText.w800,
                                    letterSpacing: 0.5,
                                    color: AppColors.onAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s8),
                              Text(
                                banner.judul,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 19,
                                  fontWeight: AppText.w800,
                                  height: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s4),
                              Text(
                                banner.subjudul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: AppText.w500,
                                  color: Colors.white.withValues(alpha: 0.86),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Pesan sekarang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: AppText.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerPromo.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: index == _bannerIndex ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: index == _bannerIndex
                    ? AppColors.primary
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
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
                  setState(() {
                    // Toggle: ketuk kategori yang sama → reset ke "Semua"
                    _kategoriDipilih = isAktif ? 'Semua' : kategori;
                  });
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

  Widget _buildJudul(int jumlah) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _judulBagian,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
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
          const SizedBox(width: 4),
          AppTextLink(text: 'Lihat semua', onPressed: _bukaSemuaMenu),
        ],
      ),
    );
  }

  Widget _buildKosong() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s24,
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
            child: SmallButton(
              text: 'Reset pencarian',
              onPressed: () {
                _cariController.clear();
                setState(() {
                  _query = '';
                  _kategoriDipilih = 'Semua';
                });
                _pudarkanHasil();
              },
            ),
          ),
        ],
      ),
    );
  }
}
