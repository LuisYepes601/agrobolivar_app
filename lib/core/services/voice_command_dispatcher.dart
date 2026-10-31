// lib/core/services/voice_command_dispatcher.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agro_bolivar/core/services/agro_voice_service.dart';

class VoiceCommandDispatcher {
  static final VoiceCommandDispatcher _instance = VoiceCommandDispatcher._internal();
  factory VoiceCommandDispatcher() => _instance;
  VoiceCommandDispatcher._internal();

  final AgroVoiceService _voiceService = AgroVoiceService();
  StreamSubscription<String>? _subscription;

  void Function(int index)? onNavigateToTab;
  VoidCallback? onOpenPerfil;

  void inicializar({
    void Function(int index)? onNavigateToTab,
    VoidCallback? onOpenPerfil,
  }) {
    this.onNavigateToTab = onNavigateToTab;
    this.onOpenPerfil = onOpenPerfil;

    _subscription?.cancel();
    _subscription = _voiceService.onCommandRecognized.listen(_procesarTexto);
  }

  void _procesarTexto(String comando) {
    if (comando.isEmpty) return;

    // 🔍 MUESTRA EN CONSOLA LO QUE EL MICRÓFONO ESCUCHÓ
    debugPrint('🗣️ Comandos recibidos en Dispatcher: "$comando"');

    // 1. Desactivar voz
    if (_coincide(comando, ['desactivar modo escucha', 'desactivar escucha', 'apagar asistente', 'desactivar voz', 'silencio'])) {
      _voiceService.detenerEscucha();
      _voiceService.hablar('Modo silencio');
      return;
    }

    // 2. Navegación global
    if (_coincide(comando, ['inicio', 'panel', 'home', 'pantalla principal', 'ir al inicio', 'volver'])) {
      debugPrint('🚀 Ejecutando navegación -> Inicio (0)');
      onNavigateToTab?.call(0);
      _voiceService.hablar('Inicio');
    }
    else if (_coincide(comando, ['mis productos', 'mis ventas', 'lo que vendo', 'ver mis productos', 'productos'])) {
      debugPrint('🚀 Ejecutando navegación -> Mis Productos (1)');
      onNavigateToTab?.call(1);
      _voiceService.hablar('Mis productos');
    }
    else if (_coincide(comando, ['mis cultivos', 'mis fincas', 'mi finca', 'mis lotes'])) {
      debugPrint('🚀 Ejecutando navegación -> Mis Cultivos (2)');
      onNavigateToTab?.call(2);
      _voiceService.hablar('Mis cultivos');
    }
    else if (_coincide(comando, ['cultivos', 'todas las fincas', 'catálogo de cultivos'])) {
      debugPrint('🚀 Ejecutando navegación -> Cultivos (3)');
      onNavigateToTab?.call(3);
      _voiceService.hablar('Cultivos');
    }
    else if (_coincide(comando, ['guía', 'plantas', 'matas', 'enfermedades', 'plagas', 'guía de plantas'])) {
      debugPrint('🚀 Ejecutando navegación -> Guía de plantas (4)');
      onNavigateToTab?.call(4);
      _voiceService.hablar('Guía de plantas');
    }
    else if (_coincide(comando, ['tienda', 'comprar', 'mercado', 'precios', 'insumos'])) {
      debugPrint('🚀 Ejecutando navegación -> Tienda (5)');
      onNavigateToTab?.call(5);
      _voiceService.hablar('Tienda');
    }
    else if (_coincide(comando, ['parámetros', 'configuración', 'ajustes', 'administración'])) {
      debugPrint('🚀 Ejecutando navegación -> Parámetros (6)');
      onNavigateToTab?.call(6);
      _voiceService.hablar('Parámetros');
    }
    else if (_coincide(comando, ['perfil', 'mi cuenta', 'mis datos', 'quién soy', 'ver perfil'])) {
      debugPrint('🚀 Ejecutando navegación -> Perfil');
      onOpenPerfil?.call();
      _voiceService.hablar('Perfil');
    } else {
      debugPrint('⚠️ Ninguna regla coincidió con "$comando"');
    }
  }

  bool _coincide(String comando, List<String> expresiones) {
    for (final expresion in expresiones) {
      if (comando.contains(expresion)) return true;
    }
    return false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}