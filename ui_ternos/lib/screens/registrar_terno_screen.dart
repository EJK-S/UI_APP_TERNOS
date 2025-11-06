import 'package:flutter/material.dart';

class RegistrarTernoScreen extends StatelessWidget {
  const RegistrarTernoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nuevo Terno')),
      body: const Center(child: Text('Formulario para registrar terno')),
    );
  }
}
