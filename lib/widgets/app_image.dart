import 'package:flutter/material.dart';

import '../core/constants.dart';

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

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
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
