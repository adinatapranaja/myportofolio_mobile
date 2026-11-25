import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

import 'helpers/fake_api.dart';

void main() {
  testWidgets('Home page shows owner info and menu buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    for (final label in ['NPM', 'Name', 'Class']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final value in ['2506656356', 'Adinata Alaudin Pranaja', 'PBP C']) {
      expect(find.text(value), findsOneWidget);
    }
    expect(find.byType(ItemCard), findsNWidgets(4));
    for (final name in [
      'Lihat Experience',
      'Tambah Experience',
      'Tambah Proyek',
      'Logout',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
  });

  testWidgets('Each menu button has its own background color', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

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
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    for (final item in MyHomePage.items) {
      await tester.ensureVisible(find.text(item.name));
      await tester.tap(find.text(item.name));
      await tester.pumpAndSettle();
      expect(
        find.text('Kamu telah menekan tombol ${item.name}!'),
        findsOneWidget,
      );
      // Tombol tambah berpindah ke halaman form; kembali ke menu dulu.
      if (item.destination != null) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
    }
  });

  for (final (button, title) in [
    ('Tambah Experience', 'Add Experience Form'),
    ('Tambah Proyek', 'Add Project Form'),
  ]) {
    testWidgets('$button card pushes its form and Back returns to the menu', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MyApp(apiClient: fakeApiClient(), initialToken: 'test-token'),
      );

      await tester.ensureVisible(find.text(button));
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
      // push() menumpuk form di atas menu, jadi masih ada halaman di bawahnya.
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        true,
      );

      // Menyimulasikan tombol Back sistem/browser.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
    });
  }

  testWidgets('Drawer Add Experience opens the form and Home returns', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(apiClient: fakeApiClient(), initialToken: 'test-token'),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();

    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      false,
    );

    // Drawer yang sama tersedia di halaman form, dan Home kembali ke menu.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer Add Project replaces the page with the form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(apiClient: fakeApiClient(), initialToken: 'test-token'),
    );

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

  testWidgets('Drawer opens and Home returns to the menu page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

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

  testWidgets('Guarded card opens Login first, then the form after login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        apiClient: fakeApiClient(
          (_) async => jsonResponse({'token': 'fresh-token'}),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'pw',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Closing Login without logging in stays on the menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    await tester.tap(find.text('Tambah Experience'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceFormPage), findsNothing);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer switches between Login and Logout', (
    WidgetTester tester,
  ) async {
    final requests = <String>[];
    await tester.pumpWidget(
      MyApp(
        apiClient: fakeApiClient((request) async {
          requests.add('${request.method} ${request.url.path}');
          return http.Response('', 204);
        }),
        initialToken: 'test-token',
      ),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Login'), findsNothing);

    await tester.tap(find.widgetWithText(ListTile, 'Logout'));
    await tester.pumpAndSettle();
    expect(requests, ['POST /api/v1/auth/logout/']);
    expect(find.text('Kamu berhasil logout.'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);
  });

  testWidgets('Logout card revokes the token when logged in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        apiClient: fakeApiClient((_) async => http.Response('', 204)),
        initialToken: 'test-token',
      ),
    );

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu berhasil logout.'), findsOneWidget);

    // Sudah logout: kartu tambah kembali meminta login.
    await tester.tap(find.text('Tambah Experience'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
