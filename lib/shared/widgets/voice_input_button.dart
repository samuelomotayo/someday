import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.size = 48,
  });

  final ValueChanged<String> onResult;
  final double size;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnim = Tween(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (_) => _stop(),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _stop();
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      _stop();
      return;
    }

    if (!_isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
      return;
    }

    setState(() => _isListening = true);
    _pulseCtrl.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          widget.onResult(result.recognizedWords);
          _stop();
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  void _stop() {
    _speech.stop();
    _pulseCtrl.stop();
    _pulseCtrl.reset();
    if (mounted) setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _isListening ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
      child: IconButton(
        iconSize: widget.size * 0.5,
        style: IconButton.styleFrom(
          backgroundColor:
              _isListening ? const Color(0xFFC97D3A) : const Color(0xFFF0EDE8),
          fixedSize: Size(widget.size, widget.size),
        ),
        onPressed: _toggleListening,
        icon: Icon(
          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
          color: _isListening ? Colors.white : const Color(0xFFC97D3A),
        ),
      ),
    );
  }
}
