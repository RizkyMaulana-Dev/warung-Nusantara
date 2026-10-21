import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../state/notification_store.dart';
import 'empty_state.dart';

/// Panel notifikasi yang menempel di bawah lonceng.
///
/// Dipasang lewat [OverlayEntry] supaya bisa muncul di atas halaman mana pun,
/// dengan penghalang transparan: ketuk di luar panel untuk menutup.
OverlayEntry? _panelAktif;

bool get panelNotifikasiTerbuka => _panelAktif != null;

/// Tutup panel tanpa animasi (dipakai saat pengguna berpindah halaman).
void tutupPanelNotifikasi() {
  final panel = _panelAktif;
  _panelAktif = null;
  if (panel != null && panel.mounted) panel.remove();
}

void showNotificationPanel(BuildContext context, {required Rect anchor}) {
  if (_panelAktif != null) return; // jangan sampai ada dua panel

  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  // Membuka panel berarti semua notifikasi dianggap sudah dibaca.
  NotificationStore.instance.tandaiSemuaDibaca();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _NotificationPanel(
      anchor: anchor,
      onTutup: () {
        if (_panelAktif == entry) _panelAktif = null;
        if (entry.mounted) entry.remove();
      },
    ),
  );

  _panelAktif = entry;
  overlay.insert(entry);
}

/// Menutup panel saat pengguna berpindah halaman supaya tidak tertinggal
/// menutupi halaman baru.
class NotificationPanelObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      tutupPanelNotifikasi();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      tutupPanelNotifikasi();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      tutupPanelNotifikasi();
}

class _NotificationPanel extends StatefulWidget {
  final Rect anchor;
  final VoidCallback onTutup;

  const _NotificationPanel({required this.anchor, required this.onTutup});

  @override
  State<_NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<_NotificationPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _tutup() async {
    await _controller.reverse();
    widget.onTutup();
  }

  @override
  Widget build(BuildContext context) {
    final lebarLayar = MediaQuery.sizeOf(context).width;
    final lebarPanel = lebarLayar - AppSpacing.s24 > 340
        ? 340.0
        : lebarLayar - AppSpacing.s24;

    return Stack(
      children: [
        // Penghalang: ketuk di luar panel menutup panel ini.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tutup,
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          top: widget.anchor.bottom + AppSpacing.s6,
          right: AppSpacing.s12,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeIn,
            ),
            alignment: Alignment.topRight,
            child: FadeTransition(
              opacity: _controller,
              child: _kartu(context, lebarPanel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _kartu(BuildContext context, double lebar) {
    return SizedBox(
      width: lebar,
      child: Material(
        color: AppColors.surface,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSize.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: AnimatedBuilder(
          animation: NotificationStore.instance,
          builder: (context, _) {
            final daftar = NotificationStore.instance.semua;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s14,
                    AppSpacing.s16,
                    AppSpacing.s10,
                  ),
                  child: Text(
                    'Notifikasi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: AppText.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                if (daftar.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
                    child: EmptyState(
                      icon: Icons.notifications_none,
                      title: 'Belum ada notifikasi.',
                      description: 'Setelah pesanan dibuat, kabar pesanannya muncul di sini.',
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 340),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s4,
                      ),
                      itemCount: daftar.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        indent: AppSpacing.s16,
                        endIndent: AppSpacing.s16,
                        color: AppColors.divider,
                      ),
                      itemBuilder: (context, index) {
                        final notifikasi = daftar[index];
                        return ListTile(
                          dense: true,
                          leading: const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryTint,
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            notifikasi.judul,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: AppText.w700,
                              color: AppColors.text,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notifikasi.isi,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                notifikasi.waktuRingkas,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
