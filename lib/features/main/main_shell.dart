import 'package:flutter/material.dart';

import '../../core/messages.dart';
import '../../widgets/bottom_nav.dart';
import '../cabang/cabang_model.dart';
import '../home/home_page.dart';
import '../menu/menu_page.dart';
import '../pesanan/pesanan_page.dart';
import '../profile/profile_page.dart';

/// Shell utama aplikasi setelah login.
/// Memakai IndexedStack agar perpindahan tab instan (tanpa animasi rute)
/// dan state tiap tab tetap tersimpan.
class MainShell extends StatefulWidget {
  final Cabang? cabangTerpilih;

  const MainShell({super.key, this.cabangTerpilih});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late Cabang? _cabang;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _cabang = widget.cabangTerpilih;
    _bangunHalaman();
  }

  void _bangunHalaman() {
    _pages = [
      BerandaPage(
        cabangTerpilih: _cabang,
        onLihatSemuaMenu: () {
          setState(() => _index = 1);
        },
      ),
      MenuPage(cabangTerpilih: _cabang),
      PesananPage(
        cabangTerpilih: _cabang,
        onPesanMenu: () {
          setState(() => _index = 1);
        },
      ),
      ProfilePage(cabangTerpilih: _cabang, onGantiCabang: _gantiCabang),
    ];
  }

  void _gantiCabang(Cabang cabang) {
    setState(() {
      _cabang = cabang;
      _bangunHalaman();
      _index = 3;
    });
    showAppMessage(context, 'Cabang diganti ke ${cabang.nama}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga semua halaman tetap hidup -> pindah tab instan.
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNav(
        activeItem: BottomNavItem.values[_index],
        onItemTapped: (item) {
          setState(() => _index = item.index);
        },
      ),
    );
  }
}
