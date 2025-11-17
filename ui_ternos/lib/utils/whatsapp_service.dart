// lib/utils/whatsapp_service.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  Future<void> launchWhatsApp({
    required BuildContext context,
    required String telefono,
    required String mensaje,
  }) async {
    // 1. Limpiar el número y asumir el código de país (ej. 51 para Perú)
    String telefonoLimpio = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    if (telefonoLimpio.length == 9) {
      // Asume 9 dígitos para celular en Perú
      telefonoLimpio = '51$telefonoLimpio';
    }

    // 2. Codificar el mensaje para la URL
    final String url =
        'https://wa.me/$telefonoLimpio?text=${Uri.encodeComponent(mensaje)}';

    // 3. Intentar lanzar la URL
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError(context, 'No se pudo abrir WhatsApp.');
      }
    } catch (e) {
      _showError(context, 'Error al intentar abrir WhatsApp: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
