import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_api.dart';

Widget wrap(ApiClient client, {String? token}) => MultiProvider(
  providers: [
    Provider.value(value: client),
    ChangeNotifierProvider(
      create: (_) => AuthState(client, initialToken: token),
    ),
  ],
  child: const MaterialApp(home: ProjectFormPage()),
);

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Title'), 'Portfolio App');
  await tester.enterText(field('Description'), 'Aplikasi portofolio');
  await tester.enterText(field('Technologies'), 'Flutter');
  await tester.enterText(
    field('Repository URL (Optional)'),
    'https://github.com/adinatapranaja/myportofolio_mobile',
  );
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Invalid input is rejected before any request is sent', (
    WidgetTester tester,
  ) async {
    var requests = 0;
    await tester.pumpWidget(
      wrap(
        fakeApiClient((_) async {
          requests++;
          return http.Response('', 500);
        }),
        token: 'test-token',
      ),
    );

    await tester.enterText(field('Title'), '   ');
    await tester.enterText(
      field('Project URL (Optional)'),
      'javascript:alert(1)',
    );
    await tapSave(tester);

    expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Description tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Technologies tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('URL harus diawali http:// atau https://'),
      findsOneWidget,
    );
    expect(requests, 0);
  });

  testWidgets(
    'Valid input is posted with the token and confirmed in a dialog',
    (WidgetTester tester) async {
      late http.Request sent;
      await tester.pumpWidget(
        wrap(
          fakeApiClient((request) async {
            sent = request;
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            return jsonResponse({...body, 'id': 'new-uuid'}, 201);
          }),
          token: 'test-token',
        ),
      );

      await fillValidForm(tester);
      await tapSave(tester);

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/projects/');
      expect(sent.headers['Authorization'], 'Token test-token');
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Proyek: Portfolio App'), findsOneWidget);
      expect(find.text('Project URL: -'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('Saving while logged out asks for login first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(fakeApiClient()));

    await fillValidForm(tester);
    await tapSave(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('A 401 response logs out and asks for login again', (
    WidgetTester tester,
  ) async {
    final client = fakeApiClient((request) async {
      return request.url.path == '/api/v1/auth/logout/'
          ? http.Response('', 401)
          : jsonResponse({'detail': 'Invalid token.'}, 401);
    });
    await tester.pumpWidget(wrap(client, token: 'expired-token'));

    await fillValidForm(tester);
    await tapSave(tester);

    // The form is now covered by LoginScreen, so include offstage widgets.
    final context = tester.element(
      find.byType(ProjectFormPage, skipOffstage: false),
    );
    expect(Provider.of<AuthState>(context, listen: false).isLoggedIn, false);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('A 403 response shows a permission message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        fakeApiClient((_) async => jsonResponse({'detail': 'Forbidden'}, 403)),
        token: 'visitor-token',
      ),
    );

    await fillValidForm(tester);
    await tapSave(tester);

    expect(
      find.text('Hanya pemilik portofolio yang dapat menambah proyek.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });
}
