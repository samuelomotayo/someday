import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:someday/core/config/app_config.dart';
import 'package:someday/domain/entities/idea.dart';
import 'package:someday/features/ideas/presentation/providers/analysis_provider.dart';

class ResurrectionRepository {
  ResurrectionRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AnalysisState> analyseIdea({
    required Idea idea,
    required String accessToken,
  }) async {
    final uri = Uri.parse('${AppConfig.supabaseUrl}/functions/v1/analyse-idea');

    final payload = {
      'ideaId': idea.id,
      'title': idea.title,
      'description': idea.description,
      if (idea.timePeriod != null) 'timePeriod': idea.timePeriod,
      if (idea.reasonForStopping != null) 'reasonForStopping': idea.reasonForStopping,
      if (idea.emotionalNote != null) 'emotionalNote': idea.emotionalNote,
    };

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'apikey': AppConfig.supabaseAnonKey,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 402) {
      return const AnalysisError('Usage limit reached. Upgrade to continue.');
    }

    if (response.statusCode != 200) {
      return AnalysisError('Server error ${response.statusCode}. Please try again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final verdict = data['verdict'] as String? ?? '';

    return switch (verdict) {
      'second_chance' => SecondChanceDetected(
          summary: data['summary'] as String? ?? '',
          signals: List<String>.from(data['signals'] as List? ?? []),
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
        ),
      'sunset_confirmed' => SunsetConfirmed(
          summary: data['summary'] as String? ?? '',
          reasons: List<String>.from(data['reasons'] as List? ?? []),
        ),
      'needs_more_context' => NeedsMoreContext(
          questions: List<String>.from(data['questions'] as List? ?? []),
        ),
      _ => AnalysisError('Unexpected verdict from server.'),
    };
  }
}

