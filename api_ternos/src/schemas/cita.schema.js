// src/schemas/cita.schema.js
import { z } from "zod";

// Enums según tu schema.prisma
const PropositoEnum = z.enum(["PRUEBA", "MEDIDAS", "ASESORIA", "OTRO"]);
const EstadoEnum    = z.enum(["PENDIENTE", "COMPLETADA", "CANCELADA"]);

// Aceptar BigInt como string o number
const bigintLike = z.union([
  z.string().regex(/^\d+$/, "Debe ser un número positivo"),
  z.number().int().nonnegative()
]);

// ================================================
// LISTAR CITAS (GET) → valida req.query
// ================================================
export const listCitasSchema = z.object({
  estado: EstadoEnum.optional(),
  proposito: PropositoEnum.optional(),
  clienteId: bigintLike.optional(),
  desde: z.string().optional(),  // ISO date
  hasta: z.string().optional()
});

// ================================================
// CREAR CITA (POST) → valida req.body
// ================================================
export const createCitaSchema = z.object({
  clienteId: bigintLike,
  fechaHora: z.string().min(1, "fechaHora es requerida"),
  proposito: PropositoEnum.optional(),
  notas: z.string().max(200).optional()
});

// ================================================
// ACTUALIZAR CITA (PUT) → valida req.body
// ================================================
export const updateCitaSchema = z.object({
  fechaHora: z.string().optional(),
  proposito: PropositoEnum.optional(),
  notas: z.string().max(200).optional()
}).refine(
  (data) =>
    data.fechaHora !== undefined ||
    data.proposito !== undefined ||
    data.notas !== undefined,
  { message: "Debes enviar al menos un campo para actualizar" }
);

// ================================================
// CAMBIAR SOLO EL ESTADO (PATCH) → valida req.body
// ================================================
export const updateEstadoCitaSchema = z.object({
  estado: EstadoEnum
});
