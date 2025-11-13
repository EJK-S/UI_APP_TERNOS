export const notFound = (_req, res) => {
  res.status(404).json({ error: "NOT_FOUND" });
};

export const errorHandler = (err, _req, res, _next) => {
  console.error(err);
  if (err?.code === "P2002") {
    return res.status(409).json({ error: "DUPLICATE", message: "dni ya existe" });
  }
  res.status(500).json({ error: "INTERNAL_ERROR" });
};
