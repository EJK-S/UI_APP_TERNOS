import { z } from "zod";
const trim = (s) => s?.trim?.();

export const createClienteSchema = z.object({
  nombres: z.string().min(1).transform(trim),
  apellidos: z.string().min(1).transform(trim),
  celular: z.string().regex(/^\d{9}$/, "celular debe tener 9 dígitos"),
  direccion: z.string().max(120).optional().transform((v) => v?.trim?.()),
  dni: z.string().regex(/^\d{8}$/, "dni debe tener 8 dígitos"),
  fecha_nac: z
    .union([z.string().date(), z.string().datetime({ offset: false })])
    .optional(),
  vetado: z.boolean().optional().default(false),
  motivo_veto: z.string().max(200).optional(),
}).superRefine((data, ctx) => {
  if (data.vetado && !data.motivo_veto) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: "motivo_veto es obligatorio si vetado=true" });
  }
});

export const updateClienteSchema = createClienteSchema.partial();

export const vetoSchema = z.object({
  vetado: z.boolean(),
  motivo_veto: z.string().min(1),
});
