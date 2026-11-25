import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_api.dart';

Widget wrap(ApiClient client) => Provider.value(
  value: client,
  child: const MaterialApp(home: ProjectListScreen()),
);

void main() {
  testWidgets('Shows a loader, then projects, and opens the detail page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(fakeApiClient((_) async => jsonResponse([projectJson]))),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Secure Event Attendance Platform'), findsOneWidget);
    expect(find.text('React.js, Firebase'), findsOneWidget);

    await tester.tap(find.text('Secure Event Attendance Platform'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Project URL'), findsOneWidget);
    expect(find.text('https://example.com/event'), findsOneWidget);
    // An empty repository_url is not shown.
    expect(find.text('Repository URL'), findsNothing);
  });

  testWidgets('Shows an empty message when the API returns no projects', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(fakeApiClient()));
    await tester.pumpAndSettle();
    expect(find.text('No projects found.'), findsOneWidget);
  });

  testWidgets('Shows an error with Retry, and Retry loads the data', (
    WidgetTester tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      wrap(
        fakeApiClient((_) async {
          calls++;
          return calls == 1
              ? http.Response('Server error', 500)
              : jsonResponse([projectJson]);
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Failed to load projects'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Secure Event Attendance Platform'), findsOneWidget);
  });
}
