import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/alamat_store.dart';
import '../../state/cart_store.dart';
import '../../state/loyalty_point_store.dart';
import '../../state/metode_bayar_store.dart';
import '../../state/order_store.dart';
import '../../state/voucher_store.dart';
import '../../widgets/bottom_action_bar.dart';
import '../../widgets/button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/voucher_drawer.dart';
import '../alamat/alamat_page.dart';
import '../cabang/cabang_model.dart';
import '../pembayaran/metode_pembayaran_page.dart';
import '../tracking/tracking_page.dart';

/// Checkout: pilih alamat, pembayaran, voucher, lalu buat pesanan.
class CheckoutPage extends StatefulWidget {
  final Cabang? cabangTerpilih;

  const CheckoutPage({super.key, this.cabangTerpilih});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

String _poinPesan(String dasar, int total) {
  final poin = (total / 1000).floor();
  return poin > 0 ? '$dasar Kamu dapat $poin poin loyalitas.' : dasar;
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _alamatId;
  String? _metodeId;
  bool _memproses = false;

  late final Listenable _perubahan = Listenable.merge([
    CartStore.instance,
    AlamatStore.instance,
    MetodeBayarStore.instance,
    VoucherStore.instance,
  ]);

  @override
  void initState() {
    super.initState();
    _alamatId = AlamatStore.instance.utama?.id;
    _metodeId = MetodeBayarStore.instance.utama?.id;
  }

  String? get _alamatIdAktif {
    final daftar = AlamatStore.instance.daftar;
    if (_alamatId != null && daftar.any((alamat) => alamat.id == _alamatId)) {
      return _alamatId;
    }
    return AlamatStore.instance.utama?.id;
  }

  String? get _metodeIdAktif {
    final daftar = MetodeBayarStore.instance.daftar;
    if (_metodeId != null && daftar.any((metode) => metode.id == _metodeId)) {
      return _metodeId;
    }
    return MetodeBayarStore.instance.utama?.id;
  }

  AlamatData? _alamatTerpilih() {
    final id = _alamatIdAktif;
    if (id == null) return null;
    for (final alamat in AlamatStore.instance.daftar) {
      if (alamat.id == id) return alamat;
    }
    return null;
  }

  MetodeBayarData? _metodeTerpilih() {
    final id = _metodeIdAktif;
    if (id == null) return null;
    for (final metode in MetodeBayarStore.instance.daftar) {
      if (metode.id == id) return metode;
    }
    return null;
  }

  Future<void> _bukaKelola(Widget halaman) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => halaman));
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _bayar() async {
    final cart = CartStore.instance;
    if (cart.kosong) {
      showAppMessage(
        context,
        'Keranjang kosong. Pilih menu dulu, lalu checkout lagi.',
        isError: true,
      );
      return;
    }

    final alamat = _alamatTerpilih();
    if (alamat == null) {
      showAppMessage(context, AppMessages.pilihAlamat, isError: true);
      return;
    }

    final metode = _metodeTerpilih();
    if (metode == null) {
      showAppMessage(context, AppMessages.pilihPembayaran, isError: true);
      return;
    }

    setState(() => _memproses = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final voucher = VoucherStore.instance.dipilih;
    final subtotal = cart.subtotal;
    final ongkir = cart.ongkir;
    final diskon = VoucherStore.instance.hitungDiskon(subtotal);
    final total = subtotal + ongkir - diskon;
    final nomor = DateTime.now().millisecondsSinceEpoch.toString();
    final order = OrderData(
      id: 'WN-${nomor.substring(nomor.length - 6)}',
      waktu: DateTime.now(),
      lines: cart.lines.map(OrderLine.fromCart).toList(),
      subtotal: subtotal,
      ongkir: ongkir,
      diskon: diskon,
      total: total,
      alamat: '${alamat.label} · ${alamat.detail}',
      pembayaran: metode.nama,
      cabang: widget.cabangTerpilih?.nama ?? 'Warung Nusantara',
      status: 'Sedang dimasak',
    );

    OrderStore.instance.tambah(order);
    cart.kosongkan();
    if (voucher != null) VoucherStore.instance.hapus();

    // Bonus poin loyalitas (1 poin / Rp 1.000, bergantung bobot transaksi).
    LoyaltyPointStore.instance.tambahDariTotal(total);

    if (!mounted) return;
    setState(() => _memproses = false);
    showAppMessage(
      context,
      _poinPesan(AppMessages.pembayaranBerhasil, total),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            TrackingPage(pesanan: order, cabangTerpilih: widget.cabangTerpilih),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _perubahan,
      builder: (context, _) {
        final cart = CartStore.instance;
        final voucher = VoucherStore.instance.dipilih;
        final diskon = VoucherStore.instance.hitungDiskon(cart.subtotal);
        final total = cart.subtotal + cart.ongkir - diskon;

        if (cart.kosong) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Checkout'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Keranjang kosong.',
              description: 'Pilih menu dulu supaya bisa lanjut ke pembayaran.',
              actionText: 'Kembali',
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJudul('Alamat pengantaran', () {
                  _bukaKelola(const AlamatPage());
                }),
                const SizedBox(height: AppSpacing.s10),
                if (AlamatStore.instance.daftar.isEmpty)
                  _buildKosongAlamat()
                else
                  RadioGroup<String>(
                    groupValue: _alamatIdAktif,
                    onChanged: (nilai) {
                      if (nilai != null) setState(() => _alamatId = nilai);
                    },
                    child: Column(
                      children: [
                        for (final alamat in AlamatStore.instance.daftar)
                          _buildOpsiAlamat(alamat),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.s20),
                _buildJudul('Metode pembayaran', () {
                  _bukaKelola(const MetodePembayaranPage());
                }),
                const SizedBox(height: AppSpacing.s10),
                if (MetodeBayarStore.instance.daftar.isEmpty)
                  _buildKosongPembayaran()
                else
                  RadioGroup<String>(
                    groupValue: _metodeIdAktif,
                    onChanged: (nilai) {
                      if (nilai != null) setState(() => _metodeId = nilai);
                    },
                    child: Column(
                      children: [
                        for (final metode in MetodeBayarStore.instance.daftar)
                          _buildOpsiPembayaran(metode),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.s20),
                _buildJudul('Voucher', null),
                const SizedBox(height: AppSpacing.s10),
                _buildVoucher(voucher, cart.subtotal, diskon),
                const SizedBox(height: AppSpacing.s20),
                _buildRingkasan(cart, diskon, total),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'Pesanan akan dikirim dari ${widget.cabangTerpilih?.nama ?? 'cabang terdekat'}.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: AppText.w400,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomActionBar(
            keterangan: 'Total pembayaran',
            nilai: formatRupiah(total),
            tombolText: 'Bayar',
            isLoading: _memproses,
            onTombolPressed: _bayar,
          ),
        );
      },
    );
  }

  Widget _buildJudul(String judul, VoidCallback? onKelola) {
    return Row(
      children: [
        Expanded(
          child: Text(
            judul,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: AppText.w800,
              color: AppColors.text,
            ),
          ),
        ),
        if (onKelola != null)
          TextButton(onPressed: onKelola, child: const Text('Kelola')),
      ],
    );
  }

  Widget _buildOpsiAlamat(AlamatData alamat) {
    final terpilih = _alamatIdAktif == alamat.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.listItemRadius),
          side: BorderSide(
            color: terpilih ? AppColors.primary : AppColors.divider,
            width: terpilih ? 1.5 : 1,
          ),
        ),
        child: RadioListTile<String>(
          value: alamat.id,
          activeColor: AppColors.primary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  alamat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: AppText.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              if (alamat.utama) ...[
                const SizedBox(width: 6),
                Text(
                  'Utama',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: AppText.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(
            alamat.detail,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: AppText.w400,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpsiPembayaran(MetodeBayarData metode) {
    final terpilih = _metodeIdAktif == metode.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.listItemRadius),
          side: BorderSide(
            color: terpilih ? AppColors.primary : AppColors.divider,
            width: terpilih ? 1.5 : 1,
          ),
        ),
        child: RadioListTile<String>(
          value: metode.id,
          activeColor: AppColors.primary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          title: Text(
            metode.nama,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: AppText.w700,
              color: AppColors.text,
            ),
          ),
          subtitle: Text(
            metode.detail,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: AppText.w400,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoucher(VoucherData? voucher, int subtotal, int diskon) {
    if (voucher == null) {
      return Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.listItemRadius),
          side: const BorderSide(color: AppColors.divider),
        ),
        child: ListTile(
          leading: const Icon(
            Icons.local_offer_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          title: Text(
            'Pilih voucher',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: AppText.w600,
              color: AppColors.text,
            ),
          ),
          subtitle: Text(
            'Ada ${VoucherStore.instance.semua.length} voucher tersedia.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onTap: () => bukaVoucherDrawer(context, CartStore.instance),
        ),
      );
    }

    final memenuhi = diskon > 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.listItemRadius),
        border: Border.all(
          color: memenuhi ? AppColors.primary : AppColors.accent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  '${voucher.kode} · ${voucher.judul}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: AppText.w700,
                    color: AppColors.text,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => bukaVoucherDrawer(context, CartStore.instance),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                ),
                child: const Text('Ubah'),
              ),
            ],
          ),
          Text(
            memenuhi
                ? 'Voucher dipakai. Kamu hemat ${formatRupiah(diskon)}.'
                : 'Belanja ${formatRupiah(voucher.minimalBelanja - subtotal)} lagi supaya voucher bisa dipakai.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: AppText.w400,
              height: 1.4,
              color: memenuhi ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasan(CartStore cart, int diskon, int total) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
      ),
      child: Column(
        children: [
          _baris(
            'Subtotal (${cart.totalItem} item)',
            formatRupiah(cart.subtotal),
          ),
          const SizedBox(height: AppSpacing.s8),
          _baris('Ongkir', formatRupiah(cart.ongkir)),
          if (diskon > 0) ...[
            const SizedBox(height: AppSpacing.s8),
            _baris(
              'Diskon voucher',
              '-${formatRupiah(diskon)}',
              warna: AppColors.primary,
            ),
          ],
          const Divider(height: 24, color: AppColors.divider),
          _baris(
            'Total',
            formatRupiah(total),
            tebal: true,
            warna: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _baris(
    String label,
    String nilai, {
    bool tebal = false,
    Color? warna,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: tebal ? 14 : 12,
              fontWeight: tebal ? AppText.w800 : AppText.w400,
              color: tebal ? AppColors.text : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          nilai,
          style: GoogleFonts.plusJakartaSans(
            fontSize: tebal ? 15 : 12,
            fontWeight: tebal ? AppText.w800 : AppText.w600,
            color: warna ?? AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildKosongAlamat() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.listItemRadius),
      ),
      child: Column(
        children: [
          Text(
            'Belum ada alamat. Tambahkan alamat dulu supaya pesanan bisa diantar.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          SecondaryButton(
            text: 'Tambah alamat',
            onPressed: () => _bukaKelola(const AlamatPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildKosongPembayaran() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.listItemRadius),
      ),
      child: Column(
        children: [
          Text(
            'Belum ada metode pembayaran. Tambahkan satu dulu untuk melanjutkan.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          SecondaryButton(
            text: 'Tambah metode',
            onPressed: () => _bukaKelola(const MetodePembayaranPage()),
          ),
        ],
      ),
    );
  }
}
