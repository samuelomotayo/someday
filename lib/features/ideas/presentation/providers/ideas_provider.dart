import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:someday/domain/entities/idea.dart' as domain;
import 'package:someday/domain/entities/verdict_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'ideas_provider.g.dart';

// ---------------------------------------------------------------------------
// Ideas are stored in Supabase (table `ideas`, RLS-scoped to auth.uid()) so
// the same list is visible across every signed-in device — mobile, web, or
// desktop. See docs/SETUP_GUIDE.md / README for the table + RLS policy SQL.
// ---------------------------------------------------------------------------

SupabaseClient get _client => Supabase.instance.client;

String? get _currentUserId => _client.auth.currentUser?.id;

// ---------------------------------------------------------------------------
// Reactive stream of all ideas, newest first
// ---------------------------------------------------------------------------

@riverpod
Stream<List<domain.Idea>> ideas(Ref ref) {
  final userId = _currentUserId;
  if (userId == null) return Stream.value(const []);

  return _client
      .from('ideas')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((rows) => rows.map(_toIdea).toList());
}

// ---------------------------------------------------------------------------
// Single idea by ID
// ---------------------------------------------------------------------------

@riverpod
Stream<domain.Idea?> ideaById(Ref ref, String id) {
  return _client
      .from('ideas')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((rows) => rows.isEmpty ? null : _toIdea(rows.first));
}

// ---------------------------------------------------------------------------
// CRUD notifier
// ---------------------------------------------------------------------------

@riverpod
class IdeasNotifier extends _$IdeasNotifier {
  @override
  void build() {}

  Future<void> save(domain.Idea idea) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('Cannot save an idea while signed out.');
    }
    await _client.from('ideas').upsert({..._toRow(idea), 'user_id': userId});
  }

  Future<void> delete(String id) async {
    await _client.from('ideas').delete().eq('id', id);
  }

  Future<void> updateVerdict(String id, VerdictType verdict) async {
    await _client.from('ideas').update({'verdict': verdict.name}).eq('id', id);
  }
}

// ---------------------------------------------------------------------------
// Conversion helpers
// ---------------------------------------------------------------------------

domain.Idea _toIdea(Map<String, dynamic> row) => domain.Idea(
  id: row['id'] as String,
  title: row['title'] as String,
  description: row['description'] as String,
  createdAt: DateTime.parse(row['created_at'] as String),
  timePeriod: row['time_period'] as String?,
  reasonForStopping: row['reason_for_stopping'] as String?,
  emotionalNote: row['emotional_note'] as String?,
  verdict: VerdictType.values.byName(row['verdict'] as String),
  aiOptIn: row['ai_opt_in'] as bool,
);

Map<String, dynamic> _toRow(domain.Idea idea) => {
  'id': idea.id,
  'title': idea.title,
  'description': idea.description,
  'created_at': idea.createdAt.toIso8601String(),
  'time_period': idea.timePeriod,
  'reason_for_stopping': idea.reasonForStopping,
  'emotional_note': idea.emotionalNote,
  'verdict': idea.verdict.name,
  'ai_opt_in': idea.aiOptIn,
};
