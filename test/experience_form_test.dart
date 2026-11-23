import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/screens/experience_form.dart';

Future<void> pumpForm(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

/// Membuka date picker dari field [label] lalu memilih hari [day] pada bulan
/// yang sedang ditampilkan.
Future<void> pickDay(WidgetTester tester, String label, int day) async {
  await tester.ensureVisible(field(label));
  await tester.tap(field(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text('$day').last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Empty required fields show errors and no dialog', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);
    await tester.enterText(field('Role atau Posisi'), '   ');
    await tapSave(tester);

    expect(find.text('Role atau posisi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
    expect(
      find.text("Pilih tanggal selesai atau aktifkan 'Masih berlangsung'."),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Invalid URL and reversed dates are rejected', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);
    await tester.enterText(field('Role atau Posisi'), 'Backend Intern');
    await tester.enterText(field('Deskripsi'), 'Membangun API');
    await tester.enterText(
      field('URL Gambar (opsional)'),
      'javascript:alert(1)',
    );
    await pickDay(tester, 'Tanggal Mulai', 20);
    await pickDay(tester, 'Tanggal Selesai', 10);
    await tapSave(tester);

    expect(
      find.text('URL harus diawali http:// atau https://'),
      findsOneWidget,
    );
    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Valid input shows every value in the summary dialog', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);
    await tester.enterText(field('Role atau Posisi'), 'Backend Intern');
    await tester.enterText(field('Deskripsi'), 'Membangun API');
    await tester.tap(find.text('Full-Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Internship').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      field('URL Gambar (opsional)'),
      'https://example.com/logo.png',
    );
    await pickDay(tester, 'Tanggal Mulai', 10);
    await tester.ensureVisible(find.text('Masih berlangsung'));
    await tester.tap(find.text('Masih berlangsung'));
    await tester.pumpAndSettle();
    await tapSave(tester);

    expect(find.text('Pengalaman berhasil disimpan!'), findsOneWidget);
    final dialog = find.byType(AlertDialog);
    for (final line in [
      'Role/Posisi: Backend Intern',
      'Deskripsi: Membangun API',
      'Kategori: Internship',
      'URL Gambar: https://example.com/logo.png',
      'Selesai: Sedang berlangsung',
    ]) {
      expect(
        find.descendant(of: dialog, matching: find.text(line)),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(
        of: dialog,
        matching: find.textContaining(RegExp(r'^Mulai: 10/\d{2}/\d{4}$')),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Backend Intern'), findsNothing);
  });

  testWidgets('Save button stays reachable on a narrow phone with keyboard', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    addTearDown(tester.view.reset);

    await pumpForm(tester);
    await tapSave(tester);

    expect(find.text('Role atau posisi tidak boleh kosong!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
