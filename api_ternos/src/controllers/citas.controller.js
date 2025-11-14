// src/controllers/citas.controller.js
import { prisma } from "../lib/prisma.js";
import { Prisma, PropositoCita, EstadoCita } from "@prisma/client";

// Convertir enums de Prisma a arrays simples
const PROPOSITOS_PERMITIDOS = Object.values(PropositoCita);
const ESTADOS_PERMITIDOS = Object.values(EstadoCita);

// Convertir BigInt a string en la respuesta
const mapCita = (c) => ({
  id: c.id.toString(),
  clienteId: c.cliente_id.toString(),
  fechaHora: c.fecha_hora.toISOString(),
  proposito: c.proposito,
  estado: c.estado,
  notas: c.notas,
  createdAt: c.created_at.toISOString(),
});

// Validar BigInt que viene como string/number
const parseBigIntParam = (value) => {
  if (!/^\d+$/.test(String(value))) return null;
  return BigInt(value);
};

// ================================================
// GET /api/citas
// ================================================
export const getCitas = async (req, res, next) => {
  try {
    const { estado, clienteId, proposito, desde, hasta } = req.query;

    const where = {};

    if (estado) where.estado = estado;
    if (proposito) where.proposito = proposito;

    if (clienteId !== undefined) {
      const clienteIdBig = parseBigIntParam(clienteId);
      if (!clienteIdBig) {
        return res.status(400).json({ message: "clienteId inválido" });
      }
      where.cliente_id = clienteIdBig;
    }

    if (desde || hasta) {
      where.fecha_hora = {};
      if (desde) where.fecha_hora.gte = new Date(desde);
      if (hasta) where.fecha_hora.lte = new Date(hasta);
    }

    const citas = await prisma.cita.findMany({
      where,
      orderBy: { fecha_hora: "asc" },
    });

    res.json(citas.map(mapCita));
  } catch (error) {
    next(error);
  }
};

// ================================================
// GET /api/citas/:id
// ================================================
export const getCitaById = async (req, res, next) => {
  try {
    const idBig = parseBigIntParam(req.params.id);
    if (!idBig) return res.status(400).json({ message: "ID inválido" });

    const cita = await prisma.cita.findUnique({
      where: { id: idBig },
    });

    if (!cita) {
      return res.status(404).json({ message: "Cita no encontrada" });
    }

    res.json(mapCita(cita));
  } catch (error) {
    next(error);
  }
};

// ================================================
// POST /api/citas
// ================================================
export const createCita = async (req, res, next) => {
  try {
    const { clienteId, fechaHora, proposito, notas } = req.body;

    const clienteIdBig = parseBigIntParam(clienteId);
    if (!clienteIdBig) {
      return res.status(400).json({ message: "clienteId inválido" });
    }

    const fecha = new Date(fechaHora);
    if (isNaN(fecha.getTime())) {
      return res.status(400).json({ message: "fechaHora no es válida" });
    }

    const ahora = new Date();
    if (fecha < ahora) {
      return res.status(400).json({
        message: "No se puede registrar una cita en el pasado",
      });
    }

    const propositoUpper = (proposito || PropositoCita.PRUEBA).toUpperCase();
    if (!PROPOSITOS_PERMITIDOS.includes(propositoUpper)) {
      return res.status(400).json({
        message: `proposito inválido. Valores permitidos: ${PROPOSITOS_PERMITIDOS.join(", ")}`,
      });
    }

    // Verificar si ya existe cita con mismo cliente y fecha/hora PENDIENTE
    const existente = await prisma.cita.findFirst({
      where: {
        cliente_id: clienteIdBig,
        fecha_hora: fecha,
        estado: EstadoCita.PENDIENTE,
      },
    });

    if (existente) {
      return res.status(409).json({
        message: "El cliente ya tiene una cita pendiente en ese horario",
      });
    }

    // Crear cita
    const nueva = await prisma.cita.create({
      data: {
        cliente_id: clienteIdBig,
        fecha_hora: fecha,
        proposito: propositoUpper,
        estado: EstadoCita.PENDIENTE,
        notas: notas || null,
      },
    });

    res.status(201).json(mapCita(nueva));
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      if (error.code === "P2003") {
        return res.status(400).json({
          message: "clienteId no existe en la tabla cliente",
        });
      }
    }
    next(error);
  }
};

// ================================================
// PUT /api/citas/:id
// ================================================
export const updateCita = async (req, res, next) => {
  try {
    const { fechaHora, proposito, notas } = req.body;
    const idBig = parseBigIntParam(req.params.id);

    if (!idBig) {
      return res.status(400).json({ message: "ID inválido" });
    }

    const data = {};

    if (fechaHora !== undefined) {
      const fecha = new Date(fechaHora);
      if (isNaN(fecha.getTime())) {
        return res.status(400).json({ message: "fechaHora no es válida" });
      }
      data.fecha_hora = fecha;
    }

    if (proposito !== undefined) {
      const propositoUpper = proposito.toUpperCase();
      if (!PROPOSITOS_PERMITIDOS.includes(propositoUpper)) {
        return res.status(400).json({
          message: `proposito inválido. Valores permitidos: ${PROPOSITOS_PERMITIDOS.join(", ")}`,
        });
      }
      data.proposito = propositoUpper;
    }

    if (notas !== undefined) {
      data.notas = notas || null;
    }

    try {
      const actualizada = await prisma.cita.update({
        where: { id: idBig },
        data,
      });

      res.json(mapCita(actualizada));
    } catch (error) {
      if (error.code === "P2025") {
        return res.status(404).json({ message: "Cita no encontrada" });
      }
      throw error;
    }
  } catch (error) {
    next(error);
  }
};

// ================================================
// PATCH /api/citas/:id/estado
// ================================================
export const updateEstadoCita = async (req, res, next) => {
  try {
    const { estado } = req.body;
    const idBig = parseBigIntParam(req.params.id);

    if (!idBig) {
      return res.status(400).json({ message: "ID inválido" });
    }

    const estadoUpper = estado.toUpperCase();
    if (!ESTADOS_PERMITIDOS.includes(estadoUpper)) {
      return res.status(400).json({
        message: `estado inválido. Valores permitidos: ${ESTADOS_PERMITIDOS.join(", ")}`,
      });
    }

    try {
      const actualizada = await prisma.cita.update({
        where: { id: idBig },
        data: { estado: estadoUpper },
      });

      res.json(mapCita(actualizada));
    } catch (error) {
      if (error.code === "P2025") {
        return res.status(404).json({ message: "Cita no encontrada" });
      }
      throw error;
    }
  } catch (error) {
    next(error);
  }
};

// ================================================
// DELETE /api/citas/:id
// ================================================
export const deleteCita = async (req, res, next) => {
  try {
    const idBig = parseBigIntParam(req.params.id);

    if (!idBig) {
      return res.status(400).json({ message: "ID inválido" });
    }

    try {
      await prisma.cita.delete({ where: { id: idBig } });
      res.json({ message: "Cita eliminada correctamente" });
    } catch (error) {
      if (error.code === "P2025") {
        return res.status(404).json({ message: "Cita no encontrada" });
      }
      throw error;
    }
  } catch (error) {
    next(error);
  }
};
