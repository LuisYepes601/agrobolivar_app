import 'package:flutter/material.dart';
import 'package:agro_bolivar/core/services/agro_voice_service.dart';

class VoiceFloatingButton extends StatelessWidget {
  const VoiceFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceService = AgroVoiceService();
    final primaryColor = Theme.of(context).primaryColor;

    return ValueListenableBuilder<bool>(
      valueListenable: voiceService.isListeningNotifier,
      builder: (context, isListening, child) {
        return FloatingActionButton.extended(
          backgroundColor: isListening ? Colors.redAccent : primaryColor,
          elevation: isListening ? 12 : 6,
          icon: Icon(
            isListening ? Icons.graphic_eq : Icons.mic,
            color: Colors.white,
          ),
          label: Text(
            isListening ? 'Escuchando...' : 'Hablar',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => voiceService.alternarEscucha(),
        );
      },
    );
  }
}