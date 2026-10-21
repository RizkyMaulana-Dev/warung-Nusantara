import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../core/messages.dart';
import 'button.dart';

/// Layar kosong / galat dengan ikon, teks singkat, dan tombol aksi.
/// Digunakan untuk: jaringan lemah, tidak ada internet, data kosong, galat.
class ErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  const ErrorState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.s24),
            // Judul
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: AppText.w800,
                color: AppColors.text,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s12),
            // Pesan
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: AppText.w400,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s36),
            // Tombol utama
            if (onButtonPressed != null)
              PrimaryButton(text: buttonText, onPressed: onButtonPressed),
            if (secondaryButtonText != null &&
                onSecondaryButtonPressed != null) ...[
              const SizedBox(height: AppSpacing.s14),
              SecondaryButton(
                text: secondaryButtonText!,
                onPressed: onSecondaryButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Varian layar kosong
// =============================================================================

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: icon,
      title: title,
      message: message,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }
}

class NetworkErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.wifi_off,
      title: 'Jaringan lemah',
      message: AppMessages.jaringanLemah,
      buttonText: AppMessages.muatUlang,
      onButtonPressed: onRetry,
      secondaryButtonText: AppMessages.cariSinyalLebihBagus,
      onSecondaryButtonPressed: onRetry,
    );
  }
}

class NoInternetState extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.wifi_off,
      title: 'Tidak ada internet',
      message: AppMessages.tidakAdaInternet,
      buttonText: AppMessages.muatUlang,
      onButtonPressed: onRetry,
    );
  }
}

class EmptyCartState extends StatelessWidget {
  final VoidCallback onViewMenu;

  const EmptyCartState({super.key, required this.onViewMenu});

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      icon: Icons.shopping_cart_outlined,
      title: 'Keranjangmu masih kosong',
      message: 'Yuk, pilih menu favoritmu terlebih dahulu.',
      buttonText: 'Lihat Menu',
      onButtonPressed: onViewMenu,
    );
  }
}
