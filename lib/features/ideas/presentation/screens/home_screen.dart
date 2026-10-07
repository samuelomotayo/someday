import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:someday/core/router/app_router.dart';
import 'package:someday/features/ideas/presentation/providers/ideas_provider.dart';
import 'package:someday/features/ideas/presentation/screens/voice_idea_screen.dart';
import 'package:someday/features/ideas/presentation/widgets/idea_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasAsync = ref.watch(ideasProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Someday'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: ideasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error loading ideas: $e', style: theme.textTheme.bodyMedium),
        ),
        data: (ideas) {
          if (ideas.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco_outlined, size: 64, color: Color(0xFFC97D3A)),
                  const SizedBox(height: 16),
                  Text('No ideas yet', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first abandoned idea.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF7A8C7E)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: ideas.length,
            itemBuilder: (_, i) => IdeaCard(
              idea: ideas[i],
              onTap: () => context.push('/idea/${ideas[i].id}'),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'voice_fab',
            onPressed: () async {
              final transcript = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => const VoiceIdeaScreen()),
              );
              if (transcript != null && transcript.isNotEmpty && context.mounted) {
                context.push(kRouteNewIdea, extra: transcript);
              }
            },
            backgroundColor: const Color(0xFFF0EDE8),
            foregroundColor: const Color(0xFFC97D3A),
            child: const Icon(Icons.mic_rounded),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_idea_fab',
            key: const Key('add_idea_fab'),
            onPressed: () => context.push(kRouteNewIdea),
            backgroundColor: const Color(0xFFC97D3A),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add idea'),
          ),
        ],
      ),
    );
  }
}
