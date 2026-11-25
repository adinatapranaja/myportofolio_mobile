# MyPortfolio Mobile

Aplikasi mobile portofolio pribadi milik **Adinata Alaudin Pranaja** untuk mata kuliah Pemrograman Berbasis Platform (PBP), kelas C. Aplikasi ini dibangun dengan Flutter dan nantinya akan menjadi klien bagi REST API Django dari proyek web [myportofolio](https://github.com/adinatapranaja/myportofolio).

- NPM: 2506656356
- Program studi: S1 Sistem Informasi, Universitas Indonesia

## Menjalankan proyek secara lokal

Prasyarat: Flutter SDK (channel stable) dan Google Chrome. Proyek ini dikembangkan dengan Flutter 3.38 dan diperbarui ke Flutter 3.50 sejak Tutorial 9, sehingga widget Material diimpor dari paket `material_ui`.

```bash
# Periksa kelengkapan toolchain
flutter doctor

# Ambil dependency
flutter pub get

# Hasilkan kode serialisasi JSON (*.g.dart tidak disimpan di Git)
dart run build_runner build --delete-conflicting-outputs

# Jalankan di Google Chrome terhadap Django lokal
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Aplikasi membaca alamat backend dari `--dart-define=API_BASE_URL`. Tanpa nilai tersebut, aplikasi memakai `http://10.0.2.2:8000`, yaitu alamat komputer pengembang jika dilihat dari emulator Android. Jalankan backend Django ([myportofolio](https://github.com/adinatapranaja/myportofolio)) dengan `python manage.py runserver` sebelum membuka aplikasi.

| Target | Perintah |
| --- | --- |
| Chrome + Django lokal | `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000` |
| Emulator Android + Django lokal | `flutter run` |
| Perangkat Android fisik (USB) | `adb reverse tcp:8000 tcp:8000`, lalu `flutter run --dart-define=API_BASE_URL=http://localhost:8000` |
| Backend yang sudah di-deploy | `flutter run --dart-define=API_BASE_URL=https://<domain-django>` |

Untuk menjalankan di emulator Android atau perangkat fisik, pastikan Android toolchain pada `flutter doctor` sudah bertanda centang.

## Pemeriksaan cepat

Jalankan pemeriksaan yang sama dengan CI sebelum commit:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Test memakai `MockClient` dari paket `http`, sehingga tidak membutuhkan server Django yang sedang berjalan.

## Struktur proyek

```text
myportofolio_mobile/
├── lib/
│   ├── main.dart                    # Entry point: MultiProvider, MaterialApp, dan tema warna
│   ├── config.dart                  # API_BASE_URL dari --dart-define
│   ├── models/
│   │   └── project.dart             # Model Project (@JsonSerializable)
│   ├── services/
│   │   ├── api_client.dart          # ApiClient dan ApiException untuk API DRF
│   │   └── auth_state.dart          # AuthState: token login di memori
│   ├── screens/
│   │   ├── menu.dart                # Halaman utama, InfoCard, dan ItemHomepage
│   │   ├── experience_form.dart     # Halaman formulir tambah pengalaman (Tugas 8)
│   │   ├── login_screen.dart        # Halaman login token
│   │   ├── project_detail_screen.dart # Detail satu proyek
│   │   ├── project_form.dart        # Formulir tambah proyek (POST ke API)
│   │   └── project_list_screen.dart # Daftar proyek dari API
│   └── widgets/
│       ├── auth_guard.dart          # ensureLoggedIn(): meminta login sebelum aksi terlindungi
│       ├── left_drawer.dart         # Drawer navigasi, Login, dan Logout
│       └── project_card.dart        # ItemCard: tombol menu, SnackBar, dan navigasi
├── test/
│   ├── helpers/fake_api.dart        # ApiClient palsu berbasis MockClient
│   ├── widget_test.dart             # Halaman utama, kartu, drawer, guard, dan navigasi
│   ├── api_client_test.dart         # Request dan parsing ApiClient
│   ├── project_list_screen_test.dart # Daftar, detail, kosong, dan error
│   ├── project_form_test.dart       # Validasi, POST bertoken, 401, dan 403
│   ├── login_screen_test.dart       # Validasi dan kegagalan login
│   └── experience_form_test.dart    # Validasi dan dialog formulir pengalaman
├── .github/workflows/main.yaml      # GitHub Actions: CI dan build APK
├── pubspec.yaml                     # Manifes proyek dan dependency
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

### Tutorial 9 — Flutter Navigation, Layouts, Forms, and Input Elements

Tutorial 9 menambahkan perpindahan antarhalaman, formulir dengan validasi, dan struktur folder yang lebih rapi.

1. **Migrasi `material_ui`.** Mulai Flutter 3.50, pustaka Material dipindahkan ke paket terpisah. Paket ditambahkan dengan `flutter pub add material_ui`, lalu setiap `import 'package:flutter/material.dart';` diganti `import 'package:material_ui/material_ui.dart';` sehingga `flutter analyze` tidak lagi menampilkan peringatan *deprecated*.
2. **Navigator.** Flutter menyimpan halaman (*route*) sebagai tumpukan. `push()` menaruh halaman baru di atas tumpukan, `pop()` membuang halaman teratas, dan `pushReplacement()` mengganti halaman teratas tanpa menyisakan halaman lama di bawahnya.
3. **Drawer.** `LeftDrawer` di `widgets/left_drawer.dart` berisi `DrawerHeader` serta menu **Home** dan **Add Project**. Keduanya memakai `pushReplacement()` agar berpindah lewat drawer tidak menumpuk halaman. Drawer dipasang melalui properti `drawer` pada `Scaffold` halaman utama dan halaman form.
4. **Formulir.** `ProjectFormPage` adalah `StatefulWidget` karena menyimpan isian pengguna. `Form` memakai `GlobalKey<FormState>` untuk menjalankan validasi dan mengatur ulang isian. Field yang tersedia adalah nama proyek, deskripsi, kategori (`DropdownButtonFormField` dengan `initialValue`), teknologi, dan tautan. Nama dan deskripsi wajib diisi melalui `validator`, sedangkan `onChanged` menyimpan nilai ke state dengan `setState()`.
5. **Menampilkan data.** Tombol **Save** menjalankan `validate()`. Jika lolos, `showDialog()` menampilkan `AlertDialog` berisi seluruh isian. Tombol **OK** menutup dialog dengan `Navigator.pop()` lalu mengosongkan formulir dengan `reset()`.
6. **Navigasi dari tombol menu.** Setelah menampilkan `SnackBar`, `ItemCard` membuka halaman form dengan `Navigator.push()`, sehingga tombol Back sistem atau browser mengembalikan pengguna ke halaman menu.
7. **Refactoring.** Halaman dipindahkan ke `lib/screens/`, sedangkan widget yang dipakai ulang dipindahkan ke `lib/widgets/`. `ItemCard` dipisahkan dari `menu.dart` ke `widgets/project_card.dart`, lalu seluruh import disesuaikan.

Beberapa penyesuaian dari contoh tutorial:

- Navigasi ke form dipicu oleh tombol **Tambah Experience**, karena tombol menu sudah disesuaikan dengan bagian Experience pada Tugas 7. Untuk sementara tombol ini membuka formulir proyek dari tutorial; formulir Experience dibuat pada Tugas 8.
- Judul `DrawerHeader` dibungkus `FittedBox` dan subjudulnya dibungkus `Flexible`. Tinggi `DrawerHeader` tetap, sehingga tanpa penyesuaian ini isi header meluap (*overflow*) ketika teks dirender lebih besar.
- Halaman form tidak menampilkan tombol kembali di `AppBar` karena posisi tersebut dipakai ikon drawer. Pengguna kembali melalui tombol Back sistem atau browser, sesuai alur tutorial.
- Widget test ditambah untuk memeriksa drawer, perbedaan `push()` dan `pushReplacement()` melalui `Navigator.canPop()`, validasi formulir, serta isi dialog. Tidak ada komentar `TODO` yang tersisa.

Sumber: [Tutorial 9 PBP](https://pbp.cs.ui.ac.id/tutorial/tutorial-9.html).

### Tutorial 10 — Flutter Backend Integration, Authentication, and CI/CD

Tutorial 10 menghubungkan aplikasi dengan REST API Django dari Tutorial 7, menambahkan login berbasis token, dan menyiapkan CI/CD.

**Backend Django.** Repositori `myportofolio` mengaktifkan `rest_framework.authtoken` dan `django-cors-headers`. `TokenAuthentication` diletakkan sebelum `SessionAuthentication`, sehingga permintaan tanpa token dijawab `401`, sedangkan halaman web tetap memakai session dan CSRF. Endpoint `POST /api/v1/auth/token/` menukar username dan password menjadi token, dan `POST /api/v1/auth/logout/` mencabut token tersebut (`204`). CORS diizinkan untuk semua origin saat pengembangan lokal agar Flutter Web dapat memanggil API.

**Model dan ApiClient.**

1. Paket `http`, `provider`, dan `json_annotation` ditambahkan, bersama `build_runner` dan `json_serializable` untuk menghasilkan kode. Berkas `*.g.dart` dikecualikan dari Git dan dari `flutter analyze`.
2. Android mendapat izin `INTERNET` dan `usesCleartextTraffic` untuk HTTP lokal selama pengembangan.
3. Model `Project` memakai `@JsonSerializable(fieldRename: FieldRename.snake)`, sehingga `repositoryUrl` di Dart menjadi `repository_url` di JSON. `id` tidak dikirim saat POST karena UUID dibuat oleh Django.
4. `ApiClient` di `lib/services/` memisahkan pemanggilan jaringan dari tampilan. Respons non-2xx dilempar sebagai `ApiException` berisi status code. Nama header ditulis sebagai string biasa, bukan `HttpHeaders` dari `dart:io`, agar tetap berjalan di Flutter Web.

**Daftar dan detail proyek.** `ProjectListScreen` membuat `Future` di `initState()` agar permintaan HTTP tidak dikirim ulang setiap kali widget dibangun ulang. `FutureBuilder` menangani keadaan memuat, gagal (dengan tombol **Retry**), kosong, dan berisi data, sedangkan `RefreshIndicator` memuat ulang daftar dengan gestur tarik. Halaman ini dapat dibuka tanpa login melalui opsi **Projects** di drawer, dan setiap kartu membuka `ProjectDetailScreen`.

**Autentikasi dan route guard.** `AuthState` (`ChangeNotifier`) menyimpan token di memori dan disediakan ke seluruh aplikasi bersama `ApiClient` melalui `MultiProvider`. `ensureLoggedIn()` membuka `LoginScreen` ketika pengguna belum login dan melanjutkan ke halaman tujuan setelah login berhasil. Guard ini melindungi kartu dan opsi drawer **Tambah/Add Project** serta **Tambah/Add Experience**. Drawer memakai `context.watch<AuthState>()` agar opsi **Login** dan **Logout** berganti secara otomatis, dan kartu **Logout** kini mencabut token.

**Formulir proyek.** Field disesuaikan dengan `ProjectSerializer`: Title, Description, Technologies, serta Project URL dan Repository URL yang opsional dan divalidasi sebagai tautan `http`/`https`. Tombol **Save** mengirim `POST /api/v1/projects/` dengan header `Authorization: Token <key>`. Respons `201` ditampilkan dalam dialog. Respons `401` menghapus token dan meminta login ulang, `403` menampilkan pesan bahwa hanya pemilik yang dapat menambah proyek, dan kesalahan lain ditampilkan melalui `SnackBar`.

**CI/CD.** `.github/workflows/main.yaml` menjalankan job `build` dari `very_good_workflows` (`build_runner`, `dart format`, `flutter analyze`, dan test dengan coverage). Setelah `build` lulus, job `build_apk` membangun APK rilis dengan `--dart-define=API_BASE_URL=${{ vars.API_BASE_URL }}` lalu mengunggah `app-release.apk` sebagai artefak `app-release-apk`. Nilai `API_BASE_URL` disimpan sebagai *repository variable* di **Settings → Secrets and variables → Actions → Variables**.

Beberapa penyesuaian dari contoh tutorial:

- Model `Project` mengikuti serializer Django proyek ini, yaitu `technologies` dan `repository_url`, bukan `tech_stack` dan `project_image_url`. Karena model tidak memiliki URL gambar, halaman detail menampilkan Project URL dan Repository URL jika tidak kosong.
- Decorator `@authentication_classes([SessionAuthentication])` dihapus dari semua view API, termasuk Experience, agar pengaturan autentikasi global berlaku. Test Django disesuaikan karena tamu kini menerima `401`, sedangkan pengguna login tanpa hak akses tetap menerima `403`.
- Versi Flutter pada GitHub Actions dikunci ke 3.50.0, sama dengan versi lokal, karena proyek bergantung pada paket `material_ui`.
- Widget test tidak dihapus. Test lama disesuaikan dengan `MyApp(apiClient: ...)`, dan test baru memakai `MockClient` untuk `ApiClient`, daftar dan detail proyek, login, guard, logout, serta POST bertoken dengan respons `201`, `401`, dan `403`.

Sumber: [Tutorial 10 PBP](https://pbp.cs.ui.ac.id/tutorial/tutorial-10.html).

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

### Tugas 8

Implementasi Tugas 8 menambahkan formulir **Tambah Experience** yang mengikuti model `Experience` pada proyek Django:

- `lib/screens/experience_form.dart` berisi `ExperienceFormPage` (`StatefulWidget`) dengan `Form` dan `GlobalKey<FormState>`. Inputnya adalah role atau posisi, deskripsi, kategori (enam pilihan yang sama dengan `EXPERIENCE_CHOICES`), URL gambar opsional, tanggal mulai, saklar **Masih berlangsung**, dan tanggal selesai. Tanggal dipilih dengan `showDatePicker()`.
- Validasi mengikuti aturan model: role dan deskripsi tidak boleh kosong atau hanya spasi, role maksimal 255 karakter, URL gambar harus berupa tautan `http`/`https` jika diisi, tanggal mulai wajib, dan tanggal selesai wajib kecuali pengalaman masih berlangsung serta tidak boleh sebelum tanggal mulai.
- Tombol **Simpan** memanggil `validate()`. Jika lolos, `AlertDialog` menampilkan seluruh isian, lalu tombol **OK** menutup dialog dan mengosongkan formulir.
- Halaman utama memiliki empat kartu dalam kisi dua kolom. **Tambah Experience** dan **Tambah Proyek** membuka formulirnya dengan `Navigator.push()`. Halaman tujuan disimpan sebagai atribut `destination` pada `ItemHomepage`, sehingga `ItemCard` tidak lagi mencocokkan nama tombol.
- Drawer mendapat opsi **Add Experience** di samping **Home** dan **Add Project**, dan drawer yang sama dipakai pada halaman formulir.
- Widget test mencakup pembukaan formulir dari kartu dan drawer, kembali dengan tombol Back maupun opsi **Home**, input kosong, URL dan urutan tanggal yang salah, isi dialog, serta tombol **Simpan** yang tetap terjangkau pada layar 360 × 480 saat papan ketik tampil.

1. `Navigator.push()` menaruh halaman baru di atas tumpukan *route* sehingga halaman sebelumnya tetap tersimpan di bawahnya. `Navigator.pushReplacement()` mengganti halaman teratas dengan halaman baru, sehingga halaman lama dibuang dari tumpukan. `Navigator.pop()` membuang halaman teratas dan menampilkan kembali halaman di bawahnya. Kartu aksi **Tambah Experience** memakai `Navigator.push()`, sehingga tombol kembali bawaan perangkat atau tombol Back browser memanggil `pop()` dan mengembalikan pengguna ke menu. Opsi **Home** di drawer memakai `Navigator.pushReplacement()` dengan `MyHomePage`. Halaman formulir yang sedang tampil diganti oleh halaman utama baru, sehingga pengguna kembali ke menu tanpa menumpuk halaman. Akibatnya, setelah membuka formulir melalui drawer tidak ada lagi halaman di bawahnya, yang dibuktikan oleh widget test melalui `Navigator.canPop()` bernilai `false`.

2. Setiap halaman memakai `Scaffold` sebagai kerangka yang sama: `AppBar` di bagian atas, `drawer` di sisi kiri, dan `body` untuk isi halaman. Karena halaman utama, formulir proyek, dan formulir pengalaman memakai widget `LeftDrawer` yang sama, menu navigasi selalu identik dan cukup diubah di satu berkas. `AppBar` juga menyediakan posisi judul serta ikon drawer yang konsisten. Contoh warna tema: `ColorScheme.fromSeed(seedColor: Colors.indigo)` pada `MaterialApp` dibaca melalui `Theme.of(context).colorScheme.primary` sebagai warna `AppBar` di halaman utama, serta sebagai warna `AppBar` dan tombol **Simpan** di halaman formulir pengalaman. Mengganti warna dasar tema akan mengubah ketiganya sekaligus.

3. Formulir disusun sebagai satu kolom vertikal karena setiap input membutuhkan lebar penuh agar label, isi, dan pesan kesalahan mudah dibaca di layar ponsel, serta urutan pengisian berjalan dari atas ke bawah. `Padding` memberi jarak 8 piksel di sekitar setiap input dan di tepi layar agar elemen tidak saling menempel dan mudah disentuh. `SingleChildScrollView` membungkus `Column` sehingga isi formulir dapat digulir ketika tingginya melebihi layar, misalnya pada ponsel kecil atau ketika papan ketik muncul dan mengurangi ruang yang tersedia. Tanpa penggulir, `Column` akan mengalami *overflow* dan tombol **Simpan** bisa tertutup. Halaman utama juga dibungkus `SingleChildScrollView` agar kartu baris kedua tetap terjangkau.

4. `GlobalKey<FormState>` memberi akses ke state widget `Form` dari luar pohon input, misalnya dari tombol **Simpan**. Setiap `TextFormField` memiliki `validator` yang menerima nilai input dan mengembalikan pesan kesalahan atau `null` jika valid. Saat **Simpan** ditekan, `_formKey.currentState!.validate()` menjalankan semua validator sekaligus, menampilkan pesan pada kolom yang tidak valid, dan mengembalikan `true` hanya jika semua kolom lolos. Dialog ringkasan hanya ditampilkan ketika nilai tersebut `true`. Contoh nilai yang ditolak adalah `javascript:alert(1)` pada kolom URL gambar. Kolom ini memakai `TextInputType.url`, tetapi jenis papan ketik hanya mengubah tombol yang ditampilkan dan tetap mengizinkan teks apa pun, termasuk hasil tempel. Validator memeriksa bahwa skema tautan adalah `http` atau `https` dan memiliki host, sehingga nilai tersebut ditolak. Contoh lain adalah tanggal selesai yang lebih awal dari tanggal mulai. `showDatePicker()` menjamin format tanggal benar, tetapi tidak mengetahui hubungan antara dua tanggal, sehingga urutannya tetap perlu diperiksa oleh validator.

### AI Disclosure
Dalam pengerjaan project ini, saya menggunakan bantuan AI secara terbatas, yaitu untuk membantu merapikan format penulisan pada file README.md agar lebih terstruktur dan mudah dibaca, serta untuk mencari referensi dan tutorial dalam mengembangkan desain web yang saya buat. Seluruh proses pengembangan, logika, dan implementasi tetap saya kerjakan dan pahami sendiri.
