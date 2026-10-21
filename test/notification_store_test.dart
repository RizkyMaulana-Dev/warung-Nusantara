import 'package:flutter_test/flutter_test.dart';
import 'package:umkm_pesanan/state/notification_store.dart';

AppNotification _notifikasi(String id) => AppNotification(
  id: id,
  judul: 'Pesanan dibuat',
  isi: 'Pesanan $id sedang disiapkan warung.',
  waktu: DateTime(2026, 10, 21, 10, 5),
);

void main() {
  setUp(() => NotificationStore.instance.kosongkan());

  test('menambah notifikasi menaikkan jumlah belum dibaca', () {
    NotificationStore.instance.tambah(_notifikasi('n1'));

    expect(NotificationStore.instance.semua, hasLength(1));
    expect(NotificationStore.instance.jumlahBelumDibaca, 1);
  });

  test(
    'tandaiSemuaDibaca mengosongkan hitungan dan menandai semua terbaca',
    () {
      NotificationStore.instance.tambah(_notifikasi('n1'));
      NotificationStore.instance.tambah(_notifikasi('n2'));

      NotificationStore.instance.tandaiSemuaDibaca();

      expect(NotificationStore.instance.jumlahBelumDibaca, 0);
      expect(NotificationStore.instance.semua.every((n) => n.dibaca), isTrue);
    },
  );

  test('notifikasi terbaru berada di paling atas', () {
    NotificationStore.instance.tambah(_notifikasi('lama'));
    NotificationStore.instance.tambah(_notifikasi('baru'));

    expect(NotificationStore.instance.semua.first.id, 'baru');
  });

  test('waktuRingkas menampilkan tanggal dan jam yang mudah dibaca', () {
    expect(_notifikasi('n1').waktuRingkas, '21/10/2026 10.05');
  });
}
