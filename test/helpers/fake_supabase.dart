// test/helpers/fake_supabase.dart
//
// Lightweight stub pattern for Supabase interactions.
// These stubs intercept the HTTP layer so no real network call is made.
//
// Pattern 1 — Mock the repository directly (preferred for unit tests).
// Pattern 2 — Intercept http.Client (used when you need to test the
//             actual repository implementation end-to-end in isolation).

import 'dart:convert';
import 'package:mocktail/mocktail.dart';

// ── Pattern 1: Mock the repository boundary ───────────────────────────────────
//
// Your ResurrectionRepository wraps the Supabase call.  In unit tests, mock
// the *repository*, not Supabase itself.
//
// class MockResurrectionRepository extends Mock
//     implements ResurrectionRepository {}
//
// When(mock.analyseIdea(any())).thenAnswer(
//   (_) async => const SecondChanceDetected(
//     signals: ['Market timing is now better'],
//     nextSteps: ['Launch an MVP'],
//   ),
// );

// ── Pattern 2: Fake HTTP client for edge-function calls ────────────────────────

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http/testing.dart' show MockClient;

/// Creates a fake [http.Client] that returns a canned Supabase Edge Function
/// response.  Inject it into your repository via a constructor parameter or
/// a Riverpod override.
///
/// Usage:
/// ```dart
/// final fakeClient = fakeEdgeFunctionClient(
///   responseBody: jsonEncode({
///     'verdict': 'second_chance',
///     'signals': ['Trend is reviving'],
///     'next_steps': ['Validate with 10 users'],
///     'confidence': 0.82,
///   }),
/// );
/// final repo = ResurrectionRepository(httpClient: fakeClient);
/// ```
http.Client fakeEdgeFunctionClient({
  required String responseBody,
  int statusCode = 200,
  Map<String, String> headers = const {'content-type': 'application/json'},
}) {
  return MockClient((request) async {
    return http.Response(responseBody, statusCode, headers: headers);
  });
}

// ── Canned payloads ────────────────────────────────────────────────────────────

/// Pre-built JSON responses for each verdict type.
const Map<String, dynamic> kSecondChancePayload = {
  'verdict': 'second_chance',
  'signals': [
    'Market timing has improved significantly',
    'Competing solutions have validated demand',
  ],
  'next_steps': [
    'Run a 2-week validation sprint',
    'Interview 10 potential users',
  ],
  'confidence': 0.85,
};

const Map<String, dynamic> kSunsetConfirmedPayload = {
  'verdict': 'sunset_confirmed',
  'reasons': [
    'Market is dominated by well-funded incumbents',
    'Core assumption proved invalid',
  ],
  'confidence': 0.91,
};

const Map<String, dynamic> kNeedsMoreContextPayload = {
  'verdict': 'needs_more_context',
  'questions': [
    'What was your target customer segment?',
    'Why did you stop working on this?',
  ],
  'confidence': 0.40,
};

/// Returns the JSON string for [verdict].
/// [verdict] must be one of: 'second_chance', 'sunset_confirmed',
/// 'needs_more_context'.
String cannedResponse(String verdict) {
  switch (verdict) {
    case 'second_chance':
      return jsonEncode(kSecondChancePayload);
    case 'sunset_confirmed':
      return jsonEncode(kSunsetConfirmedPayload);
    case 'needs_more_context':
      return jsonEncode(kNeedsMoreContextPayload);
    default:
      throw ArgumentError('Unknown verdict: $verdict');
  }
}

// ── Fake Supabase auth session ─────────────────────────────────────────────────

/// A minimal fake of the data your app reads from Supabase auth.
/// Replace field types with your actual model types as needed.
class FakeAuthSession {
  final String userId;
  final String email;
  final String accessToken;

  const FakeAuthSession({
    this.userId = 'test-user-uuid-1234',
    this.email = 'test@example.com',
    this.accessToken = 'fake-jwt-token',
  });

  Map<String, dynamic> toJson() => {
        'user': {'id': userId, 'email': email},
        'access_token': accessToken,
      };
}

// ── Error stubs ────────────────────────────────────────────────────────────────

/// Returns a client that always throws a network error.
http.Client networkErrorClient() {
  return MockClient((_) async {
    throw Exception('Network unreachable');
  });
}

/// Returns a client that always responds with [statusCode] and an error body.
http.Client httpErrorClient({int statusCode = 500}) {
  return MockClient((_) async {
    return http.Response(
      jsonEncode({'error': 'Internal Server Error'}),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  });
}
