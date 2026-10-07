import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:someday/domain/entities/idea.dart';
import 'package:someday/shared/widgets/verdict_badge.dart';

class IdeaCard extends ConsumerWidget {
  const IdeaCard({required this.idea, this.onTap, super.key});

  final Idea idea;
  final VoidCallback? onTap;

  static final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      key: Key('idea_card_${idea.id}'),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      idea.title,
                      key: const Key('idea_card_title'),
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  VerdictBadge(verdict: idea.verdict),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _dateFormat.format(idea.createdAt),
                style: theme.textTheme.bodySmall,
              ),
              if (idea.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  idea.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
