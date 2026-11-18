import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

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
      await tester.pump();
      expect(
        find.text('Kamu telah menekan tombol ${item.name}!'),
        findsOneWidget,
      );
    }
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
