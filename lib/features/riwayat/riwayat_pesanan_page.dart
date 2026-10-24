import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../state/order_store.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_card.dart';
import '../cabang/cabang_model.dart';
import '../tracking/tracking_page.dart';

/// Riwayat pesanan yang sudah selesai.
class RiwayatPesananPage extends StatelessWidget {
  final Cabang? cabangTerpilih;

  const RiwayatPesananPage({super.key, this.cabangTerpilih});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat pesanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: OrderStore.instance,
        builder: (context, _) {
          final daftar = OrderStore.instance.riwayat;
          if (daftar.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'Riwayat masih kosong.',
              description: 'Setelah pesanan pertama selesai, riwayatnya akan muncul di sini.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s20),
            itemCount: daftar.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) {
              final order = daftar[index];
              return OrderCard(
                order: order,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrackingPage(
                        pesanan: order,
                        cabangTerpilih: cabangTerpilih,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
