import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_api.dart';

Widget wrap(ApiClient client) => MultiProvider(
  providers: [
    Provider.value(value: client),
    ChangeNotifierProvider(create: (_) => AuthState(client)),
  ],
  child: const MaterialApp(home: LoginScreen()),
);

void main() {
  testWidgets('Empty credentials show validation errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(fakeApiClient()));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Username cannot be empty!'), findsOneWidget);
    expect(find.text('Password cannot be empty!'), findsOneWidget);
  });

  testWidgets('Wrong credentials keep the user on Login with a message', (
    WidgetTester tester,
  ) async {
    final client = fakeApiClient(
      (_) async => jsonResponse({
        'non_field_errors': ['Unable to log in.'],
      }, 400),
    );
    await tester.pumpWidget(wrap(client));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrong',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Username atau password salah.'), findsOneWidget);
    final context = tester.element(find.byType(LoginScreen));
    expect(Provider.of<AuthState>(context, listen: false).isLoggedIn, false);
  });
}
