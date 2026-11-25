import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'helpers/fake_api.dart';

void main() {
  test('getProjects parses the DRF list response', () async {
    late http.Request sent;
    final client = fakeApiClient((request) async {
      sent = request;
      return jsonResponse([projectJson]);
    });

    final projects = await client.getProjects();

    expect(sent.method, 'GET');
    expect(sent.url.toString(), 'http://test.local/api/v1/projects/');
    expect(projects.single.id, projectJson['id']);
    expect(projects.single.technologies, 'React.js, Firebase');
    expect(projects.single.projectUrl, 'https://example.com/event');
    expect(projects.single.repositoryUrl, '');
  });

  test(
    'createProject sends the token and a snake_case body without id',
    () async {
      late http.Request sent;
      final client = fakeApiClient((request) async {
        sent = request;
        return jsonResponse({...projectJson, 'title': 'New'}, 201);
      });

      final created = await client.createProject(
        const Project(
          id: 'ignored',
          title: 'New',
          description: 'Desc',
          technologies: 'Flutter',
          repositoryUrl: 'https://github.com/x/y',
        ),
        token: 'abc123',
      );

      expect(sent.method, 'POST');
      expect(sent.headers['Authorization'], 'Token abc123');
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), {
        'title': 'New',
        'description': 'Desc',
        'technologies': 'Flutter',
        'project_url': '',
        'repository_url': 'https://github.com/x/y',
      });
      expect(created.title, 'New');
    },
  );

  test('obtainToken posts credentials and returns the token', () async {
    late http.Request sent;
    final client = fakeApiClient((request) async {
      sent = request;
      return jsonResponse({'token': 'secret-token'});
    });

    expect(await client.obtainToken('owner', 'pw'), 'secret-token');
    expect(sent.url.path, '/api/v1/auth/token/');
    expect(jsonDecode(sent.body), {'username': 'owner', 'password': 'pw'});
  });

  test('logout posts the token to the logout endpoint', () async {
    late http.Request sent;
    final client = fakeApiClient((request) async {
      sent = request;
      return http.Response('', 204);
    });

    await client.logout(token: 'secret-token');
    expect(sent.url.path, '/api/v1/auth/logout/');
    expect(sent.headers['Authorization'], 'Token secret-token');
  });

  test('non-2xx responses throw ApiException with the status code', () async {
    final client = fakeApiClient(
      (_) async => jsonResponse({'detail': 'nope'}, 401),
    );

    expect(
      () => client.getProjects(),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
  });
}
