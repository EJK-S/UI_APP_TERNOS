import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';

class EditarCitaScreen extends StatelessWidget {
  final Cita cita;
  const EditarCitaScreen({super.key, required this.cita});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cita')),
      body: Center(
        child: Text('Formulario para editar la cita de ${cita.clienteNombre}'),
      ),
    );
  }
}
