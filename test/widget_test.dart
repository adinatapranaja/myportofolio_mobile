import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

void main() {
  testWidgets('Home page shows owner info and menu buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    for (final label in ['NPM', 'Name', 'Class']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final value in ['2506656356', 'Adinata Alaudin Pranaja', 'PBP C']) {
      expect(find.text(value), findsOneWidget);
    }
    expect(find.byType(ItemCard), findsNWidgets(3));
    for (final name in ['Lihat Experience', 'Tambah Experience', 'Logout']) {
      expect(find.text(name), findsOneWidget);
    }
  });

  testWidgets('Each menu button has its own background color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final colors = [
      for (final item in MyHomePage.items)
        tester
            .widget<Material>(
              find
                  .ancestor(
                    of: find.text(item.name),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .color,
    ];
    expect(colors, MyHomePage.items.map((item) => item.color).toList());
    expect(colors.toSet().length, MyHomePage.items.length);
  });

  testWidgets('Tapping each menu button shows a matching SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    for (final item in MyHomePage.items) {
      await tester.tap(find.text(item.name));
      await tester.pumpAndSettle();
      expect(
        find.text('Kamu telah menekan tombol ${item.name}!'),
        findsOneWidget,
      );
      // Tombol tambah berpindah ke halaman form; kembali ke menu dulu.
      if (find.byType(ProjectFormPage).evaluate().isNotEmpty) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('Add button pushes the form and Back returns to the menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);
    // push() menumpuk form di atas menu, jadi masih ada halaman di bawahnya.
    expect(tester.state<NavigatorState>(find.byType(Navigator)).canPop(), true);

    // Menyimulasikan tombol Back sistem/browser.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer Add Project replaces the page with the form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);
    // pushReplacement() mengganti menu, jadi tidak ada halaman di bawahnya.
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      false,
    );
    expect(find.byTooltip('Open navigation menu'), findsOneWidget);
  });

  testWidgets('Form validates input and shows the entered data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Proyek'),
      'Portfolio App',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
      'Aplikasi portofolio',
    );
    await tester.tap(find.text('Web Development'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile Development').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Teknologi yang Digunakan'),
      'Flutter',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tautan Proyek'),
      'https://example.com',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    for (final line in [
      'Nama Proyek: Portfolio App',
      'Deskripsi: Aplikasi portofolio',
      'Kategori: Mobile Development',
      'Teknologi: Flutter',
      'Tautan: https://example.com',
    ]) {
      expect(find.text(line), findsOneWidget);
    }

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Drawer opens and Home returns to the menu page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('My Portfolio'), findsOneWidget);
    expect(
      find.text('Explore personal projects and experiences!'),
      findsOneWidget,
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('My Portfolio'), findsNothing);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });
}
