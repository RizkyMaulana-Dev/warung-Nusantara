import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_pesanan/core/image_url.dart';
import 'package:umkm_pesanan/data/menu_data.dart';
import 'package:umkm_pesanan/state/pengaturan_store.dart';
import 'package:umkm_pesanan/widgets/app_image.dart';

String _urlDari(Image image) {
  final provider = image.image;
  final network = provider is ResizeImage
      ? provider.imageProvider as NetworkImage
      : provider as NetworkImage;
  return network.url;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('urlHematData menurunkan lebar dan kualitas gambar Unsplash', () {
    const url =
        'https://images.unsplash.com/photo-1?auto=format&fit=crop&w=600&q=70';

    final hasil = urlHematData(url);

    expect(hasil, contains('w=320'));
    expect(hasil, contains('q=50'));
    expect(hasil, isNot(contains('w=600')));
  });

  test('urlHematData memakai ukuran Wikimedia yang didukung', () {
    const url =
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Foo.jpg/600px-Foo.jpg';

    expect(urlHematData(url), contains('/330px-Foo.jpg'));
  });

  test('fotoUkuran memakai ukuran Wikimedia yang didukung', () {
    const url =
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Pisang_Goreng_Hangat.jpg/500px-Pisang_Goreng_Hangat.jpg';

    expect(
      fotoUkuran(url, 600),
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Pisang_Goreng_Hangat.jpg/960px-Pisang_Goreng_Hangat.jpg',
    );
  });

  test('urlHematData tidak mengubah URL tanpa parameter yang dikenal', () {
    const url = 'https://example.com/gambar.jpg';

    expect(urlHematData(url), url);
  });

  testWidgets('AppImage memakai URL hemat dan berubah saat toggle dimatikan', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await PengaturanStore.instance.muat();
    await PengaturanStore.instance.setHematData(true);

    await tester.pumpWidget(
      const MaterialApp(
        home: AppImage(
          url: 'https://images.unsplash.com/photo-1?auto=format&fit=crop&w=600&q=70',
        ),
      ),
    );

    expect(
      _urlDari(tester.widget<Image>(find.byType(Image))),
      contains('w=320'),
    );

    await PengaturanStore.instance.setHematData(false);
    await tester.pump();

    expect(
      _urlDari(tester.widget<Image>(find.byType(Image))),
      contains('w=600'),
    );
  });
}
