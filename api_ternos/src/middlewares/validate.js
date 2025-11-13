export const validate = (schema) => async (req, res, next) => {
  try {
    const parsed = await schema.parseAsync(req.body);
    req.validated = parsed;
    next();
  } catch (err) {
    return res.status(400).json({ error: "VALIDATION_ERROR", details: err.errors || String(err) });
  }
};
