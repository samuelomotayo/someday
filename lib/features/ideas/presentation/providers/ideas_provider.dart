import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:someday/data/local/app_database.dart';
import 'package:someday/domain/entities/idea.dart' as domain;
import 'package:someday/domain/entities/verdict_type.dart';

part 'ideas_provider.g.dart';

// ---------------------------------------------------------------------------
// Database singleton — overridden in main.dart via ProviderScope
// ---------------------------------------------------------------------------

@riverpod
AppDatabase appDatabase(Ref ref) => AppDatabase();

// ---------------------------------------------------------------------------
// Reactive stream of all ideas, newest first
// ---------------------------------------------------------------------------

@riverpod
Stream<List<domain.Idea>> ideas(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.ideas)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch()
      .map((rows) => rows.map(_toIdea).toList());
}

// ---------------------------------------------------------------------------
// Single idea by ID
// ---------------------------------------------------------------------------

@riverpod
Stream<domain.Idea?> ideaById(Ref ref, String id) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.ideas)..where((t) => t.id.equals(id)))
      .watchSingleOrNull()
      .map((row) => row == null ? null : _toIdea(row));
}

// ---------------------------------------------------------------------------
// CRUD notifier
// ---------------------------------------------------------------------------

@riverpod
class IdeasNotifier extends _$IdeasNotifier {
  @override
  void build() {}

  AppDatabase get _db => ref.read(appDatabaseProvider);

  Future<void> save(domain.Idea idea) async {
    await _db.into(_db.ideas).insertOnConflictUpdate(
      IdeasCompanion.insert(
        id: idea.id,
        title: idea.title,
        description: idea.description,
        createdAt: idea.createdAt,
        timePeriod: Value(idea.timePeriod),
        reasonForStopping: Value(idea.reasonForStopping),
        emotionalNote: Value(idea.emotionalNote),
        verdict: Value(idea.verdict.name),
        aiOptIn: Value(idea.aiOptIn),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.ideas)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateVerdict(String id, VerdictType verdict) async {
    await (_db.update(_db.ideas)..where((t) => t.id.equals(id)))
        .write(IdeasCompanion(verdict: Value(verdict.name)));
  }
}

// ---------------------------------------------------------------------------
// Conversion helper
// ---------------------------------------------------------------------------

domain.Idea _toIdea(IdeaData row) => domain.Idea(
      id: row.id,
      title: row.title,
      description: row.description,
      createdAt: row.createdAt,
      timePeriod: row.timePeriod,
      reasonForStopping: row.reasonForStopping,
      emotionalNote: row.emotionalNote,
      verdict: VerdictType.values.byName(row.verdict),
      aiOptIn: row.aiOptIn,
    );
