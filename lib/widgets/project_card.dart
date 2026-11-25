import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onTap(BuildContext context) async {
    // Menampilkan SnackBar dengan pesan interaktif.
    _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");

    if (item.name == "Logout") {
      final auth = context.read<AuthState>();
      if (!auth.isLoggedIn) return;
      await auth.logout();
      if (!context.mounted) return;
      _showSnackBar(context, "Kamu berhasil logout.");
      return;
    }

    final destination = item.destination;
    if (destination == null) return;
    // Halaman yang dilindungi meminta login terlebih dahulu.
    if (item.requiresLogin && !await ensureLoggedIn(context)) return;
    if (!context.mounted) return;
    // push() menumpuk halaman tujuan di atas menu, sehingga tombol
    // kembali bawaan perangkat membawa pengguna ke halaman ini lagi.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Menggunakan warna latar milik masing-masing tombol.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
