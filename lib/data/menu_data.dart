/// Data menu dan banner promosi.
///
/// Semua data masih lokal (mock) agar alur aplikasi bisa dicoba tanpa API.
/// Gambar memakai URL publik Unsplash dan Wikimedia Commons (CC0/public
/// domain sehingga bebas dipakai tanpa wajib mencantumkan atribusi); bila
/// jaringan bermasalah, widget gambar akan menampilkan ikon pengganti.
library;

class AddonOption {
  final String id;
  final String nama;
  final int harga;

  const AddonOption({required this.id, required this.nama, this.harga = 0});
}

class AddonGroup {
  final String id;
  final String nama;
  final bool wajib;
  final bool multiPilih;
  final List<AddonOption> opsi;

  const AddonGroup({
    required this.id,
    required this.nama,
    required this.opsi,
    this.wajib = false,
    this.multiPilih = false,
  });

  AddonOption get opsiAwal => opsi.first;
}

class MenuProduk {
  final String id;
  final String nama;
  final String deskripsi;
  final String kategori;
  final String takaran;
  final String imageUrl;
  final int harga;
  final bool tersedia;
  final bool populer;
  final List<AddonGroup> addon;

  const MenuProduk({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.takaran,
    required this.imageUrl,
    required this.harga,
    this.tersedia = true,
    this.populer = false,
    this.addon = const [],
  });
}

class BannerPromo {
  final String judul;
  final String subjudul;
  final String label;
  final String imageUrl;
  final String menuId;

  const BannerPromo({
    required this.judul,
    required this.subjudul,
    required this.label,
    required this.imageUrl,
    required this.menuId,
  });
}

const String _unsplash = 'https://images.unsplash.com/';
const String _imageQuery = '?auto=format&fit=crop&w=400&q=70';

String _foto(String id) => '$_unsplash$id$_imageQuery';

/// URL gambar dengan lebar baru — untuk halaman detail/banner yang lebih lebar
/// daripada thumbnail daftar menu. Mendukung pola Unsplash (w=数字) dan
/// Wikimedia Commons (/thumb/.../400px-nama.jpg).
String fotoUkuran(String url, int lebar) {
  var hasil = url.replaceAll(RegExp(r'[?&]w=\d+'), 'w=$lebar');
  hasil = hasil.replaceAllMapped(
    RegExp(r'/\d+px-'),
    (m) => '/$lebar' 'px-',
  );
  return hasil;
}

const List<String> kategoriMenu = [
  'Semua',
  'Nasi',
  'Mie',
  'Ayam',
  'Minuman',
  'Camilan',
];

const List<AddonGroup> _levelPedas = [
  AddonGroup(
    id: 'level',
    nama: 'Level pedas',
    wajib: true,
    opsi: [
      AddonOption(id: 'tidak-pedas', nama: 'Tidak pedas'),
      AddonOption(id: 'sedang', nama: 'Sedang'),
      AddonOption(id: 'pedas', nama: 'Pedas'),
    ],
  ),
];

const List<AddonGroup> _tambahanAyam = [
  AddonGroup(
    id: 'tambahan',
    nama: 'Tambahan',
    multiPilih: true,
    opsi: [
      AddonOption(id: 'telur', nama: 'Telur dadar', harga: 3000),
      AddonOption(id: 'keju', nama: 'Keju parut', harga: 5000),
      AddonOption(id: 'nasi', nama: 'Nasi tambah', harga: 4000),
    ],
  ),
];

