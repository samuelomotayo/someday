import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:someday/features/ideas/presentation/providers/analysis_provider.dart';

class VerdictScreen extends ConsumerStatefulWidget {
  const VerdictScreen({required this.ideaId, super.key});

  final String ideaId;

  @override
  ConsumerState<VerdictScreen> createState() => _VerdictScreenState();
}

class _VerdictScreenState extends ConsumerState<VerdictScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bloomController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bloomController, curve: _SpringCurve()),
    );
  }

  @override
  void dispose() {
    _bloomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(analysisNotifierProvider(widget.ideaId));

    return Scaffold(
      appBar: AppBar(title: const Text('Verdict')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: switch (state) {
            AnalysisIdle() => _IdleFallback(theme: theme),
            AnalysisLoading() => const Center(child: CircularProgressIndicator()),
            AnalysisError(:final message) => _ErrorView(message: message, theme: theme),
            SecondChanceDetected(:final summary, :final signals, :final confidence) =>
              _SecondChanceView(
                state: SecondChanceDetected(summary: summary, signals: signals, confidence: confidence),
                scaleAnimation: _scaleAnimation,
                theme: theme,
              ),
            SunsetConfirmed(:final summary, :final reasons) => _SunsetView(
                state: SunsetConfirmed(summary: summary, reasons: reasons),
                theme: theme,
              ),
            NeedsMoreContext(:final questions) => _ContextView(
                state: NeedsMoreContext(questions: questions),
                theme: theme,
              ),
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-views
// ---------------------------------------------------------------------------

class _SecondChanceView extends StatelessWidget {
  const _SecondChanceView({
    required this.state,
    required this.scaleAnimation,
    required this.theme,
  });

  final SecondChanceDetected state;
  final Animation<double> scaleAnimation;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        ScaleTransition(
          scale: scaleAnimation,
          child: const _SeedIcon(color: Color(0xFF6EE7A0)),
        ),
        const SizedBox(height: 24),
        Text(
          'Second Chance Detected',
          key: const Key('verdict_headline'),
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        if (state.confidence > 0) ...[
          const SizedBox(height: 8),
          Text(
            '${(state.confidence * 100).round()}% confidence',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        Text(state.summary, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        Text('Signals', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...state.signals.asMap().entries.map(
              (e) => _SignalTile(key: Key('signal_${e.key}'), text: e.value),
            ),
      ],
    );
  }
}

class _SunsetView extends StatelessWidget {
  const _SunsetView({required this.state, required this.theme});

  final SunsetConfirmed state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        const _SeedIcon(color: Color(0xFFF9A8A8)),
        const SizedBox(height: 24),
        Text(
          'Sunset Confirmed',
          key: const Key('verdict_headline'),
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(state.summary, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        Text('Why this idea has run its course', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...state.reasons.asMap().entries.map(
              (e) => _SignalTile(key: Key('reason_${e.key}'), text: e.value),
            ),
      ],
    );
  }
}

class _ContextView extends StatelessWidget {
  const _ContextView({required this.state, required this.theme});

  final NeedsMoreContext state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        const _SeedIcon(color: Color(0xFFFBE08A)),
        const SizedBox(height: 24),
        Text(
          'Needs More Context',
          key: const Key('verdict_headline'),
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Answer these to get a clearer verdict.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...state.questions.asMap().entries.map(
              (e) => Card(
                key: Key('context_question_${e.key}'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(e.value, style: theme.textTheme.bodyLarge),
                ),
              ),
            ),
      ],
    );
  }
}

class _IdleFallback extends StatelessWidget {
  const _IdleFallback({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No verdict yet. Use Analyse to begin.',
        style: theme.textTheme.bodyMedium,
        key: const Key('idle_fallback'),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.theme});
  final String message;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        key: const Key('error_message'),
        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red[700]),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _SeedIcon extends StatelessWidget {
  const _SeedIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
        ),
        child: Icon(Icons.eco_outlined, size: 40, color: color),
      ),
    );
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({required this.text, super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFFC97D3A)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _SpringCurve extends Curve {
  @override
  double transformInternal(double t) {
    return math.sin(t * math.pi);
  }
}
