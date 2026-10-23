import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../state/cart_store.dart';
import '../../widgets/bottom_action_bar.dart';
import '../../widgets/cart_item.dart';
import '../../widgets/empty_state.dart';
import '../cabang/cabang_model.dart';
import '../checkout/checkout_page.dart';
import '../menu/detail_menu_page.dart';

/// Keranjang: item nyata dari state bersama, ongkir, dan tombol Checkout.
class CartPage extends StatelessWidget {
  final Cabang? cabangTerpilih;

  const CartPage({super.key, this.cabangTerpilih});

  void _bukaEdit(BuildContext context, CartLine line) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailMenuPage(
          menu: line.produk,
          cabangTerpilih: cabangTerpilih,
          editLine: line,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartStore.instance,
      builder: (context, _) {
        final store = CartStore.instance;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              store.kosong ? 'Keranjang' : 'Keranjang (${store.totalItem})',
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: store.kosong
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Keranjangmu masih kosong.',
                  description: 'Yuk, pilih menu favoritmu dulu. Nanti pesanannya muncul di sini.',
                  actionText: 'Pilih menu',
                  onAction: () => Navigator.of(context).pop(),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20,
                          AppSpacing.s20,
                          AppSpacing.s20,
                          AppSpacing.s8,
                        ),
                        itemCount: store.lines.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.s10),
                        itemBuilder: (context, index) {
                          final line = store.lines[index];
                          return CartItem(
                            imageUrl: line.produk.imageUrl,
                            name: line.produk.nama,
                            options: line.opsiRingkas,
                            price: line.hargaSatuan,
                            quantity: line.jumlah,
                            onIncrease: () => store.tambahJumlah(line.id),
                            onDecrease: () => store.kurangiJumlah(line.id),
                            onRemove: () {
                              store.hapus(line.id);
                              showAppMessage(
                                context,
                                AppMessages.itemDihapusKeranjang,
                              );
                            },
                            onEdit: () => _bukaEdit(context, line),
                          );
                        },
                      ),
                    ),
                    _buildRingkasan(store),
                    BottomActionBar(
                      keterangan: 'Total pembayaran',
                      nilai: formatRupiah(store.total),
                      tombolText: 'Checkout',
                      onTombolPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                CheckoutPage(cabangTerpilih: cabangTerpilih),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildRingkasan(CartStore store) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s4,
        AppSpacing.s20,
        AppSpacing.s8,
      ),
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSize.listItemRadius),
      ),
      child: Column(
        children: [
          _baris('Subtotal', formatRupiah(store.subtotal)),
          const SizedBox(height: AppSpacing.s8),
          _baris(
            'Ongkir',
            '+ ${formatRupiah(store.ongkir)}',
            nilaiWarna: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _baris(
    String label,
    String nilai, {
    Color nilaiWarna = AppColors.text,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: AppText.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          nilai,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: AppText.w700,
            color: nilaiWarna,
          ),
        ),
      ],
    );
  }
}
