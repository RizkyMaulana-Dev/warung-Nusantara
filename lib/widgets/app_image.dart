import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/image_url.dart';
import '../state/pengaturan_store.dart';

/// Gambar jaringan dengan placeholder, cache decode kecil, dan fallback lokal.
class AppImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final int cacheWidth;
  final int cacheHeight;

  const AppImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackIcon = Icons.restaurant,
    this.fallbackIconSize = 28,
    this.cacheWidth = 512,
    this.cacheHeight = 512,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _fallback();

    // Dengarkan preferensi supaya gambar yang sudah tampil langsung
    // menyesuaikan saat mode hemat data diubah.
    return AnimatedBuilder(
      animation: PengaturanStore.instance,
      builder: (context, _) {
        final hemat = PengaturanStore.instance.hematData;
        final urlGambar = hemat ? urlHematData(url) : url;
        // Mode hemat: URL lebih kecil, decode lebih kecil, dan filter
        // kualitas rendah supaya render lebih ringan.
        final lebarCache = hemat ? (cacheWidth * 0.6).round() : cacheWidth;
        final tinggiCache = hemat ? (cacheHeight * 0.6).round() : cacheHeight;

        return Image.network(
          urlGambar,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: lebarCache,
          cacheHeight: tinggiCache,
          filterQuality: hemat ? FilterQuality.low : FilterQuality.medium,
          gaplessPlayback: true,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: width,
              height: height,
              color: AppColors.surfaceSoft,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _fallback(),
        );
      },
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        color: AppColors.textSecondary,
        size: fallbackIconSize,
      ),
    );
  }
}
