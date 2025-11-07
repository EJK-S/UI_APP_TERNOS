import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class NuevoClienteScreen extends StatefulWidget {
  const NuevoClienteScreen({super.key});

  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _fechaNacimientoCtrl = TextEditingController();
  final _motivoVetoCtrl = TextEditingController();
  bool _vetado = false; // Por defecto, un nuevo cliente no está vetado

  @override
  void dispose() {
    // Limpia todos los controladores
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _fechaNacimientoCtrl.dispose();
    _motivoVetoCtrl.dispose();
    super.dispose();
  }

  void _guardarCliente() {
    // Valida el formulario
    if (_formKey.currentState!.validate()) {
      // Crea el nuevo objeto Cliente
      final nuevoCliente = Cliente(
        nombre: _nombresCtrl.text,
        apellidos: _apellidosCtrl.text,
        dni: _dniCtrl.text, // (Deberías validar que este DNI no exista)
        telefono: _telefonoCtrl.text,
        correo: _correoCtrl.text,
        direccion: _direccionCtrl.text,
        fechaNacimiento: _fechaNacimientoCtrl.text,
        vetado: _vetado,
        motivoVeto: _motivoVetoCtrl.text,
      );

      // "Habla" con el cerebro para agregar el cliente
      Provider.of<ClienteProvider>(
        context,
        listen: false,
      ).agregarCliente(nuevoCliente);

      // Regresa a la lista de clientes
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Cliente'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Nombres y Apellidos en fila
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _nombresCtrl,
                      label: 'Nombres',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _apellidosCtrl,
                      label: 'Apellidos',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dniCtrl,
                label: 'DNI',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telefonoCtrl,
                label: 'Teléfono',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _correoCtrl,
                label: 'Correo',
                keyboardType: TextInputType.emailAddress,
                isRequired: false, // Hacemos el correo opcional
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _direccionCtrl,
                label: 'Dirección',
                isRequired: false, // Opcional
              ),
              const SizedBox(height: 16),
              _buildDateField(
                controller: _fechaNacimientoCtrl,
                label: 'Fecha de Nacimiento',
              ),
              const SizedBox(height: 16),
              // Checkbox 'Vetado'
              CheckboxListTile(
                title: const Text('Vetado'),
                value: _vetado,
                onChanged: (bool? value) {
                  setState(() {
                    _vetado = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              // Motivo de veto (se muestra si está vetado)
              if (_vetado)
                _buildTextField(
                  controller: _motivoVetoCtrl,
                  label: 'Motivo de veto',
                  hint: 'Ingresar motivo',
                  isRequired: false,
                ),
            ],
          ),
        ),
      ),
      // Barra inferior con botones
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                child: const Text('Guardar Cliente'), // Texto cambiado
                onPressed: _guardarCliente, // Función de guardar
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (Helpers) ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onTap: () async {
            FocusScope.of(context).requestFocus(new FocusNode());
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text =
                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            }
          },
        ),
      ],
    );
  }
}
