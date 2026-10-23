import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/messages.dart';
import '../../widgets/button.dart';
import '../../widgets/error_state.dart';
import 'cabang_model.dart';
import 'cabang_service.dart';

/// Halaman pemilihan cabang (multi-cabang).
/// Menampilkan daftar cabang diurutkan dari yang terdekat.
/// User bisa memilih cabang lain jika ingin preferensi sendiri.
class CabangPage extends StatefulWidget {
  /// Opsional. Jika diisi, halaman tidak menutup diri dan memanggil
  /// callback ini. Jika kosong, halaman menutup diri dan mengembalikan
  /// cabang terpilih lewat Navigator.pop.
  final ValueChanged<Cabang>? onCabangDipilih;

  /// Cabang yang sedang dipakai. Jika diisi, pilihan tidak akan
  /// ditimpa otomatis oleh cabang terdekat.
  final Cabang? cabangAwal;

  const CabangPage({super.key, this.onCabangDipilih, this.cabangAwal});

  @override
  State<CabangPage> createState() => _CabangPageState();
}

class _CabangPageState extends State<CabangPage> {
  final CabangService _service = CabangService();
  List<Cabang> _daftarCabang = [];
  bool _isLoading = true;
  bool _isLocating = true;
  bool _lokasiDipakai = false;
  bool _sudahMemilih = false;
  String? _error;
  Cabang? _cabangTerpilih;

  @override
  void initState() {
    super.initState();
    _cabangTerpilih = widget.cabangAwal;
    _muatCabang();
  }

  Future<void> _muatCabang() async {
    setState(() {
      _isLoading = true;
      _isLocating = true;
      _error = null;
      _lokasiDipakai = false;
    });

    try {
      // Coba ambil lokasi user untuk hitung jarak
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _pakaiDaftarTanpaLokasi();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _pakaiDaftarTanpaLokasi();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _pakaiDaftarTanpaLokasi();
        return;
      }

      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (!mounted) return;

      setState(() {
        _daftarCabang = _service.hitungJarakDariLokasi(posisi);
        _isLoading = false;
        _isLocating = false;
        _lokasiDipakai = true;

        // Pilih otomatis cabang terdekat hanya jika belum ada pilihan.
        if (_daftarCabang.isNotEmpty && _cabangTerpilih == null) {
          _cabangTerpilih = _daftarCabang.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppMessages.gagalMuatCabang;
        _isLoading = false;
        _isLocating = false;
        _lokasiDipakai = false;
        _daftarCabang = _service.getSemuaCabang();
        // Pastikan ada pilihan default supaya tombol "Pilih Cabang Ini" muncul.
        if (_daftarCabang.isNotEmpty && _cabangTerpilih == null) {
          _cabangTerpilih = _daftarCabang.first;
        }
      });
    }
  }

  /// Dipakai saat lokasi tidak tersedia: tetap tampilkan semua cabang
  /// agar user bisa memilih secara manual.
  void _pakaiDaftarTanpaLokasi() {
    if (!mounted) return;
    setState(() {
      _daftarCabang = _service.getSemuaCabang();
      _isLoading = false;
      _isLocating = false;
      _lokasiDipakai = false;
      if (_daftarCabang.isNotEmpty && _cabangTerpilih == null) {
        _cabangTerpilih = _daftarCabang.first;
      }
    });
  }

  void _pilihCabang(Cabang cabang) {
    setState(() {
      _cabangTerpilih = cabang;
    });
  }

  void _konfirmasi() {
    final cabang = _cabangTerpilih;
    if (cabang == null || _sudahMemilih) return;

    setState(() => _sudahMemilih = true);

    if (widget.onCabangDipilih != null) {
      widget.onCabangDipilih!(cabang);
    } else {
      Navigator.of(context).pop(cabang);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null && _daftarCabang.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pilih Cabang'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: NetworkErrorState(onRetry: _muatCabang),
      );
    }

    if (_daftarCabang.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pilih Cabang'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: EmptyState(
          title: 'Cabang tidak ditemukan',
          message: 'Belum ada cabang yang tersedia saat ini.',
          buttonText: 'Muat ulang',
          onButtonPressed: _muatCabang,
          icon: Icons.location_off,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Cabang'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildInfoLokasi(),
          // Daftar cabang
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s8,
                vertical: AppSpacing.s8,
              ),
              itemCount: _daftarCabang.length,
              itemBuilder: (context, index) {
                final cabang = _daftarCabang[index];
                final isSelected = _cabangTerpilih?.id == cabang.id;
                final isTerdekat = _lokasiDipakai && index == 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceSoft,
                    child: Icon(
                      Icons.store,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    cabang.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: AppText.w700,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        cabang.alamat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: AppText.w400,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (isTerdekat) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.badgeBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Terdekat',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: AppText.w700,
                                  color: AppColors.badgeText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Icon(
                            _lokasiDipakai
                                ? Icons.directions_walk
                                : Icons.location_off_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _lokasiDipakai
                                  ? '${cabang.jarakDisplay} · ${AppMessages.jarakCabang}'
                                  : 'Jarak belum tersedia',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: AppText.w500,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.success)
                      : const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                        ),
                  onTap: () => _pilihCabang(cabang),
                  selected: isSelected,
                  selectedTileColor: AppColors.primaryTint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: 6,
                  ),
                );
              },
            ),
          ),
          // Tombol konfirmasi
          if (_cabangTerpilih != null)
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s8,
                  AppSpacing.s16,
                  AppSpacing.s8,
                ),
                child: PrimaryButton(
                  text: 'Pilih Cabang Ini',
                  onPressed: _sudahMemilih ? null : _konfirmasi,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoLokasi() {
    if (_isLocating) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s12),
        color: AppColors.primaryTint,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Mencari cabang terdekat...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: AppText.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    // Lokasi gagal / tidak aktif: beri solusi yang jelas.
    if (!_lokasiDipakai) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        color: AppColors.badgeBg,
        child: Row(
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 18,
              color: AppColors.badgeText,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Lokasi tidak aktif. Pilih cabang manual, atau ketuk Coba lagi.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: AppText.w600,
                  color: AppColors.badgeText,
                  height: 1.4,
                ),
              ),
            ),
            TextButton(
              onPressed: _muatCabang,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.badgeText,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(44, 44),
              ),
              child: Text(
                'Coba lagi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: AppText.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s12),
      color: AppColors.primaryTint,
      child: Column(
        children: [
          Text(
            'Cabang terdekat sudah dipilih otomatis. Kamu bisa pilih cabang lain.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: AppText.w600,
              color: AppColors.primary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _cabangTerpilih = _daftarCabang.first;
              });
            },
            icon: const Icon(Icons.near_me, size: 16, color: AppColors.primary),
            label: Text(
              'Pilih otomatis (terdekat)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: AppText.w800,
                color: AppColors.primary,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(44, 32),
            ),
          ),
        ],
      ),
    );
  }
}
