import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = "2506656356";
  final String nama = "Adinata Alaudin Pranaja";
  final String kelas = "PBP C";

  // Warna memakai tingkat 700 agar teks putih tetap kontras dan mudah dibaca
  // di atas latar setiap kartu. Kartu yang membuka halaman lain menyimpan
  // tujuannya di `destination`.
  static const List<ItemHomepage> items = [
    ItemHomepage("Lihat Experience", Icons.work_history, Color(0xFF1976D2)),
    ItemHomepage(
      "Tambah Experience",
      Icons.add_circle,
      Color(0xFF388E3C),
      destination: ExperienceFormPage.new,
      requiresLogin: true,
    ),
    ItemHomepage(
      "Tambah Proyek",
      Icons.create_new_folder,
      Color(0xFF7B1FA2),
      destination: ProjectFormPage.new,
      requiresLogin: true,
    ),
    ItemHomepage("Logout", Icons.logout, Color(0xFFD32F2F)),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      // Body dapat digulir agar empat kartu menu tetap terjangkau di layar
      // ponsel yang pendek.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
            // IntrinsicHeight + stretch membuat ketiga kartu setinggi kartu
            // tertinggi, sehingga nama yang turun ke dua baris tetap rapi.
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InfoCard(title: 'NPM', content: npm),
                  InfoCard(title: 'Name', content: nama),
                  InfoCard(title: 'Class', content: kelas),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  // GridView menampilkan empat kartu tombol dalam kisi 2 kolom.
                  // Penggulirannya diserahkan ke SingleChildScrollView di luar.
                  GridView.count(
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        // Menyesuaikan lebar kartu dengan proporsi layar (dibagi 3.5).
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Model data satu tombol menu: label, ikon, warna latar, dan halaman tujuan.
///
/// Warna dan tujuan disimpan di model sehingga [ItemCard] cukup membaca
/// [color] dan [destination] tanpa percabangan per nama tombol.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  /// Pembuat halaman yang dibuka dengan `Navigator.push()`, atau `null` jika
  /// tombol hanya menampilkan SnackBar.
  final Widget Function()? destination;

  /// Whether [destination] needs a logged-in user (checked by `ensureLoggedIn`).
  final bool requiresLogin;

  const ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.destination,
    this.requiresLogin = false,
  });
}
