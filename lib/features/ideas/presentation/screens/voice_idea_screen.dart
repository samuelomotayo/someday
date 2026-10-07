import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceIdeaScreen extends StatefulWidget {
  const VoiceIdeaScreen({super.key});

  @override
  State<VoiceIdeaScreen> createState() => _VoiceIdeaScreenState();
}

class _VoiceIdeaScreenState extends State<VoiceIdeaScreen>
    with SingleTickerProviderStateMixin {
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _transcript = '';
  String _partial = '';
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (_) => _stopListening(),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _stopListening();
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _startListening() async {
    if (!_isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _partial = '';
    });
    _pulseCtrl.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          if (result.finalResult) {
            if (_transcript.isNotEmpty) {
              _transcript += ' ';
            }
            _transcript += result.recognizedWords;
            _partial = '';
          } else {
            _partial = result.recognizedWords;
          }
        });
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 4),
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  void _stopListening() {
    _speech.stop();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    if (mounted) setState(() => _isListening = false);
  }

  void _clearTranscript() {
    setState(() {
      _transcript = '';
      _partial = '';
    });
  }

  void _useTranscript() {
    final text = _transcript.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = _transcript +
        (_partial.isNotEmpty ? (_transcript.isNotEmpty ? ' ' : '') + _partial : '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speak your idea'),
        actions: [
          if (_transcript.isNotEmpty)
            TextButton(
              onPressed: _useTranscript,
              child: Text(
                'Use this',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFC97D3A),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: displayText.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_none_rounded,
                            size: 64,
                            color: const Color(0xFFC97D3A).withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap the mic and tell us\nabout your idea',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF7A8C7E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        displayText,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          height: 1.6,
                        ),
                      ),
                    ),
            ),
          ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Listening...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFC97D3A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_transcript.isNotEmpty && !_isListening)
                    IconButton(
                      onPressed: _clearTranscript,
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Clear',
                      color: const Color(0xFF7A8C7E),
                    ),
                  const SizedBox(width: 16),
                  ScaleTransition(
                    scale: _isListening
                        ? _pulseAnim
                        : const AlwaysStoppedAnimation(1.0),
                    child: GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? const Color(0xFFC97D3A)
                              : const Color(0xFFF0EDE8),
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFC97D3A)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 32,
                          color: _isListening
                              ? Colors.white
                              : const Color(0xFFC97D3A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_transcript.isNotEmpty && !_isListening)
                    IconButton(
                      onPressed: _startListening,
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Add more',
                      color: const Color(0xFF7A8C7E),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
