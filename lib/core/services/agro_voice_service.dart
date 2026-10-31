// lib/core/services/agro_voice_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AgroVoiceService {
  static final AgroVoiceService _instance = AgroVoiceService._internal();
  factory AgroVoiceService() => _instance;
  AgroVoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  final ValueNotifier<bool> isListeningNotifier = ValueNotifier<bool>(false);
  final StreamController<String> _commandStreamController = StreamController<String>.broadcast();

  Stream<String> get onCommandRecognized => _commandStreamController.stream;
  bool get isListening => _isListening;

  Future<bool> init() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (val) {
        debugPrint('❌ Error STT: ${val.errorMsg} (permanente: ${val.permanent})');

        // Ignoramos silencios o ruidos no reconocidos para evitar cancelar el bucle
        final isIgnorableError = val.errorMsg.contains('error_speech_timeout') ||
            val.errorMsg.contains('error_no_match');

        if (val.permanent && !isIgnorableError) {
          detenerEscucha();
        }
      },
      onStatus: (status) {
        debugPrint('📡 Estado STT: $status');
        if (status == 'notListening' && _isListening && !_isSpeaking) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (_isListening && !_isSpeaking) {
              _iniciarBucleEscucha();
            }
          });
        }
      },
    );

    await _tts.setLanguage("es-CO");
    await _tts.setSpeechRate(0.55);

    return _isInitialized;
  }

  Future<void> alternarEscucha() async {
    if (!_isInitialized) {
      final ok = await init();
      if (!ok) {
        debugPrint('❌ No se pudo inicializar SpeechToText.');
        return;
      }
    }

    if (_isListening) {
      await detenerEscucha();
      await hablar('Asistente desactivado');
      return;
    }

    _isListening = true;
    isListeningNotifier.value = true;
    await hablar('Te escucho');
  }

  void _iniciarBucleEscucha() async {
    if (!_isListening || _isSpeaking) return;

    if (!_speech.isListening) {
      try {
        await _speech.listen(
          onResult: (result) {
            final comando = result.recognizedWords.toLowerCase().trim();
            if (comando.isNotEmpty) {
              _commandStreamController.add(comando);
            }
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        );
      } catch (e) {
        debugPrint('⚠️ Excepción al escuchar: $e');
      }
    }
  }

  Future<void> pausarBrevemente() async {
    await _speech.stop();
  }

  Future<void> detenerEscucha() async {
    _isListening = false;
    _isSpeaking = false;
    isListeningNotifier.value = false;
    await _speech.stop();
    await _tts.stop();
  }

  Future<void> hablar(String texto) async {
    _isSpeaking = true;
    await _speech.stop(); // Detenemos el micrófono antes de reproducir audio sintético

    await _tts.speak(texto);
    await _tts.awaitSpeakCompletion(true);

    _isSpeaking = false;

    // Reactivamos el micrófono dando tiempo a que se libere el altavoz
    if (_isListening) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_isListening) {
          _iniciarBucleEscucha();
        }
      });
    }
  }

  void dispose() {
    _commandStreamController.close();
    isListeningNotifier.dispose();
  }
}