import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';

enum BottomNavItem { beranda, menu, pesanan, akun }

class BottomNavItemData {
  final BottomNavItem item;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  BottomNavItemData({
    required this.item,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

final List<BottomNavItemData> bottomNavItems = [
  BottomNavItemData(
    item: BottomNavItem.beranda,
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Beranda',
  ),
  BottomNavItemData(
    item: BottomNavItem.menu,
    icon: Icons.restaurant_outlined,
    activeIcon: Icons.restaurant_rounded,
    label: 'Menu',
  ),
  BottomNavItemData(
    item: BottomNavItem.pesanan,
    icon: Icons.receipt_outlined,
    activeIcon: Icons.receipt_rounded,
    label: 'Pesanan',
  ),
  BottomNavItemData(
    item: BottomNavItem.akun,
    icon: Icons.person_outlined,
    activeIcon: Icons.person_rounded,
    label: 'Akun',
  ),
];

/// Navigasi bawah: latar primary, 4 item rata sama.
/// Diberi jarak dari tepi bawah perangkat agar tidak menempel
/// ke gesture bar / sudut layar.
///
/// Desain: floating capsule — radius penuh, margin aman layar,
/// tanpa bayangan sehingga ikon tombol tetap rapi.
class BottomNav extends StatelessWidget {
  final BottomNavItem activeItem;
  final ValueChanged<BottomNavItem> onItemTapped;

  const BottomNav({
    super.key,
    required this.activeItem,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return Padding(
      // Floating: tidak menempel di tepi layar, ruang aman di bawah.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        0,
        AppSpacing.s20,
        insets.bottom + AppSpacing.s12,
      ),
      // Tanpa Center: Center akan mengisi seluruh tinggi slot
      // bottomNavigationBar sehingga body jadi 0 tinggi.
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          // Capsule: radius penuh (semua sisi).
          borderRadius: BorderRadius.circular(30),
          // Tanpa bayangan seperti diminta.
        ),
        child: Row(
          children: [
            for (final item in bottomNavItems)
              Expanded(
                child: _ItemNav(
                  item: item,
                  selected: activeItem == item.item,
                  onTap: () => onItemTapped(item.item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Item navigasi individual di dalam capsule.
class _ItemNav extends StatelessWidget {
  final BottomNavItemData item;
  final bool selected;
  final VoidCallback onTap;

  const _ItemNav({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: 20,
                color: selected ? Colors.white : AppColors.onPrimaryMuted,
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: selected ? AppText.w800 : AppText.w600,
                      color: selected ? Colors.white : AppColors.onPrimaryMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
