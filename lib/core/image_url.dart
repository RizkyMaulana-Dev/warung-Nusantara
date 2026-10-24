/// Ukuran thumbnail yang didukung Wikimedia Commons.
///
/// Wikimedia menolak lebar arbitrer (mis. 320/600 px) dan hanya menerima
/// ukuran standar ini. Pakai ukuran terkecil yang masih >= lebar diminta.
const List<int> _ukuranThumbnailWikimedia = [
  250,
  330,
  500,
  960,
  1280,
  1920,
  3840,
];

int _ukuranWikimediaUntuk(int lebar) {
  for (final ukuran in _ukuranThumbnailWikimedia) {
    if (ukuran >= lebar) return ukuran;
  }
  return _ukuranThumbnailWikimedia.last;
}

/// Mengubah lebar gambar jaringan.
///
/// Unsplash memakai parameter `w`; Wikimedia memakai segmen `/NNNpx-` dan
/// harus dipetakan ke ukuran thumbnail standar agar tidak menghasilkan 400.
String ubahUkuranGambar(String url, int lebar) {
  if (url.isEmpty) return url;

  final uri = Uri.tryParse(url);
  final wikimedia =
      uri != null &&
      (uri.host == 'upload.wikimedia.org' ||
          uri.host == 'thumb.wikimedia.org') &&
      url.contains('/thumb/');
  if (wikimedia) {
    final ukuran = _ukuranWikimediaUntuk(lebar);
    return url.replaceAllMapped(
      RegExp(r'/\d+px-'),
      (_) => '/${ukuran}px-',
    );
  }

  return url.replaceAll(RegExp(r'[?&]w=\d+'), 'w=$lebar');
}

/// Menurunkan ukuran gambar jaringan untuk mode hemat data.
///
/// Mendukung URL Unsplash (`w`/`q`) dan Wikimedia Commons (`/NNNpx-`).
/// URL lain dikembalikan apa adanya supaya tidak merusak sumber gambar.
String urlHematData(String url, {int lebar = 320, int kualitas = 50}) {
  if (url.isEmpty) return url;

  var hasil = ubahUkuranGambar(url, lebar);
  hasil = hasil.replaceAllMapped(
    RegExp(r'([?&])q=\d+'),
    (match) => '${match[1]}q=$kualitas',
  );
  return hasil;
}
