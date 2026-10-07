import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:someday/domain/entities/idea.dart';
import 'package:someday/features/ideas/presentation/providers/analysis_provider.dart';
import 'package:someday/shared/widgets/privacy_consent_dialog.dart';

class AnalyseButton extends ConsumerWidget {
  const AnalyseButton({required this.idea, this.label, super.key});

  final Idea idea;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisNotifierProvider(idea.id));
    final isLoading = state is AnalysisLoading;

    return ElevatedButton(
      key: const Key('analyse_button'),
      onPressed: isLoading ? null : () => _onTap(context, ref),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: isLoading
            ? const SizedBox(
                key: Key('analyse_button_loading'),
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                key: const Key('analyse_button_label'),
                label ?? 'Give This Idea a Second Chance',
              ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    // CRITICAL: Privacy gate — user must explicitly consent before content
    // is sent to the Supabase Edge Function / Claude API.
    final consented = await showPrivacyConsentDialog(context);
    if (!consented) return;

    if (!context.mounted) return;
    await ref.read(analysisNotifierProvider(idea.id).notifier).analyse(idea);
  }
}
