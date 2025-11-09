import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';

class PrendaProvider extends ChangeNotifier {
  // La lista "viva" de todas las prendas individuales
  final List<Prenda> _prendas = List.from(mockPrendas);

  // Getter público
  List<Prenda> get prendas => _prendas;

  // Método para añadir una nueva prenda (desde 'registrar_terno_screen.dart')
  void agregarPrenda(Prenda nuevaPrenda) {
    _prendas.add(nuevaPrenda);
    notifyListeners(); // Avisa a quien esté escuchando (el InventarioProvider)
  }

  // Método para editar una prenda (desde 'editar_prenda_screen.dart')
  void editarPrenda(Prenda prendaActualizada) {
    final index = _prendas.indexWhere((p) => p.id == prendaActualizada.id);
    if (index != -1) {
      _prendas[index] = prendaActualizada;
      notifyListeners();
    }
  }

  // Método para eliminar una prenda
  void eliminarPrenda(String id) {
    _prendas.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // --- MÉTODOS DE CÁLCULO ---
  // Estos son los métodos que usará el 'InventarioProvider'

  // Cuenta cuántas prendas hay de una categoría y estado
  int contarPorCategoriaYEstado(String categoria, PrendaEstado estado) {
    return _prendas
        .where((p) => p.categoria == categoria && p.estado == estado)
        .length;
  }

  // Obtiene todas las prendas de una categoría
  List<Prenda> getPrendasPorCategoria(String categoria) {
    return _prendas.where((p) => p.categoria == categoria).toList();
  }
}
