import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:someday/domain/entities/idea.dart';
import 'package:someday/features/ideas/presentation/providers/ideas_provider.dart';
import 'package:someday/features/ideas/presentation/screens/voice_idea_screen.dart';
import 'package:someday/shared/widgets/voice_input_button.dart';

class EditIdeaScreen extends ConsumerStatefulWidget {
  const EditIdeaScreen({required this.ideaId, super.key});

  final String ideaId;

  @override
  ConsumerState<EditIdeaScreen> createState() => _EditIdeaScreenState();
}

class _EditIdeaScreenState extends ConsumerState<EditIdeaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timePeriodCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _emotionalCtrl = TextEditingController();
  bool _aiOptIn = true;
  bool _isSaving = false;
  bool _loaded = false;

  void _loadIdea(Idea idea) {
    if (_loaded) return;
    _loaded = true;
    _titleCtrl.text = idea.title;
    _descCtrl.text = idea.description;
    _timePeriodCtrl.text = idea.timePeriod ?? '';
    _reasonCtrl.text = idea.reasonForStopping ?? '';
    _emotionalCtrl.text = idea.emotionalNote ?? '';
    _aiOptIn = idea.aiOptIn;
  }

  Future<void> _save(Idea original) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updated = original.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      timePeriod: _timePeriodCtrl.text.trim().isEmpty ? null : _timePeriodCtrl.text.trim(),
      reasonForStopping: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
      emotionalNote: _emotionalCtrl.text.trim().isEmpty ? null : _emotionalCtrl.text.trim(),
      aiOptIn: _aiOptIn,
    );

    try {
      await ref.read(ideasNotifierProvider.notifier).save(updated);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _timePeriodCtrl.dispose();
    _reasonCtrl.dispose();
    _emotionalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ideaAsync = ref.watch(ideaByIdProvider(widget.ideaId));
    final theme = Theme.of(context);

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

        _loadIdea(idea);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit idea'),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : () => _save(idea),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Save',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: const Color(0xFFC97D3A),
                        ),
                      ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _VoicePromptBanner(
                    onTranscript: (text) {
                      _descCtrl.text = _descCtrl.text.isEmpty
                          ? text
                          : '${_descCtrl.text} $text';
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('What was the idea?', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleCtrl,
                    maxLength: Idea.titleMaxLength,
                    decoration: const InputDecoration(
                      hintText: 'e.g. An app that tracks habit streaks',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Give your idea a title';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Describe it in detail',
                            style: theme.textTheme.titleMedium),
                      ),
                      VoiceInputButton(
                        size: 36,
                        onResult: (text) {
                          _descCtrl.text = _descCtrl.text.isEmpty
                              ? text
                              : '${_descCtrl.text} $text';
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 5,
                    maxLength: Idea.descriptionMaxLength,
                    decoration: const InputDecoration(
                      hintText: 'What was the vision? Who was it for?',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Describe the idea';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('When did you have this idea? (optional)',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _timePeriodCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 2022, "last summer", college',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Why did you stop? (optional)',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Ran out of time, couldn\'t find co-founder',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('How do you feel about it now? (optional)',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emotionalCtrl,
                    maxLength: Idea.emotionalNoteMaxLength,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Still think about it, moved on, not sure',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _aiOptIn,
                    onChanged: (v) => setState(() => _aiOptIn = v),
                    title: Text('Allow AI analysis',
                        style: theme.textTheme.titleSmall),
                    subtitle: Text(
                      'Your idea text will be sent to Claude for a verdict.',
                      style: theme.textTheme.bodySmall,
                    ),
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: const Color(0xFFC97D3A),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => _save(idea),
                    child: const Text('Save changes'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VoicePromptBanner extends StatelessWidget {
  const _VoicePromptBanner({required this.onTranscript});

  final ValueChanged<String> onTranscript;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push<String>(
          MaterialPageRoute(builder: (_) => const VoiceIdeaScreen()),
        );
        if (result != null && result.isNotEmpty) {
          onTranscript(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFC97D3A).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFC97D3A).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFC97D3A),
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Speak your idea',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF1C2B3A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to describe your idea by voice',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF7A8C7E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFFC97D3A),
            ),
          ],
        ),
      ),
    );
  }
}
