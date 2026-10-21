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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 6),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SizedBox(
            height: AppSize.bottomNavHeight,
            child: Row(
              children: bottomNavItems.map((itemData) {
                final isActive = activeItem == itemData.item;
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: isActive,
                    label: itemData.label,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onItemTapped(itemData.item),
                      child: SizedBox(
                        height: AppSize.bottomNavHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActive ? itemData.activeIcon : itemData.icon,
                              size: 20,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.onPrimaryMuted,
                            ),
                            const SizedBox(height: 2),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  itemData.label,
                                  maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: isActive
                                        ? AppText.w800
                                        : AppText.w600,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.onPrimaryMuted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
