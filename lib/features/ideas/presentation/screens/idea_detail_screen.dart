import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:someday/domain/entities/idea.dart';
import 'package:someday/features/ideas/presentation/providers/analysis_provider.dart';
import 'package:someday/features/ideas/presentation/providers/ideas_provider.dart';
import 'package:someday/features/ideas/presentation/widgets/analyse_button.dart';
import 'package:someday/shared/widgets/verdict_badge.dart';

class IdeaDetailScreen extends ConsumerWidget {
  const IdeaDetailScreen({required this.ideaId, super.key});

  final String ideaId;

  static final _dateFormat = DateFormat('MMMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideaAsync = ref.watch(ideaByIdProvider(ideaId));
    return ideaAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (idea) {
        if (idea == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Idea not found')),
          );
        }
        return _IdeaDetailBody(idea: idea);
      },
    );
  }
}

class _IdeaDetailBody extends ConsumerWidget {
  const _IdeaDetailBody({required this.idea});

  final Idea idea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analysisState = ref.watch(analysisNotifierProvider(idea.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(idea.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit idea',
            onPressed: () => context.push('/idea/${idea.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete idea',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete idea?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Delete', style: TextStyle(color: Colors.red[700])),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(ideasNotifierProvider.notifier).delete(idea.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  IdeaDetailScreen._dateFormat.format(idea.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              VerdictBadge(verdict: idea.verdict),
            ],
          ),
          const SizedBox(height: 20),
          Text('Idea', style: theme.textTheme.titleSmall?.copyWith(color: const Color(0xFF7A8C7E))),
          const SizedBox(height: 6),
          Text(idea.description, style: theme.textTheme.bodyLarge),
          if (idea.timePeriod != null) ...[
            const SizedBox(height: 20),
            Text('When', style: theme.textTheme.titleSmall?.copyWith(color: const Color(0xFF7A8C7E))),
            const SizedBox(height: 6),
            Text(idea.timePeriod!, style: theme.textTheme.bodyLarge),
          ],
          if (idea.reasonForStopping != null) ...[
            const SizedBox(height: 20),
            Text(
              'Why I stopped',
              style: theme.textTheme.titleSmall?.copyWith(color: const Color(0xFF7A8C7E)),
            ),
            const SizedBox(height: 6),
            Text(idea.reasonForStopping!, style: theme.textTheme.bodyLarge),
          ],
          if (idea.emotionalNote != null) ...[
            const SizedBox(height: 20),
            Text(
              'How I feel about it',
              style: theme.textTheme.titleSmall?.copyWith(color: const Color(0xFF7A8C7E)),
            ),
            const SizedBox(height: 6),
            Text(idea.emotionalNote!, style: theme.textTheme.bodyLarge),
          ],
          const Divider(height: 48),
          if (analysisState is SecondChanceDetected ||
              analysisState is SunsetConfirmed ||
              analysisState is NeedsMoreContext) ...[
            ElevatedButton.icon(
              onPressed: () => context.push('/idea/${idea.id}/verdict'),
              icon: const Icon(Icons.insights_outlined),
              label: const Text('View verdict'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ref.read(analysisNotifierProvider(idea.id).notifier).reset();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: Color(0xFFC97D3A)),
              ),
              child: const Text(
                'Analyse again',
                style: TextStyle(color: Color(0xFFC97D3A)),
              ),
            ),
          ] else ...[
            if (idea.aiOptIn)
              AnalyseButton(idea: idea)
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE7E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI analysis is disabled for this idea. Edit the idea to enable it.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
