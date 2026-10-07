import 'package:flutter/material.dart';

/// Shown before sending an idea's content to the Claude API.
/// Returns true if the user consents, false/null if they decline.
Future<bool> showPrivacyConsentDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _PrivacyConsentDialog(),
  );
  return result ?? false;
}

class _PrivacyConsentDialog extends StatelessWidget {
  const _PrivacyConsentDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      key: const Key('privacy_consent_dialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Before we analyse this idea',
        style: theme.textTheme.headlineSmall,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To give you a verdict, we\'ll send this idea\'s title, description, and context to the Someday AI engine.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _BulletPoint(
            icon: Icons.lock_outline,
            text: 'Your idea is not stored beyond this session.',
          ),
          _BulletPoint(
            icon: Icons.block,
            text: 'It is never used to train AI models.',
          ),
          _BulletPoint(
            icon: Icons.visibility_off_outlined,
            text: 'Only you can see the result.',
          ),
          const SizedBox(height: 12),
          Text(
            'You can decline and keep this idea private.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('privacy_decline_button'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Keep Private',
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
        FilledButton(
          key: const Key('privacy_consent_button'),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Analyse My Idea'),
        ),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
