// lib/screens/gestion_alquiler/registrar_devolucion_screen.dart (REFACTORIZADO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
// 1. Importar los nuevos modelos
import 'package:proyecto_tienda_ternos/models/pieza_item.dart';

// 2. Convertido a StatefulWidget
class RegistrarDevolucionScreen extends StatefulWidget {
  final Alquiler alquiler; // <-- Mantiene el flujo actual
  const RegistrarDevolucionScreen({super.key, required this.alquiler});

  @override
  State<RegistrarDevolucionScreen> createState() =>
      _RegistrarDevolucionScreenState();
}

class _RegistrarDevolucionScreenState extends State<RegistrarDevolucionScreen> {
  // 3. Traer la lógica de estado del ejemplo

  // TODO: Cargar esta lista desde el Alquiler o la Prenda
  // Por ahora, usamos los datos de ejemplo de tu compañero.
  final List<PiezaItem> _piezas = [
    PiezaItem(nombre: 'Saco', articuloId: 'A-SACO'),
    PiezaItem(nombre: 'Pantalón', articuloId: 'A-PANTALON'),
    PiezaItem(nombre: 'Camisa', articuloId: 'A-CAMISA'),
  ];

  final TextEditingController _observacionesCtrl = TextEditingController();
  EstadoTraje _estadoAgregado = EstadoTraje.incompleto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _recalcularEstado();
  }

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    super.dispose();
  }

  // Lógica de cálculo del ejemplo (sin cambios)
  void _recalcularEstado() {
    final seleccionadas = _piezas.where((p) => p.selected).toList();
    final anyPerdido = seleccionadas.any(
      (p) => p.estado == PiezaEstado.perdido,
    );
    final anyDaniado = seleccionadas.any(
      (p) => p.estado == PiezaEstado.daniado,
    );
    final allChecked = seleccionadas.length == _piezas.length;

    EstadoTraje nuevo = EstadoTraje.incompleto;
    if (anyPerdido || anyDaniado) {
      nuevo = EstadoTraje.daniado;
    } else if (allChecked && seleccionadas.isNotEmpty) {
      nuevo = EstadoTraje.completo;
    }
    setState(() {
      _estadoAgregado = nuevo;
    });
  }

  // Lógica de botones del ejemplo (sin cambios)
  bool get _puedeRegistrar => _piezas.any((p) => p.selected) && !_isSaving;
  bool get _puedeDevolverGarantia =>
      _estadoAgregado == EstadoTraje.completo && _puedeRegistrar;
  bool get _puedeRetenerGarantia =>
      _estadoAgregado != EstadoTraje.completo && _puedeRegistrar;

  // 4. NUEVA función de guardado
  Future<void> _registrarDevolucion(bool retenerGarantia) async {
    setState(() => _isSaving = true);

    // Filtra solo las piezas seleccionadas para enviar
    final piezasDevueltas = _piezas.where((p) => p.selected).toList();

    try {
      await context.read<AlquilerProvider>().registrarDevolucionDetallada(
        alquiler: widget.alquiler, // <-- Pasa el alquiler del widget
        piezasDevueltas: piezasDevueltas,
        observaciones: _observacionesCtrl.text,
        garantiaRetenida: retenerGarantia,
      );

      if (mounted) {
        Navigator.pop(context); // Cierra este
        Navigator.pop(context); // Cierra el detalle
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al registrar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // 5. Build (Combinando tu UI con la del ejemplo)
  @override
  Widget build(BuildContext context) {
    // Obtenemos el nombre del cliente (como en tu código original)
    final clienteProvider = context.read<ClienteProvider>();
    Cliente? cliente;
    try {
      cliente = clienteProvider.clientes.firstWhere(
        (c) => c.id == widget.alquiler.clienteId,
      );
    } catch (e) {
      cliente = null;
    }
    final String nombreCliente = cliente != null
        ? '${cliente.nombre} ${cliente.apellidos ?? ''}'
        : 'Cliente (ID: ${widget.alquiler.clienteId})';

    final primary = AppColors.primary;
    final bg = Theme.of(context).colorScheme.surface;
    final border = Theme.of(context).colorScheme.outlineVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devolución de Terno'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- Tarjeta de Info (Tu lógica original) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registrando devolución para:',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.stone600),
                        ),
                        Text(
                          widget.alquiler.producto,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Cliente: $nombreCliente',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.stone700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Lista de Piezas (Lógica del ejemplo) ---
                  const Text(
                    'Piezas devueltas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  ..._piezas.map(
                    (p) => _PiezaTile(
                      pieza: p,
                      primary: primary,
                      onChanged: (selected) {
                        p.selected = selected ?? false;
                        _recalcularEstado();
                      },
                      onEstadoChanged: (estado) {
                        if (estado != null) p.estado = estado;
                        _recalcularEstado();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Estado Agregado (Lógica del ejemplo) ---
                  const Text(
                    'Estado del traje',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        text: 'Completo',
                        active: _estadoAgregado == EstadoTraje.completo,
                        activeColor: primary,
                      ),
                      _Badge(
                        text: 'Incompleto',
                        active: _estadoAgregado == EstadoTraje.incompleto,
                        activeColor: primary,
                      ),
                      _Badge(
                        text: 'Dañado',
                        active: _estadoAgregado == EstadoTraje.daniado,
                        activeColor: primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Estado calculado: ${_estadoAgregado.label.toLowerCase()}.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Observaciones (Lógica del ejemplo) ---
                  const Text(
                    'Observaciones',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _observacionesCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Añadir observaciones...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Botones de Acción (Lógica del ejemplo, pero conectados) ---
                  // (Estos reemplazan tus antiguos botones 'Finalizar y...')
                  FilledButton.tonal(
                    onPressed: _puedeDevolverGarantia
                        ? () =>
                              _registrarDevolucion(false) // false = no retener
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Registrar y Devolver Garantía'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _puedeRetenerGarantia
                        ? () =>
                              _registrarDevolucion(true) // true = retener
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: _puedeRetenerGarantia
                          ? Colors.red.shade700
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Registrar y Retener Garantía'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES (Copiados del ejemplo, sin cambios) ---

class _PiezaTile extends StatelessWidget {
  const _PiezaTile({
    required this.pieza,
    required this.primary,
    required this.onChanged,
    required this.onEstadoChanged,
  });

  final PiezaItem pieza;
  final Color primary;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<PiezaEstado?> onEstadoChanged;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    final bg = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: pieza.selected, onChanged: onChanged),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pieza.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Estado pieza', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<PiezaEstado>(
                        value: pieza.estado,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more),
                        decoration: InputDecoration(
                          enabled: pieza.selected,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: PiezaEstado.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.label),
                              ),
                            )
                            .toList(),
                        onChanged: pieza.selected ? onEstadoChanged : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${pieza.articuloId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.active,
    required this.activeColor,
  });

  final String text;
  final bool active;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    final bg = active ? activeColor : Colors.transparent;
    final fg = active ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? activeColor : border),
      ),
      child: Text(text, style: TextStyle(color: fg)),
    );
  }
}
