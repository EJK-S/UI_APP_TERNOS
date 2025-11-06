import 'package:flutter/material.dart';

class NuevaCitaScreen extends StatelessWidget {
  const NuevaCitaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nueva Cita')),
      body: const Center(child: Text('Formulario para crear nueva cita')),
    );
  }
}
