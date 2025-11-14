// src/routes/cita.routes.js
import { Router } from "express";
import * as citasController from "../controllers/citas.controller.js";
import { validate } from "../middlewares/validate.js";
import {
  listCitasSchema,
  createCitaSchema,
  updateCitaSchema,
  updateEstadoCitaSchema
} from "../schemas/cita.schema.js";

const router = Router();

// Listar citas con filtros (query)
router.get("/", citasController.getCitas);

// Obtener cita por id
router.get("/:id", citasController.getCitaById);

// Crear nueva cita
router.post(
  "/",
  validate(createCitaSchema),
  citasController.createCita
);

// Actualizar campos (fechaHora, proposito, notas)
router.put(
  "/:id",
  validate(updateCitaSchema),
  citasController.updateCita
);

// Cambiar solo el estado
router.patch(
  "/:id/estado",
  validate(updateEstadoCitaSchema),
  citasController.updateEstadoCita
);

// Eliminar cita (opcional)
router.delete("/:id", citasController.deleteCita);

export default router;
