import pool from '../../db.js';

// --- Helpers ---
const fromBodyToDb = (b) => ({
  nombres: b.nombres ?? b.nombre ?? '',
  apellidos: b.apellidos ?? '',
  celular: b.celular ?? b.telefono ?? '',
  direccion: b.direccion ?? null,
  dni: b.dni ?? null,
  fecha_nac: b.fecha_nac ?? (b.fechaNacimiento ? toIsoDate(b.fechaNacimiento) : null),
  vetado: b.vetado ?? false,
  motivo_veto: b.motivo_veto ?? b.motivoVeto ?? null,
});

function toIsoDate(d) {
  if (!d) return null;

  // 2002-09-15T05:00:00.000Z  ó  2002-09-15 00:00:00
  const m = String(d).match(/^(\d{4}-\d{2}-\d{2})/);
  if (m) return m[1];

  // dd/MM/yyyy -> yyyy-MM-dd
  if (/^\d{2}\/\d{2}\/\d{4}$/.test(d)) {
    const [dd, mm, yyyy] = d.split('/');
    return `${yyyy}-${mm}-${dd}`;
  }

  return d; // ya es ISO simple
}



// --- Controladores ---

export async function listar(_req, res) {
  try {
    const [rows] = await pool.query('SELECT * FROM cliente ORDER BY created_at DESC');
    return res.json(rows);
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Error listando clientes' });
  }
}

export async function obtenerPorId(req, res) {
  try {
    const [rows] = await pool.query('SELECT * FROM cliente WHERE id=?', [req.params.id]);
    if (!rows.length) {
      return res.status(404).json({ error: 'Cliente no encontrado' });
    }
    return res.json(rows[0]);
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Error obteniendo cliente' });
  }
}

export async function crear(req, res) {
  try {
    const b = req.body ?? {};
    // Validación mínima (evita NULL obligatorios)
    if (!b.nombres && !b.nombre) return res.status(400).json({ error: 'nombres es requerido' });
    if (!b.dni) return res.status(400).json({ error: 'dni es requerido' });
    if (!b.celular && !b.telefono) return res.status(400).json({ error: 'celular/telefono es requerido' });

    // Normalización
    const d = fromBodyToDb(b);
    d.fecha_nac = !d.fecha_nac || d.fecha_nac === '' ? null : d.fecha_nac;
    d.vetado = (d.vetado === true || d.vetado === 1 || d.vetado === '1' || d.vetado === 'true') ? 1 : 0;
    d.apellidos = d.apellidos ?? '';
    d.direccion = d.direccion ?? null;
    d.motivo_veto = d.motivo_veto ?? null;

    const sql = `
      INSERT INTO cliente (nombres, apellidos, celular, direccion, dni, fecha_nac, vetado, motivo_veto)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const [r] = await pool.execute(sql, [
      d.nombres, d.apellidos, d.celular, d.direccion, d.dni, d.fecha_nac, d.vetado, d.motivo_veto,
    ]);

    const [row] = await pool.query('SELECT * FROM cliente WHERE id=?', [r.insertId]);
    return res.status(201).json(row[0]);
  } catch (e) {
    console.error('ERROR crear cliente:', e.code, e.sqlMessage || e.message);
    if (e.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'DNI ya registrado' });
    }
    return res.status(500).json({ error: e.sqlMessage || 'Error creando cliente' });
  }
}

export async function actualizar(req, res) {
  try {
    const id = req.params.id;
    if (!id) return res.status(400).json({ error: 'id requerido' });

    const b = req.body ?? {};
    // Validación mínima (si tu UI siempre manda todo, mantenemos required)
    if (!b.nombres && !b.nombre) return res.status(400).json({ error: 'nombres es requerido' });
    if (!b.dni) return res.status(400).json({ error: 'dni es requerido' });
    if (!b.celular && !b.telefono) return res.status(400).json({ error: 'celular/telefono es requerido' });

    // Normalización
    const d = fromBodyToDb(b);
    d.fecha_nac = !d.fecha_nac || d.fecha_nac === '' ? null : d.fecha_nac;
    d.vetado = (d.vetado === true || d.vetado === 1 || d.vetado === '1' || d.vetado === 'true') ? 1 : 0;
    d.apellidos = d.apellidos ?? '';
    d.direccion = d.direccion ?? null;
    d.motivo_veto = d.motivo_veto ?? null;

    const sql = `
      UPDATE cliente
      SET nombres=?, apellidos=?, celular=?, direccion=?, dni=?, fecha_nac=?, vetado=?, motivo_veto=?
      WHERE id=?
    `;
    const [r] = await pool.execute(sql, [
      d.nombres, d.apellidos, d.celular, d.direccion, d.dni, d.fecha_nac, d.vetado, d.motivo_veto, id,
    ]);

    if (!r.affectedRows) return res.status(404).json({ error: 'Cliente no encontrado' });

    const [row] = await pool.query('SELECT * FROM cliente WHERE id=?', [id]);
    return res.json(row[0]);
  } catch (e) {
    console.error('ERROR actualizar cliente:', e.code, e.sqlMessage || e.message);
    if (e.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'DNI ya registrado' });
    }
    return res.status(500).json({ error: e.sqlMessage || 'Error actualizando cliente' });
  }
}

export async function eliminar(req, res) {
  try {
    const [r] = await pool.execute('DELETE FROM cliente WHERE id=?', [req.params.id]);

    if (!r.affectedRows) {
      return res.status(404).json({ error: 'Cliente no encontrado' });
    }

    // ✅ Devolver JSON explícito para evitar errores en Flutter/Dio
    return res.json({ ok: true, id: req.params.id });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Error eliminando cliente' });
  }
}
