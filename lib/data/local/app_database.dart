import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('IdeaData')
class Ideas extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get timePeriod => text().nullable()();
  TextColumn get reasonForStopping => text().nullable()();
  TextColumn get emotionalNote => text().nullable()();
  TextColumn get verdict => text().withDefault(const Constant('notYetAnalysed'))();
  BoolColumn get aiOptIn => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Ideas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'someday.db'));
    // TODO(v1.1): Add SQLCipher at-rest encryption once sqlcipher_flutter_libs
    // resolves its Android compileSdk compatibility issue.
    return NativeDatabase.createInBackground(file);
  });
}