final List<MenuProduk> daftarMenu = [
  MenuProduk(
    id: 'ayam-geprek',
    nama: 'Ayam Geprek Spesial',
    deskripsi: 'Ayam goreng renyah yang digeprek dengan sambal bawang pedas, disajikan bersama nasi hangat dan lalapan segar.',
    kategori: 'Ayam',
    takaran: '1 porsi',
    imageUrl: _foto('photo-1562967914-608f82629710'),
    harga: 22000,
    populer: true,
    addon: [..._levelPedas, ..._tambahanAyam],
  ),
  MenuProduk(
    id: 'nasi-goreng',
    nama: 'Nasi Goreng Kampung',
    deskripsi: 'Nasi goreng dengan bumbu kampung, telur, dan irisan ayam. Wangi, gurih, dan pas untuk makan siang.',
    kategori: 'Nasi',
    takaran: '1 piring',
    imageUrl: _foto('photo-1603133872878-684f208fb84b'),
    harga: 18000,
    populer: true,
    addon: [
      const AddonGroup(
        id: 'level',
        nama: 'Level pedas',
        opsi: [
          AddonOption(id: 'tidak-pedas', nama: 'Tidak pedas'),
          AddonOption(id: 'sedang', nama: 'Sedang'),
          AddonOption(id: 'pedas', nama: 'Pedas'),
        ],
      ),
      const AddonGroup(
        id: 'tambahan',
        nama: 'Tambahan',
        multiPilih: true,
        opsi: [
          AddonOption(id: 'telur-ceplok', nama: 'Telur ceplok', harga: 4000),
          AddonOption(id: 'sosis', nama: 'Sosis', harga: 6000),
          AddonOption(id: 'kerupuk', nama: 'Kerupuk', harga: 2000),
        ],
      ),
    ],
  ),
  MenuProduk(
    id: 'mie-ayam',
    nama: 'Mie Ayam Bakso',
    deskripsi: 'Mie kenyal dengan topping ayam kecap, sawi hijau, dan bakso sapi. Kuah kaldu hangat disajikan terpisah.',
    kategori: 'Mie',
    takaran: '1 mangkuk',
    imageUrl: _foto('photo-1585032226651-759b368d7246'),
    harga: 15000,
    addon: [
      const AddonGroup(
        id: 'ukuran',
        nama: 'Pilih ukuran',
        wajib: true,
        opsi: [
          AddonOption(id: 'reguler', nama: 'Reguler'),
          AddonOption(id: 'jumbo', nama: 'Jumbo', harga: 5000),
        ],
      ),
      const AddonGroup(
        id: 'tambahan',
        nama: 'Tambahan',
        multiPilih: true,
        opsi: [
          AddonOption(id: 'bakso', nama: 'Bakso sapi', harga: 5000),
          AddonOption(id: 'pangsit', nama: 'Pangsit goreng', harga: 4000),
        ],
      ),
    ],
  ),
  MenuProduk(
    id: 'es-teh',
    nama: 'Es Teh Manis',
    deskripsi: 'Teh melati seduh segar dengan gula pasir. Manisnya bisa diatur lewat pilihan es dan ukuran.',
    kategori: 'Minuman',
    takaran: '1 gelas',
    imageUrl: _foto('photo-1556679343-c7306c1976bc'),
    harga: 5000,
    addon: [
      const AddonGroup(
        id: 'ukuran',
        nama: 'Pilih ukuran',
        wajib: true,
        opsi: [
          AddonOption(id: 'reguler', nama: 'Reguler'),
          AddonOption(id: 'jumbo', nama: 'Jumbo', harga: 3000),
        ],
      ),
      const AddonGroup(
        id: 'es',
        nama: 'Level es',
        wajib: true,
        opsi: [
          AddonOption(id: 'normal', nama: 'Es normal'),
          AddonOption(id: 'sedikit', nama: 'Es sedikit'),
          AddonOption(id: 'tanpa', nama: 'Tanpa es'),
        ],
      ),
    ],
  ),
  MenuProduk(
    id: 'ayam-bakar',
    nama: 'Ayam Bakar Madu',
    deskripsi: 'Ayam kampung dibakar dengan olesan madu dan bumbu kecap. Aroma smokey dengan rasa manis gurih.',
    kategori: 'Ayam',
    takaran: '1 ekor',
    imageUrl: _foto('photo-1555939594-58d7cb561ad1'),
    harga: 35000,
    populer: true,
    addon: [..._levelPedas, ..._tambahanAyam],
  ),
  MenuProduk(
    id: 'es-jeruk',
    nama: 'Es Jeruk Segar',
    deskripsi: 'Perasan jeruk peras asli dengan es batu. Segar dan cocok menemani menu ayam atau nasi.',
    kategori: 'Minuman',
    takaran: '1 gelas',
    imageUrl: _foto('photo-1544145945-f90425340c7e'),
    harga: 6000,
    addon: [
      const AddonGroup(
        id: 'ukuran',
        nama: 'Pilih ukuran',
        wajib: true,
        opsi: [
          AddonOption(id: 'reguler', nama: 'Reguler'),
          AddonOption(id: 'jumbo', nama: 'Jumbo', harga: 3000),
        ],
      ),
      const AddonGroup(
        id: 'gula',
        nama: 'Tingkat manis',
        wajib: true,
        opsi: [
          AddonOption(id: 'normal', nama: 'Manis normal'),
          AddonOption(id: 'kurang', nama: 'Kurang manis'),
          AddonOption(id: 'tanpa-gula', nama: 'Tanpa gula'),
        ],
      ),
    ],
  ),
  MenuProduk(
    id: 'nasi-uduk',
    nama: 'Nasi Uduk Komplit',
    deskripsi: 'Nasi uduk gurih dengan ayam suwir, tempe orek, telur balado, dan sambal kacang.',
    kategori: 'Nasi',
    takaran: '1 porsi',
    imageUrl: _foto('photo-1512058564366-18510be2db19'),
    harga: 20000,
    addon: [
      const AddonGroup(
        id: 'tambahan',
        nama: 'Tambahan',
        multiPilih: true,
        opsi: [
          AddonOption(id: 'telur', nama: 'Telur balado', harga: 4000),
          AddonOption(id: 'ayam', nama: 'Ayam suwir ekstra', harga: 7000),
          AddonOption(id: 'tempe', nama: 'Tempe orek', harga: 3000),
        ],
      ),
    ],
  ),
  MenuProduk(
    id: 'pisang-goreng',
    nama: 'Pisang Goreng Keju',
    deskripsi: 'Pisang raja goreng renyah dengan topping keju parut dan susu kental manis. Camilan hangat favorit sore.',
    kategori: 'Camilan',
    takaran: '5 potong',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Pisang_Goreng_Hangat.jpg/500px-Pisang_Goreng_Hangat.jpg',
    harga: 12000,
    populer: true,
    addon: [
      const AddonGroup(
        id: 'topping',
        nama: 'Topping',
        multiPilih: true,
        opsi: [
          AddonOption(id: 'keju', nama: 'Keju parut', harga: 3000),
          AddonOption(id: 'coklat', nama: 'Cokelat leleh', harga: 3000),
          AddonOption(id: 'susu', nama: 'Susu kental manis', harga: 2000),
        ],
      ),
    ],
  ),
  MenuProduk(
    id: 'sate-ayam',
    nama: 'Sate Ayam Madura',
    deskripsi: 'Sepuluh tusuk sate ayam bakar dengan bumbu kacang kental, kecap, dan irisan bawang merah.',
    kategori: 'Ayam',
    takaran: '10 tusuk',
    imageUrl: _foto('photo-1529042410759-befb1204b468'),
    harga: 25000,
    addon: [
      const AddonGroup(
        id: 'tambahan',
        nama: 'Tambahan',
        multiPilih: true,
        opsi: [
          AddonOption(id: 'lontong', nama: 'Lontong', harga: 5000),
          AddonOption(id: 'sate-extra', nama: '3 tusuk ekstra', harga: 8000),
        ],
      ),
    ],
  ),
  MenuProduk(
    id: 'tahu-crispy',
    nama: 'Tahu Crispy',
    deskripsi: 'Tahu goreng renyah dengan saus pedas manis. Cocok untuk camilan ringan.',
    kategori: 'Camilan',
    takaran: '8 potong',
    imageUrl: _foto('photo-1559847844-5315695dadae'),
    harga: 10000,
    tersedia: false,
    addon: [
      const AddonGroup(
        id: 'saus',
        nama: 'Pilih saus',
        wajib: true,
        opsi: [
          AddonOption(id: 'pedas-manis', nama: 'Pedas manis'),
          AddonOption(id: 'mayo', nama: 'Mayones'),
          AddonOption(id: 'keju', nama: 'Saus keju', harga: 3000),
        ],
      ),
    ],
  ),
];

const List<BannerPromo> bannerPromo = [
  BannerPromo(
    label: 'PROMO HARI INI',
    judul: 'Geprek pedas, harga bersahabat',
    subjudul: 'Ayam Geprek Spesial mulai Rp 22.000',
    imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?auto=format&fit=crop&w=600&q=75',
    menuId: 'ayam-geprek',
  ),
  BannerPromo(
    label: 'PAKET MAKAN SIANG',
    judul: 'Nasi goreng kampung bikin kenyang',
    subjudul: 'Tambahkan telur ceplok hanya Rp 4.000',
    imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=600&q=75',
    menuId: 'nasi-goreng',
  ),
  BannerPromo(
    label: 'CAMILAN SORE',
    judul: 'Pisang goreng keju, manisnya pas',
    subjudul: 'Cocok disantap bersama es teh',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Pisang_Goreng_Hangat.jpg/960px-Pisang_Goreng_Hangat.jpg',
    menuId: 'pisang-goreng',
  ),
];

List<MenuProduk> get menuPopuler =>
    daftarMenu.where((menu) => menu.populer).toList();

MenuProduk? menuById(String id) {
  for (final menu in daftarMenu) {
    if (menu.id == id) return menu;
  }
  return null;
}
