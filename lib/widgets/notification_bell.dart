import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../state/notification_store.dart';
import 'button.dart';
import 'count_badge.dart';
import 'notification_panel.dart';

/// Ikon lonceng dengan angka jumlah notifikasi yang belum dibaca.
/// Ketuk untuk membuka panel notifikasi tepat di bawah lonceng.
class NotificationBell extends StatelessWidget {
  final Color backgroundColor;
  final Color iconColor;

  const NotificationBell({
    super.key,
    this.backgroundColor = AppColors.surface,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NotificationStore.instance,
      builder: (context, _) {
        final jumlah = NotificationStore.instance.jumlahBelumDibaca;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Builder(
              builder: (bellContext) => IconButtonCircle(
                icon: Icons.notifications_none,
                tooltip: 'Notifikasi',
                backgroundColor: backgroundColor,
                iconColor: iconColor,
                onPressed: () {
                  final box = bellContext.findRenderObject() as RenderBox?;
                  final anchor = box == null
                      ? Rect.zero
                      : box.localToGlobal(Offset.zero) & box.size;
                  showNotificationPanel(bellContext, anchor: anchor);
                },
              ),
            ),
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
