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

## Refleksi

### Tugas 7

Implementasi Tugas 7 mengubah aplikasi contoh menjadi portofolio pribadi:

- Tiga `InfoCard` menampilkan NPM 2506656356, nama Adinata Alaudin Pranaja, dan kelas PBP C. Baris kartu dibungkus `IntrinsicHeight` dengan `CrossAxisAlignment.stretch` dan teks rata tengah, sehingga ketiga kartu tetap sama tinggi ketika nama turun ke dua baris di layar sempit.
- Tombol menu disesuaikan dengan bagian Experience dari proyek web: **Lihat Experience**, **Tambah Experience**, dan **Logout**.
- Model `ItemHomepage` mendapat atribut `color`, lalu `ItemCard` memakai `item.color` sebagai latar. Warna biru, hijau, dan merah tingkat 700 dipilih agar teks putih tetap kontras, tanpa percabangan warna per tombol.
- Setiap tombol menampilkan `SnackBar` "Kamu telah menekan tombol [Nama Tombol]!".
- Widget test memeriksa data identitas, label tombol, warna unik setiap tombol, dan pesan `SnackBar` setiap tombol. `flutter analyze` tidak menemukan isu.

1. **Widget tree** adalah susunan bertingkat seluruh widget yang membentuk antarmuka. Setiap widget dapat memiliki satu anak (`child`) atau banyak anak (`children`), dan aplikasi ini tersusun sebagai `MaterialApp` → `MyHomePage` → `Scaffold` → `Padding` → `Column` → `Row`/`GridView` → `InfoCard`/`ItemCard`. Hubungan induk-anak bekerja dalam dua arah. Induk meneruskan batas ukuran (*constraints*) ke anak, anak menentukan ukurannya di dalam batas itu, lalu induk menempatkan anak sesuai aturan tata letaknya. Contohnya, `Row` dengan `spaceEvenly` mengatur jarak tiga `InfoCard`, sedangkan `GridView.count` di dalam `Column` membutuhkan `shrinkWrap: true` karena `Column` tidak memberi batas tinggi. Induk juga menyediakan data bagi keturunannya, misalnya tema dari `MaterialApp` yang dibaca `ItemCard` lewat `Theme.of(context)`. Ketika induk dibangun ulang, anak-anaknya ikut dibangun ulang, kecuali widget `const` yang dapat dipakai kembali.

2. Widget yang digunakan beserta fungsinya:
   - `MaterialApp`: root aplikasi yang menyediakan tema Material, judul aplikasi, dan halaman awal (`home`).
   - `Scaffold`: kerangka halaman Material yang menyediakan slot `appBar`, `body`, dan tempat menampilkan `SnackBar`.
   - `AppBar`: bar judul di bagian atas halaman.
   - `Text`: menampilkan teks seperti judul, label kartu, dan isi `SnackBar`.
   - `Padding`: memberi jarak di sekeliling isi halaman dan di antara ikon serta label tombol.
   - `Column`: menyusun widget secara vertikal, baik pada isi halaman maupun isi kartu.
   - `Row`: menyusun tiga `InfoCard` secara horizontal.
   - `IntrinsicHeight`: menyamakan tinggi anak-anak `Row` dengan anak tertinggi agar kartu identitas rata.
   - `Center`: menempatkan pesan sambutan, kisi tombol, dan isi tombol di tengah.
   - `SizedBox`: memberi jarak tetap antarbagian.
   - `Card`: wadah dengan bayangan (*elevation*) untuk kartu identitas.
   - `Container`: mengatur lebar dan padding kartu identitas serta padding isi tombol.
   - `GridView.count`: menampilkan tombol menu dalam kisi tiga kolom.
   - `Material`: memberi warna latar dan sudut membulat pada tombol, sekaligus menjadi permukaan untuk efek ripple.
   - `InkWell`: menangkap ketukan pada tombol dan menampilkan efek ripple.
   - `Icon`: menampilkan ikon setiap tombol.
   - `SnackBar`: pesan singkat di bagian bawah layar setelah tombol ditekan, ditampilkan melalui `ScaffoldMessenger`.
   - `MyHomePage`, `InfoCard`, dan `ItemCard`: widget buatan sendiri untuk halaman menu, kartu identitas, dan kartu tombol.

