import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const projectJson = {
  'id': '0552b486-2ecc-4cff-90af-954033813469',
  'title': 'Secure Event Attendance Platform',
  'description': 'Platform manajemen event dengan QR code aman.',
  'technologies': 'React.js, Firebase',
  'project_url': 'https://example.com/event',
  'repository_url': '',
  'star_count': 2,
  'is_starred': false,
  'starred_by_names': 'alice, bob',
};

/// Builds an [ApiClient] whose HTTP calls are answered by [handler].
ApiClient fakeApiClient([
  Future<http.Response> Function(http.Request request)? handler,
]) {
  return ApiClient(
    baseUrl: 'http://test.local',
    client: MockClient(handler ?? (_) async => http.Response('[]', 200)),
  );
}

http.Response jsonResponse(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);
