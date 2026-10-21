import 'dart:async';

import 'package:flutter/material.dart';

import 'constants.dart';

/// Pesan dalam Bahasa Indonesia yang mudah dipahami dan singkat.
/// Setiap pesan negatif disertai solusi (tombol atau saran tindakan).
class AppMessages {
  // =============================================================================
  // JARINGAN
  // =============================================================================
  static const String jaringanLemah =
      'Jaringan lemah. Cari tempat sinyal lebih bagus, lalu ketuk Muat ulang.';
  static const String tidakAdaInternet =
      'Tidak terhubung internet. Periksa sambungan kamu, lalu coba lagi.';
  static const String gagalMemuatData =
      'Gagal memuat data. Periksa sinyal kamu, lalu coba lagi.';
  static const String waktuHabis =
      'Waktu habis. Coba lagi atau cari tempat sinyal lebih bagus.';
  static const String cobaLagi = 'Coba lagi';
  static const String muatUlang = 'Muat ulang';
  static const String cariSinyalLebihBagus = 'Cari tempat sinyal lebih bagus';

  // =============================================================================
  // LOGIN & SESI
  // =============================================================================
  static const String emailAtauSandiSalah =
      'Email atau kata sandi salah. Periksa lagi, lalu coba masuk.';
  static const String kolomWajibDiisi = 'Kolom ini wajib diisi.';
  static const String formatEmailSalah =
      'Format email belum benar. Contoh: nama@email.com.';
  static const String sandiTerlaluPendek = 'Kata sandi minimal 8 karakter.';
  static const String loginBerhasil = 'Login berhasil.';
  static const String gagalLogin =
      'Gagal masuk. Periksa email dan kata sandi, lalu coba lagi.';
  static const String sesiKedaluwarsa = 'Sesi kamu telah berakhir. Masuk lagi.';
  static const String keluarKonfirmasi = 'Yakin ingin keluar?';

  // =============================================================================
  // MENU & KERANJANG
  // =============================================================================
  static const String menuHabis =
      'Maaf, menu ini sedang habis. Pilih menu lain yang tersedia.';
  static const String menuTidakTersedia =
      'Menu belum tersedia. Coba menu lain dulu, ya.';
  static const String keranjangKosong =
      'Keranjangmu masih kosong. Pilih menu dulu, ya.';
  static const String itemDitambahKeranjang = 'Item ditambahkan ke keranjang.';
  static const String itemDihapusKeranjang = 'Item dihapus dari keranjang.';
  static const String minimalBelanja =
      'Minimal belanja belum terpenuhi. Tambah menu lagi atau pakai voucher lain.';

  // =============================================================================
  // CHECKOUT & PEMBAYARAN
  // =============================================================================
  static const String pilihAlamat = 'Pilih alamat dulu, lalu coba bayar lagi.';
  static const String pilihPembayaran =
      'Pilih metode pembayaran dulu, lalu coba lagi.';
  static const String pembayaranBerhasil =
      'Pembayaran berhasil. Pesanan dibuat.';
  static const String pembayaranGagal =
      'Pembayaran gagal. Coba lagi atau pilih metode lain.';
  static const String pembayaranKedaluwarsa =
      'Waktu pembayaran habis. Pesanan tidak dibuat. Coba lagi.';
  static const String pesananDibuat = 'Pesanan berhasil dibuat.';

  // =============================================================================
  // PESANAN
  // =============================================================================
  static const String pesananDibatalkan = 'Pesanan dibatalkan.';
  static const String gagalMuatStatus = 'Gagal memuat status pesanan.';
  static const String tidakAdaPesanan = 'Belum ada pesanan.';

  // =============================================================================
  // CABANG (multi-cabang)
  // =============================================================================
  static const String cabangTidakDitemukan =
      'Cabang terdekat tidak ditemukan. Pilih cabang lain.';
  static const String gagalMuatCabang =
      'Gagal memuat daftar cabang. Periksa sinyal, lalu ketuk Muat ulang.';
  static const String pilihCabang =
      'Pilih cabang dulu supaya pesanan dikirim dari tempat yang tepat.';
  static const String jarakCabang = 'dari lokasi kamu';

  // =============================================================================
  // BANTUAN
  // =============================================================================
  static const String gagalBukaWhatsApp =
      'WhatsApp tidak bisa dibuka. Nomor sudah disalin, buka WhatsApp Web atau telepon warung.';
}

