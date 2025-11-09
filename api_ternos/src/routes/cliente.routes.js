import { Router } from 'express';
import * as ctrl from '../controllers/cliente.controller.js';

const router = Router();

/**
 * Rutas de Clientes
 * Prefijo general: /api/clientes
 * Todas devuelven JSON
 */

// ✅ Listar todos
router.get('/', ctrl.listar); // GET /api/clientes

// ✅ Obtener cliente por ID
router.get('/:id', ctrl.obtenerPorId); // GET /api/clientes/:id

// ✅ Crear nuevo cliente
router.post('/', ctrl.crear); // POST /api/clientes

// ✅ Actualizar cliente existente
router.put('/:id', ctrl.actualizar); // PUT /api/clientes/:id
router.patch('/:id', ctrl.actualizar); // PATCH /api/clientes/:id (por compatibilidad)

// ✅ Eliminar cliente
router.delete('/:id', ctrl.eliminar); // DELETE /api/clientes/:id

// ✅ Preflight OPTIONS (para navegadores / Flutter Web)
router.options('*', (_req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  return res.sendStatus(204);
});

export default router;

