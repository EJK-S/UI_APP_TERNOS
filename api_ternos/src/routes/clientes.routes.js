import { Router } from "express";
import * as ctrl from "../controllers/clientes.controller.js";
import { validate } from "../middlewares/validate.js";
import { createClienteSchema, updateClienteSchema, vetoSchema } from "../schemas/cliente.schema.js";

const r = Router();
r.get("/", ctrl.listar);
r.get("/:id", ctrl.obtener);
r.post("/", validate(createClienteSchema), ctrl.crear);
r.put("/:id", validate(createClienteSchema), ctrl.actualizar);
r.patch("/:id", validate(updateClienteSchema), ctrl.parcial);
r.patch("/:id/veto", validate(vetoSchema), ctrl.veto);
r.delete("/:id", ctrl.eliminar);
export default r;