// =============================================================================
// Helper: notifikasi singkat di atas bar aksi bawah.
// Memakai Overlay agar tidak menutupi tombol Checkout/Bayar seperti SnackBar.
// Bisa ditutup lebih cepat dengan menggeser ke samping atau ke bawah.
// =============================================================================
OverlayEntry? _toastAktif;
Timer? _toastTimer;

/// Jarak geser minimum supaya toast dianggap sengaja ditutup.
const double _ambangGeserSamping = 120;
const double _ambangGeserBawah = 60;

void showAppMessage(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  _toastTimer?.cancel();
  final toastLama = _toastAktif;
  _toastAktif = null;
  if (toastLama != null && toastLama.mounted) toastLama.remove();

  late final OverlayEntry entry;

  void tutup() {
    _toastTimer?.cancel();
    _toastTimer = null;
    if (_toastAktif == entry) _toastAktif = null;
    if (entry.mounted) entry.remove();
  }

  void mulaiUlangTimer() {
    _toastTimer?.cancel();
    _toastTimer = Timer(duration, tutup);
  }

  entry = OverlayEntry(
    builder: (toastContext) {
      final bottomInset = MediaQuery.paddingOf(toastContext).bottom;
      return Positioned(
        left: 16,
        right: 16,
        bottom: bottomInset + 108,
        child: _ToastKartu(
          message: message,
          isError: isError,
          actionLabel: actionLabel,
          onAction: () {
            tutup();
            onAction?.call();
          },
          onTutup: tutup,
          onTimerTunda: () {
            _toastTimer?.cancel();
            _toastTimer = null;
          },
          onTimerMulaiUlang: mulaiUlangTimer,
        ),
      );
    },
  );

  _toastAktif = entry;
  overlay.insert(entry);
  mulaiUlangTimer();
}

/// Isi toast: beranimasi saat muncul, mengikuti jari saat digeser, dan
/// beranimasi keluar saat ditutup.
class _ToastKartu extends StatefulWidget {
  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onTutup;
  final VoidCallback onTimerTunda;
  final VoidCallback onTimerMulaiUlang;

  const _ToastKartu({
    required this.message,
    required this.isError,
    required this.onTutup,
    required this.onTimerTunda,
    required this.onTimerMulaiUlang,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_ToastKartu> createState() => _ToastKartuState();
}

class _ToastKartuState extends State<_ToastKartu>
    with TickerProviderStateMixin {
  late final AnimationController _masuk = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  late final AnimationController _keluar = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  Offset _geser = Offset.zero;
  bool _sedangMenutup = false;

  @override
  void initState() {
    super.initState();
    _masuk.forward();
  }

  @override
  void dispose() {
    _masuk.dispose();
    _keluar.dispose();
    super.dispose();
  }

  void _saatDigeser(DragUpdateDetails detail) {
    // Tahan dulu semburan otomatisnya selama jari masih menempel.
    widget.onTimerTunda();
    setState(() => _geser += detail.delta);
  }

  Future<void> _setelahDigeser(DragEndDetails detail) async {
    final kecepatan = detail.velocity.pixelsPerSecond;
    final jauhKeSamping =
        _geser.dx.abs() > _ambangGeserSamping || kecepatan.dx.abs() > 400;
    final jauhKeBawah = _geser.dy > _ambangGeserBawah || kecepatan.dy > 400;

    if (jauhKeSamping || jauhKeBawah) {
      await _tutup();
      return;
    }

    setState(() => _geser = Offset.zero);
    widget.onTimerMulaiUlang();
  }

  Future<void> _tutup() async {
    if (_sedangMenutup) return;
    _sedangMenutup = true;
    widget.onTimerTunda();
    await _keluar.forward();
    widget.onTutup();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_masuk, _keluar]),
      builder: (context, child) {
        final masuk = Curves.easeOut.transform(_masuk.value);
        final keluar = _keluar.value;
        final geser = _geser * (1 + keluar * 0.6) + Offset(0, (1 - masuk) * 12);

        return Transform.translate(
          offset: geser,
          child: Opacity(opacity: (1 - keluar) * masuk, child: child),
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _saatDigeser,
        onHorizontalDragEnd: _setelahDigeser,
        onVerticalDragUpdate: _saatDigeser,
        onVerticalDragEnd: _setelahDigeser,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isError ? AppColors.error : AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.isError
                      ? Icons.error_outline
                      : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: widget.onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      widget.actionLabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
