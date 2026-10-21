import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme.dart';
import 'features/splash/splash_page.dart';
import 'widgets/notification_panel.dart';

void main() {
  // Font sudah dibundel di assets, jadi tidak perlu ambil dari internet.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Nusantara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Panel notifikasi menempel di atas halaman; tutup otomatis begitu
      // pengguna berpindah halaman supaya tidak tertinggal.
      navigatorObservers: [NotificationPanelObserver()],
      // Batasi skala font agar label tidak terpotong di HP dengan
      // pengaturan ukuran teks yang sangat besar.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashPage(),
    );
  }
}
