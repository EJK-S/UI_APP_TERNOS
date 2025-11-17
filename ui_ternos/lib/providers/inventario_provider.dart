import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/inventario_categoria.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';

class InventarioProvider extends ChangeNotifier {
  PrendaProvider _prendaProvider;

  // --- CAMBIO CLAVE ---
  // Esta es la "lista maestra" de categorías.
  // La extraemos de las prendas al inicio.
  List<String> _nombresDeCategorias = [];

  // La lista de categorías que mostramos (calculada)
  List<InventarioCategoria> _categoriasCalculadas = [];
  String _filtroCategoria = '';
  List<InventarioCategoria> get categorias {
    if (_filtroCategoria.isEmpty) {
      return _categoriasCalculadas; // Retorna todo si no hay filtro
    } else {
      // Retorna solo las categorías que coincidan con el filtro
      return _categoriasCalculadas
          .where((cat) => cat.nombre.toLowerCase().contains(_filtroCategoria))
          .toList();
    }
  }

  InventarioProvider(this._prendaProvider) {
    // Llenamos la lista maestra inicial y calculamos
    _actualizarListaMaestra();
    _calcularCategorias();
  }

  // Se llama cuando el PrendaProvider se actualiza
  void update(PrendaProvider newPrendaProvider) {
    _prendaProvider = newPrendaProvider;
    _actualizarListaMaestra(); // Re-calcula la lista maestra por si hay nuevas prendas
    _calcularCategorias();
    notifyListeners();
  }

  // --- NUEVO MÉTODO ---
  // Para el botón "Agregar nuevo tipo de prenda"
  void agregarCategoria(String nombre) {
    if (nombre.isEmpty || _nombresDeCategorias.contains(nombre)) return;

    _nombresDeCategorias.add(nombre);
    _calcularCategorias(); // Recalcula para añadir la nueva categoría (con 0 stock)
    notifyListeners();
  }

  // Actualiza la lista maestra de categorías basándose en las prendas
  void _actualizarListaMaestra() {
    final categoriasDePrendas = _prendaProvider.prendas
        .map((p) => p.categoria)
        .toSet();
    // Añadimos cualquier categoría de las prendas que no esté en nuestra lista maestra
    for (var cat in categoriasDePrendas) {
      if (!_nombresDeCategorias.contains(cat)) {
        _nombresDeCategorias.add(cat);
      }
    }
  }

  void filtrarCategorias(String query) {
    _filtroCategoria = query.toLowerCase();
    notifyListeners(); // Avisa a la lista que se redibuje con el filtro
  }

  // ¡LA LÓGICA PRINCIPAL!
  // Ahora calcula los totales basándose en la "lista maestra"
  void _calcularCategorias() {
    _categoriasCalculadas = _nombresDeCategorias.map((nombreCategoria) {
      final disponibles = _prendaProvider.contarPorCategoriaYEstado(
        nombreCategoria,
        PrendaEstado.Disponible,
      );
      final alquilados = _prendaProvider.contarPorCategoriaYEstado(
        nombreCategoria,
        PrendaEstado.Alquilado,
      );
      final mantenimiento = _prendaProvider.contarPorCategoriaYEstado(
        nombreCategoria,
        PrendaEstado.Mantenimiento,
      );

      // --- AÑADIDO ---
      final vendidos = _prendaProvider.contarPorCategoriaYEstado(
        nombreCategoria,
        PrendaEstado.Vendido,
      );
      // --- FIN DE LA ADICIÓN ---

      return InventarioCategoria(
        nombre: nombreCategoria,
        disponibles: disponibles,
        alquilados: alquilados,
        mantenimiento: mantenimiento,
        vendidos: vendidos, // <-- AÑADIDO
      );
    }).toList();
  }

  // Método 'actualizarStock' (se mantiene igual)
  void actualizarStock() {
    print('Stock actualizado! (simulado)');
    _calcularCategorias();
    notifyListeners();
  }

  Future<void> eliminarCategoria(String nombreCategoria) async {
    // 1. Limpiar el nombre
    final nombreTrimmed = nombreCategoria.trim();

    // 2. Comprobar si la categoría está vacía
    final prendasEnCategoria = _prendaProvider
        .getPrendasPorCategoria(nombreTrimmed)
        .length;

    if (prendasEnCategoria > 0) {
      // 3. Si no está vacía, lanzar un error
      throw Exception(
        'No se puede eliminar: La categoría "$nombreCategoria" todavía tiene $prendasEnCategoria prendas.',
      );
    }

    // 4. Si está vacía, eliminarla de la lista maestra y recalcular
    _nombresDeCategorias.removeWhere((cat) => cat == nombreTrimmed);
    _calcularCategorias();
    notifyListeners();
  }
}
