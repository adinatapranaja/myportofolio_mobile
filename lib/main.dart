import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.apiClient, this.initialToken, super.key});

  /// Injected from outside so tests can pass a client backed by `MockClient`.
  final ApiClient apiClient;

  /// Token to start with; `null` (the default) means the user is logged out.
  final String? initialToken;

  @override
  Widget build(BuildContext context) {
    // MultiProvider makes shared objects available to every widget below it.
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => AuthState(apiClient, initialToken: initialToken),
        ),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            secondary: Colors.amber[700],
          ),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
