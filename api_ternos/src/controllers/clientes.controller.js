// src/controllers/cliente.controller.js
import { prisma } from "../lib/prisma.js";

const baseSelect = {
  id: true,
  nombres: true,
  apellidos: true,
  celular: true,
  direccion: true,
  dni: true,
  fecha_nac: true,
  vetado: true,
  motivo_veto: true,
  created_at: true,
  updated_at: true,
};

function jsonBigIntSafe(data) {
  return JSON.parse(
    JSON.stringify(
      data,
      (_, v) => (typeof v === "bigint" ? v.toString() : v)
    )
  );
}

// GET /api/clientes
export const listar = async (req, res, next) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const pageSize = Math.min(
      Math.max(parseInt(req.query.pageSize) || 10, 1),
      100
    );
    const search = (req.query.search || "").trim();

    const where = { deleted_at: null };
    if (search) {
      Object.assign(where, {
        OR: [
          { nombres: { contains: search } },
          { apellidos: { contains: search } },
          { dni: { contains: search } },
          { celular: { contains: search } },
        ],
      });
    }

    const [total, data] = await Promise.all([
      prisma.cliente.count({ where }),
      prisma.cliente.findMany({
        where,
        select: baseSelect,
        orderBy: { created_at: "desc" },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
    ]);

    const payload = jsonBigIntSafe({ page, pageSize, total, data });
    return res.json(payload);
  } catch (err) {
    next(err);
  }
};

// GET /api/clientes/:id
export const obtener = async (req, res, next) => {
  try {
    const id = BigInt(req.params.id);
    const c = await prisma.cliente.findFirst({
      where: { id, deleted_at: null },
      select: baseSelect,
    });

    if (!c) {
      return res.status(404).json({ error: "NOT_FOUND" });
    }

    return res.json(jsonBigIntSafe(c));
  } catch (err) {
    next(err);
  }
};

// POST /api/clientes
export const crear = async (req, res, next) => {
  try {
    // Ojo: req.validated lo suele poner tu middleware de validación
    const payload = { ...req.validated };

    if (payload.fecha_nac) {
      payload.fecha_nac = new Date(payload.fecha_nac);
      if (payload.fecha_nac > new Date()) {
        throw new Error("fecha_nac no puede ser futura");
      }
    }

    const nuevo = await prisma.cliente.create({
      data: payload,
      select: baseSelect,
    });

    return res.status(201).json(jsonBigIntSafe(nuevo));
  } catch (err) {
    next(err);
  }
};

// PUT /api/clientes/:id
export const actualizar = async (req, res, next) => {
  try {
    const id = BigInt(req.params.id);
    const payload = req.validated ?? req.body;

    const existe = await prisma.cliente.findUnique({ where: { id } });
    if (!existe) {
      return res
        .status(404)
        .json({ error: "NOT_FOUND", message: "Cliente no existe" });
    }

    if (payload.fecha_nac) {
      payload.fecha_nac = new Date(payload.fecha_nac);
    }

    const upd = await prisma.cliente.update({
      where: { id },
      data: payload,
      select: baseSelect,
    });

    return res.json(jsonBigIntSafe(upd));
  } catch (err) {
    next(err);
  }
};

// PATCH /api/clientes/:id (parcial)
export const parcial = async (req, res, next) => {
  try {
    const id = BigInt(req.params.id);
    const payload = req.validated ?? req.body;

    if (payload?.vetado && !payload?.motivo_veto) {
      return res.status(400).json({
        error: "VALIDATION_ERROR",
        message: "motivo_veto requerido si vetado=true",
      });
    }

    if (payload.fecha_nac) {
      payload.fecha_nac = new Date(payload.fecha_nac);
    }

    const upd = await prisma.cliente.update({
      where: { id },
      data: payload,
      select: baseSelect,
    });

    return res.json(jsonBigIntSafe(upd));
  } catch (err) {
    next(err);
  }
};

// PATCH /api/clientes/:id/veto
export const veto = async (req, res, next) => {
  try {
    const id = BigInt(req.params.id);
    const { vetado, motivo_veto } = req.validated ?? req.body;

    const upd = await prisma.cliente.update({
      where: { id },
      data: { vetado, motivo_veto },
      select: baseSelect,
    });

    return res.json(jsonBigIntSafe(upd));
  } catch (err) {
    next(err);
  }
};

// DELETE lógico /api/clientes/:id
export const eliminar = async (req, res, next) => {
  try {
    const id = BigInt(req.params.id);
    const del = await prisma.cliente.update({
      where: { id },
      data: { deleted_at: new Date() },
      select: { id: true },
    });

    // También aquí usamos jsonBigIntSafe por si id sigue siendo BigInt
    return res.json(jsonBigIntSafe({ ok: true, id: del.id }));
  } catch (err) {
    next(err);
  }
};