3. `MaterialApp` membungkus aplikasi dengan konfigurasi yang dibutuhkan komponen Material Design: tema (`ThemeData` dan `ColorScheme`), navigasi antarhalaman melalui `Navigator`, judul aplikasi, lokalisasi, serta akses ke ukuran layar melalui `MediaQuery`. Widget ini umumnya dijadikan root karena widget Material lain mencari konfigurasi tersebut dari leluhurnya di widget tree. Contohnya, `Theme.of(context)` pada `AppBar` dan `MediaQuery.of(context)` pada `InfoCard` hanya bekerja jika ada `MaterialApp` di atasnya. Dengan meletakkannya di root, seluruh halaman memperoleh tema dan perilaku yang konsisten.

4. `StatelessWidget` tidak memiliki state internal yang berubah. Tampilannya hanya bergantung pada parameter konstruktor dan data dari leluhurnya, sehingga dibangun ulang hanya jika induknya berubah. `StatefulWidget` dipasangkan dengan objek `State` yang menyimpan data yang dapat berubah selama widget hidup. Pemanggilan `setState()` memberi tahu Flutter untuk menjalankan ulang `build()`. Pilih `StatelessWidget` untuk tampilan yang ditentukan sepenuhnya oleh input, seperti `InfoCard`, `ItemCard`, dan halaman menu ini. Pilih `StatefulWidget` ketika widget harus mengingat dan memperbarui data sendiri, misalnya penghitung pada aplikasi bawaan `flutter create`, isian form, checkbox, animasi, atau data yang dimuat dari API.

5. `BuildContext` adalah penanda posisi sebuah widget di dalam widget tree. Setiap metode `build` menerima `context` miliknya sendiri, dan context ini dipakai untuk mencari widget atau data dari leluhurnya. Di proyek ini, `Theme.of(context)` membaca warna tema untuk `AppBar`, `MediaQuery.of(context)` membaca lebar layar untuk menghitung lebar `InfoCard`, dan `ScaffoldMessenger.of(context)` menemukan `Scaffold` terdekat untuk menampilkan `SnackBar` saat `ItemCard` ditekan. Context penting karena hasil pencarian bergantung pada posisinya. Context dari widget yang berada di atas `Scaffold` tidak dapat menemukan `Scaffold` tersebut.

6. **Hot reload** menyuntikkan kode yang berubah ke Dart VM yang sedang berjalan, lalu membangun ulang widget tree tanpa menghapus state. Perubahan tampilan terlihat dalam hitungan detik dan, misalnya, nilai penghitung tidak kembali ke nol. **Hot restart** memuat ulang seluruh kode Dart dan menjalankan aplikasi dari awal dengan memanggil `main()` lagi, sehingga semua state hilang, tetapi tetap lebih cepat daripada kompilasi ulang penuh. Hot reload tidak cukup ketika perubahan menyentuh kode yang hanya dijalankan sekali atau struktur yang sudah tertanam di state, misalnya isi `main()` atau `initState()`, nilai awal variabel global dan `static`, perubahan widget dari `StatelessWidget` menjadi `StatefulWidget`, perubahan enum atau tipe generik, serta kesalahan kompilasi yang membuat reload gagal. Untuk kasus tersebut gunakan hot restart. *Full restart* (menghentikan lalu menjalankan ulang `flutter run`) diperlukan setelah mengubah kode native Android/iOS, menambah dependency atau aset di `pubspec.yaml`, atau mengganti konfigurasi platform.

### AI Disclosure
Dalam pengerjaan project ini, saya menggunakan bantuan AI secara terbatas, yaitu untuk membantu merapikan format penulisan pada file README.md agar lebih terstruktur dan mudah dibaca, serta untuk mencari referensi dan tutorial dalam mengembangkan desain web yang saya buat. Seluruh proses pengembangan, logika, dan implementasi tetap saya kerjakan dan pahami sendiri.
