# MyPortfolio Mobile

Aplikasi mobile portofolio pribadi milik **Adinata Alaudin Pranaja** untuk mata kuliah Pemrograman Berbasis Platform (PBP), kelas C. Aplikasi ini dibangun dengan Flutter dan nantinya akan menjadi klien bagi REST API Django dari proyek web [myportofolio](https://github.com/adinatapranaja/myportofolio).

- NPM: 2506656356
- Program studi: S1 Sistem Informasi, Universitas Indonesia

## Menjalankan proyek secara lokal

Prasyarat: Flutter SDK (channel stable) dan Google Chrome. Proyek ini dikembangkan dengan Flutter 3.38 dan Dart 3.10.

```bash
# Periksa kelengkapan toolchain
flutter doctor

# Ambil dependency
flutter pub get

# Jalankan di Google Chrome
flutter run -d chrome
```

Untuk menjalankan di emulator Android atau perangkat fisik, gunakan `flutter run` setelah Android toolchain pada `flutter doctor` bertanda centang.

## Pemeriksaan cepat

Jalankan analisis statis dan widget test sebelum commit:

```bash
flutter analyze
flutter test
```

## Struktur proyek

```text
myportofolio_mobile/
├── lib/
│   ├── main.dart   # Entry point: MyApp, MaterialApp, dan tema warna
│   └── menu.dart   # Halaman utama, InfoCard, ItemHomepage, dan ItemCard
├── test/
│   └── widget_test.dart
├── pubspec.yaml    # Manifes proyek dan dependency
└── analysis_options.yaml
```

## Ringkasan Tutorial PBP

### Tutorial 8 — Basic Flutter

Tutorial 8 memulai paruh kedua mata kuliah, yaitu pengembangan aplikasi mobile multiplatform dengan Flutter dan Dart.

1. Proyek dibuat dengan `flutter create myportofolio_mobile` di repositori terpisah dari proyek Django, karena keduanya merupakan proyek yang berbeda dan nantinya terhubung melalui API.
2. Halaman utama dipindahkan dari `main.dart` ke `menu.dart` agar `main.dart` hanya berisi bootstrap aplikasi (*separation of concerns*).
3. Tema memakai `ColorScheme.fromSeed` dengan warna dasar indigo dan warna sekunder amber, sehingga seluruh komponen Material 3 mendapat palet yang serasi.
4. `MyHomePage` diubah dari `StatefulWidget` menjadi `StatelessWidget` karena halaman menu hanya menampilkan data tetap dan tidak menyimpan state yang berubah.
5. `InfoCard` adalah widget reusable untuk menampilkan NPM, nama, dan kelas tanpa menulis kode kartu berulang.
6. `ItemHomepage` adalah model data tombol menu, sedangkan `ItemCard` menampilkannya sebagai kartu berikon dengan efek sentuh `InkWell`. Saat ditekan, kartu menampilkan `SnackBar` melalui `ScaffoldMessenger`.
7. Halaman dirakit dengan `Scaffold`, `AppBar`, `Padding`, `Column`, `Row`, dan `GridView.count` tiga kolom. `shrinkWrap: true` membuat kisi menyesuaikan tinggi isinya di dalam `Column`.
8. Kualitas kode diperiksa dengan `flutter analyze` hingga tidak ada peringatan.

Beberapa penyesuaian dari contoh tutorial:

- `MyHomePage`, `ItemCard`, dan `ItemHomepage` memakai konstruktor `const`, dan daftar tombol disimpan sebagai `static const`. Widget yang tidak berubah dapat dibuat sekali dan dipakai ulang saat halaman dibangun ulang.
- Test counter bawaan `flutter create` diganti dengan widget test yang memeriksa kartu informasi, tombol menu, dan pesan `SnackBar`.
- `/android/build/` ditambahkan ke `.gitignore` agar hasil build Android tidak ikut ter-commit.

Sumber: [Tutorial 8 PBP](https://pbp.cs.ui.ac.id/tutorial/tutorial-8.html).
