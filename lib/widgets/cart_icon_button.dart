import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../features/cabang/cabang_model.dart';
import '../features/cart/cart_page.dart';
import '../state/cart_store.dart';
import 'button.dart';
import 'count_badge.dart';

/// Ikon keranjang dengan badge jumlah item yang ikut berubah.
class CartIconButton extends StatelessWidget {
  final Cabang? cabangTerpilih;
  final Color backgroundColor;
  final Color iconColor;

  const CartIconButton({
    super.key,
    this.cabangTerpilih,
    this.backgroundColor = AppColors.surface,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartStore.instance,
      builder: (context, _) {
        final jumlah = CartStore.instance.totalItem;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButtonCircle(
              icon: Icons.shopping_cart_outlined,
              tooltip: 'Keranjang',
              backgroundColor: backgroundColor,
              iconColor: iconColor,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CartPage(cabangTerpilih: cabangTerpilih),
                  ),
                );
              },
            ),
            // Selalu ada agar animasinya juga terlihat saat jumlah kembali nol.
            Positioned(
              right: -3,
              top: -4,
              child: AnimatedCountBadge(jumlah: jumlah),
            ),
          ],
        );
      },
    );
  }
}
