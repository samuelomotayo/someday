import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:someday/core/config/app_config.dart';

class UsageLimitExceededException implements Exception {
  const UsageLimitExceededException();

  @override
  String toString() => 'Free analysis limit of ${AppConfig.freeTierAnalysisLimit} reached.';
}

class UsageCountService {
  const UsageCountService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'someday_analysis_count';

  Future<int> currentCount() async {
    final raw = await _storage.read(key: _key);
    return int.tryParse(raw ?? '0') ?? 0;
  }

  Future<bool> canAnalyse() async {
    final count = await currentCount();
    return count < AppConfig.freeTierAnalysisLimit;
  }

  Future<int> remaining() async {
    final count = await currentCount();
    final rem = AppConfig.freeTierAnalysisLimit - count;
    return rem < 0 ? 0 : rem;
  }

  /// Increments the count. Throws [UsageLimitExceededException] if already at limit.
  Future<void> increment() async {
    final count = await currentCount();
    if (count >= AppConfig.freeTierAnalysisLimit) {
      throw const UsageLimitExceededException();
    }
    await _storage.write(key: _key, value: (count + 1).toString());
  }

  Future<void> reset() async {
    await _storage.write(key: _key, value: '0');
  }
}
