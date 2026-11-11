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
    expect(find.byType(ItemCard), findsNWidgets(3));
    for (final item in MyHomePage.items) {
      expect(find.text(item.name), findsOneWidget);
    }
  });

  testWidgets('Tapping a menu button shows a SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();
    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );

    await tester.tap(find.text('Logout'));
    await tester.pump();
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
  });
}
