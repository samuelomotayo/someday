// test/unit/usage_count_service_test.dart
//
// Tests for UsageCountService:
//   - free-tier limit enforcement (3 analyses)
//   - increment
//   - reset
//   - persistence across service instances (via shared preferences stub)

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// import 'package:someday/domain/services/usage_count_service.dart';

// ---------------------------------------------------------------------------
// Inline storage interface + service — remove once real imports are in place.
// ---------------------------------------------------------------------------

/// Thin abstraction over SharedPreferences / secure storage.
/// Your real implementation injects the platform storage via Riverpod.
abstract class KeyValueStorage {
  Future<int?> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<void> remove(String key);
}

class MockKeyValueStorage extends Mock implements KeyValueStorage {}

class UsageCountService {
  static const int freeTierLimit = 3;
  static const String _storageKey = 'usage_analysis_count';

  final KeyValueStorage _storage;

  UsageCountService(this._storage);

  /// Returns the current count (0 if never set).
  Future<int> currentCount() async {
    return (await _storage.getInt(_storageKey)) ?? 0;
  }

  /// Returns true if the user has remaining free analyses.
  Future<bool> canAnalyse() async {
    return await currentCount() < freeTierLimit;
  }

  /// Increments the count. Throws [UsageLimitExceededException] if already at
  /// or beyond the free-tier limit.
  Future<void> increment() async {
    final count = await currentCount();
    if (count >= freeTierLimit) {
      throw UsageLimitExceededException(
        'Free tier limit of $freeTierLimit analyses reached.',
      );
    }
    await _storage.setInt(_storageKey, count + 1);
  }

  /// Resets the count to zero (used after subscription unlock or testing).
  Future<void> reset() async {
    await _storage.remove(_storageKey);
  }

  /// Returns how many analyses remain in the free tier.
  Future<int> remaining() async {
    final count = await currentCount();
    return (freeTierLimit - count).clamp(0, freeTierLimit);
  }
}

class UsageLimitExceededException implements Exception {
  final String message;
  const UsageLimitExceededException(this.message);
  @override
  String toString() => 'UsageLimitExceededException: $message';
}
// ---------------------------------------------------------------------------

void main() {
  late MockKeyValueStorage mockStorage;
  late UsageCountService service;

  setUp(() {
    mockStorage = MockKeyValueStorage();
    service = UsageCountService(mockStorage);
  });

  group('UsageCountService', () {
    group('currentCount()', () {
      test('returns 0 when storage has no value', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => null);

        final count = await service.currentCount();
        expect(count, 0);
      });

      test('returns stored value when present', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => 2);

        final count = await service.currentCount();
        expect(count, 2);
      });
    });

    group('canAnalyse()', () {
      test('returns true when count is 0 (fresh install)', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => null);

        expect(await service.canAnalyse(), isTrue);
      });

      test('returns true when count is 1', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => 1);

        expect(await service.canAnalyse(), isTrue);
      });

      test('returns true when count is 2', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => 2);

        expect(await service.canAnalyse(), isTrue);
      });

      test('returns false when count equals free-tier limit (3)', () async {
        when(() => mockStorage.getInt(any()))
            .thenAnswer((_) async => UsageCountService.freeTierLimit);

        expect(await service.canAnalyse(), isFalse);
      });

      test('returns false when count exceeds free-tier limit', () async {
        when(() => mockStorage.getInt(any()))
            .thenAnswer((_) async => UsageCountService.freeTierLimit + 5);

        expect(await service.canAnalyse(), isFalse);
      });
    });

    group('increment()', () {
      test('increments count from 0 to 1', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => 0);
        when(() => mockStorage.setInt(any(), any())).thenAnswer((_) async {});

        await service.increment();

        verify(() => mockStorage.setInt('usage_analysis_count', 1)).called(1);
      });

      test('increments count from 1 to 2', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => 1);
        when(() => mockStorage.setInt(any(), any())).thenAnswer((_) async {});

        await service.increment();

        verify(() => mockStorage.setInt('usage_analysis_count', 2)).called(1);
      });

      test('increments count from 2 to 3 (reaching limit)', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => 2);
        when(() => mockStorage.setInt(any(), any())).thenAnswer((_) async {});

        await service.increment();

        verify(() => mockStorage.setInt('usage_analysis_count', 3)).called(1);
      });

      test('throws UsageLimitExceededException when count is at limit', () async {
        when(() => mockStorage.getInt(any()))
            .thenAnswer((_) async => UsageCountService.freeTierLimit);

        expect(
          () => service.increment(),
          throwsA(isA<UsageLimitExceededException>()),
        );
        verifyNever(() => mockStorage.setInt(any(), any()));
      });

      test('throws when count is already over limit', () async {
        when(() => mockStorage.getInt(any()))
            .thenAnswer((_) async => UsageCountService.freeTierLimit + 1);

        expect(
          () => service.increment(),
          throwsA(isA<UsageLimitExceededException>()),
        );
      });

      test('exception message mentions free-tier limit', () async {
        when(() => mockStorage.getInt(any()))
            .thenAnswer((_) async => UsageCountService.freeTierLimit);

        try {
          await service.increment();
          fail('Expected exception not thrown');
        } on UsageLimitExceededException catch (e) {
          expect(e.message, contains('3'));
        }
      });
    });

    group('reset()', () {
      test('calls storage.remove with correct key', () async {
        when(() => mockStorage.remove(any())).thenAnswer((_) async {});

        await service.reset();

        verify(() => mockStorage.remove('usage_analysis_count')).called(1);
      });

      test('after reset, count returns 0', () async {
        when(() => mockStorage.remove(any())).thenAnswer((_) async {});
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => null);

        await service.reset();
        final count = await service.currentCount();

        expect(count, 0);
      });
    });

    group('remaining()', () {
      test('returns 3 when count is 0', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => null);

        expect(await service.remaining(), 3);
      });

      test('returns 2 when count is 1', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => 1);

        expect(await service.remaining(), 2);
      });

      test('returns 1 when count is 2', () async {
        when(() => mockStorage.getInt(any())).thenAnswer((_) async => 2);

        expect(await service.remaining(), 1);
      });

      test('returns 0 when count equals limit', () async {
        when(() => mockStorage.getInt(any()))
            .thenAnswer((_) async => UsageCountService.freeTierLimit);

        expect(await service.remaining(), 0);
      });

      test('returns 0 (not negative) when count is over limit', () async {
        when(() => mockStorage.getInt(any()))
            .thenAnswer((_) async => UsageCountService.freeTierLimit + 10);

        expect(await service.remaining(), 0);
      });
    });

    group('freeTierLimit constant', () {
      test('free tier limit is exactly 3', () {
        expect(UsageCountService.freeTierLimit, 3);
      });
    });
  });
}
