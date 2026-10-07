import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:someday/data/repositories/resurrection_repository.dart';
import 'package:someday/domain/entities/idea.dart';
import 'package:someday/domain/entities/verdict_type.dart';
import 'package:someday/features/ideas/data/repositories/usage_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'analysis_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class AnalysisState {
  const AnalysisState();
}

final class AnalysisIdle extends AnalysisState {
  const AnalysisIdle();
}

final class AnalysisLoading extends AnalysisState {
  const AnalysisLoading();
}

final class SecondChanceDetected extends AnalysisState {
  const SecondChanceDetected({
    required this.summary,
    required this.signals,
    this.confidence = 0.0,
  });

  final String summary;
  final List<String> signals;
  final double confidence;
}

final class SunsetConfirmed extends AnalysisState {
  const SunsetConfirmed({required this.summary, required this.reasons});

  final String summary;
  final List<String> reasons;
}

final class NeedsMoreContext extends AnalysisState {
  const NeedsMoreContext({required this.questions});

  final List<String> questions;
}

final class AnalysisError extends AnalysisState {
  const AnalysisError(this.message);

  final String message;
}

// ---------------------------------------------------------------------------
// Derived helper — converts state to VerdictType without separate storage
// ---------------------------------------------------------------------------

extension AnalysisStateVerdict on AnalysisState {
  VerdictType get verdictType => switch (this) {
        AnalysisIdle() || AnalysisLoading() || AnalysisError() =>
          VerdictType.notYetAnalysed,
        SecondChanceDetected() => VerdictType.secondChance,
        SunsetConfirmed() => VerdictType.sunsetConfirmed,
        NeedsMoreContext() => VerdictType.needsMoreContext,
      };
}

// ---------------------------------------------------------------------------
// Provider — family-scoped by ideaId so two ideas maintain independent state
// ---------------------------------------------------------------------------

@riverpod
class AnalysisNotifier extends _$AnalysisNotifier {
  @override
  AnalysisState build(String ideaId) => const AnalysisIdle();

  Future<void> analyse(Idea idea) async {
    assert(idea.id == ideaId, 'Idea ID mismatch');

    final usageService = UsageCountService();
    if (!await usageService.canAnalyse()) {
      state = const AnalysisError(
        'You have used all 3 free analyses. Upgrade to continue.',
      );
      return;
    }

    state = const AnalysisLoading();

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        state = const AnalysisError('Please sign in to analyse your idea.');
        return;
      }

      final result = await ResurrectionRepository().analyseIdea(
        idea: idea,
        accessToken: session.accessToken,
      );

      // Only increment count on a successful verdict — not on error states.
      if (result is! AnalysisError) {
        await usageService.increment();
      }

      state = result;
    } catch (e) {
      state = AnalysisError(e.toString());
    }
  }

  void reset() => state = const AnalysisIdle();
}
